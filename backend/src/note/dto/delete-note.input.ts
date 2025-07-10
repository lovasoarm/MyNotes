import {Field, InputType, Int} from "@nestjs/graphql";

@InputType()
export class DeleteNoteInput {
    @Field()
    id: string;
}