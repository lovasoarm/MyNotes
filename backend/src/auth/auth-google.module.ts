import { Module } from '@nestjs/common';
import { AuthGoogleController } from './auth-google.controller';
import { AuthGoogleService } from './auth-google.service';
import { FirebaseModule } from '../common/firebase/firebase.module';
import { PrismaService } from '../prisma.service';

@Module({
  imports: [FirebaseModule],
  controllers: [AuthGoogleController],
  providers: [AuthGoogleService, PrismaService],
  exports: [AuthGoogleService],
})
export class AuthGoogleModule {}
