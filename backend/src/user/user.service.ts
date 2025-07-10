import {PrismaService} from "../prisma.service";
import {Injectable} from "@nestjs/common";

@Injectable()
export class UserService {
    constructor(private readonly prisma: PrismaService) {
    }

    async getAllUsersWithNotes(){
        return this.prisma.user.findMany({
            include: {
                Note: true,
            },
        });
    }

    async getUserWithNotesByEmail(email: string){
        return this.prisma.user.findFirst({
            where: {email},
            include: {
                Note: true,
            }
        });
    }
}