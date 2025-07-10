import {Injectable} from '@nestjs/common';
import {CreateNoteInput} from "./dto/create-note.input";
import {Note} from "./model/note.model";
import {PrismaService} from "../prisma.service";
import { Args, Mutation, Query, Resolver } from '@nestjs/graphql';
import {UpdateNoteInput} from "./dto/update-note.input";
import {DeleteNoteInput} from "./dto/delete-note.input";
import {NoteDeleteResponse} from "./model/note-delete-response.model";
import {SearchNoteInput} from "./dto/search-note.input";
import {NoteUpdateResponse} from "./model/note-update-response.model";

@Injectable()
@Resolver(() => Note)
export class NoteResolver {
    constructor(private readonly prisma: PrismaService) {
    }

    @Mutation(() => Note)
    async createNote(
        @Args('data') data: CreateNoteInput
    ): Promise<Note> {
        return this.prisma.note.create({
            data: {
                title: data.title,
                user: {
                    connect: {
                        id: data.userId
                    }
                },
                content: data.content,
            },
            include: {
                user: true,
            }
        });
    }

    @Query(() => [Note])
    async getAllNotes(): Promise<Note[]> {
        return this.prisma.note.findMany({
            include: {
                user: true,
            }
        });
    }

    @Mutation(() => NoteUpdateResponse)
    async updateNote(
        @Args('data') data: UpdateNoteInput
    ): Promise<NoteUpdateResponse> {
        await this.prisma.note.update({
            where: {id: data.id},
            data: {
                title: data.title,
                content: data.content,
            },
            include: {
                user: true,
            },
        });

        return {
            success: true,
            updatedId: data.id,
        }
    }

    @Mutation(() => NoteDeleteResponse)
    async deleteNote(
        @Args('data') data: DeleteNoteInput
    ): Promise<NoteDeleteResponse> {
        await this.prisma.note.delete({
            where: {id: data.id},
            include: {
                user: true
            }
        });

        return {
            success: true,
            deletedId: data.id,
        }
    }

    @Query(() => [Note])
    async searchNotes(@Args('filter') filter: SearchNoteInput): Promise<Note[]> {

        const where: any = {
            userId: filter.userId,
        };

        if (filter.keyword) {
            where.OR = [
                { title: { contains: filter.keyword, mode: 'insensitive' } },
                { content: { contains: filter.keyword, mode: 'insensitive' } },
            ];
        }

        if (filter.startDate || filter.endDate) {
            where.createdAt = {};
            if (filter.startDate) {
                where.createdAt.gte = filter.startDate;
            }
            if (filter.endDate) {
                where.createdAt.lte = filter.endDate;
            }
        }

        return this.prisma.note.findMany({
            where,
            orderBy: {
                createdAt: filter.sortOrder || 'desc',
            },
            skip: filter.offset ?? 0,
            take: filter.limit ?? 10,
            include: {
                user: true,
            },
        });
    }

}


