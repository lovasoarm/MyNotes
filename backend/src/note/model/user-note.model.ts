import {Field, GraphQLISODateTime, ObjectType} from "@nestjs/graphql";

@ObjectType()
export class UserNote {
    @Field()
    id: String;
    
    @Field()
    title: string;
    
    @Field()
    content: string;
    
    @Field(() => GraphQLISODateTime)
    createdAt: Date;
    
    @Field(() => GraphQLISODateTime)
    updatedAt: Date;
}