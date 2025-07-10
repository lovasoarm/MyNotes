import {SyncController} from "./sync.controller";
import {Module} from "@nestjs/common";
import {FirebaseService} from "../common/firebase/firebase.service";
import {UserModule} from "../user/user.module";

@Module({
    controllers: [SyncController],
    providers: [FirebaseService],
    imports: [UserModule],
})
export class SyncModule {}