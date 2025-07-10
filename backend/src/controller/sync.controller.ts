import {Body, Controller, Post} from "@nestjs/common";
import {UserService} from "../user/user.service";
import {FirebaseService} from "../common/firebase/firebase.service";

@Controller('sync')
export class SyncController {

    constructor(private readonly userService: UserService, private readonly firebaseService: FirebaseService) {}

    @Post('firebase')
    async syncToFirebase(@Body('email') email?: string): Promise<boolean> {
        let usersWithNotes: any;

        if (email) {
            const user = await this.userService.getUserWithNotesByEmail(email);
            if (!user) {
                return false;
            }
            usersWithNotes = [user];
        } else {
            usersWithNotes = await this.userService.getAllUsersWithNotes();
        }

        await this.firebaseService.syncUsersAndNotes(usersWithNotes);
        return true;
    }

}