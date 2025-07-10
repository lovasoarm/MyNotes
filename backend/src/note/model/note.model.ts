import {User} from "../../user/model/user.model";
import {Field, GraphQLISODateTime, ObjectType} from "@nestjs/graphql";

@ObjectType()
export class Note {
    @Field()
    id: String;

    @Field()
    title: string;

    @Field(() => User)
    user: User;

    @Field()
    content: string;

    @Field(() => GraphQLISODateTime)
    createdAt: Date;

    @Field(() => GraphQLISODateTime)
    updatedAt: Date;
}