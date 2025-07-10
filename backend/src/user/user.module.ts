import { Module } from '@nestjs/common';
import {UserService} from "./user.service";
import {PrismaService} from "../prisma.service";
import {FirebaseService} from "../common/firebase/firebase.service";

@Module({
  providers: [UserService, PrismaService],
  exports: [UserService]
})
export class UserModule {}
