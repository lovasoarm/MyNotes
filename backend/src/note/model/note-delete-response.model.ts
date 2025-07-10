import {Field, ObjectType} from "@nestjs/graphql";

@ObjectType()
export class NoteDeleteResponse {
    @Field()
    success: boolean;

    @Field()
    deletedId: string;
}