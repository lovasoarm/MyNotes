import {Field, InputType, Int} from "@nestjs/graphql";

@InputType()
export class CreateNoteInput {

    @Field()
    title: string;

    @Field()
    userId: string;

    @Field()
    content: string;
}