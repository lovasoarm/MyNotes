import { PrismaClient } from 'generated/prisma';
import { OnModuleDestroy, OnModuleInit } from '@nestjs/common';

export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  async onModuleInit() {
    await this.$connect();
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }
}