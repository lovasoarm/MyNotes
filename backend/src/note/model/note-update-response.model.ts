import {Field, ObjectType} from "@nestjs/graphql";

@ObjectType()
export class NoteUpdateResponse {
    @Field()
    success: boolean;

    @Field()
    updatedId: string;
}