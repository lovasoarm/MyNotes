import { Module } from '@nestjs/common';
import { PrismaClient } from '../../generated/prisma';

@Module({
  providers: [PrismaClient],
})
export class NotesModule {}
