import {Field, GraphQLISODateTime, InputType, Int} from "@nestjs/graphql";
import {SortOrder} from "../../common/enum/sort-order.enum";

@InputType()
export class SearchNoteInput {
    @Field()
    userId: string;

    @Field({nullable: true})
    keyword?: string;

    @Field(() => GraphQLISODateTime, {nullable: true})
    startDate?: Date;

    @Field(() => GraphQLISODateTime, {nullable: true})
    endDate?: Date;

    @Field(() => SortOrder, {nullable: true})
    sortOrder?: SortOrder;

    @Field(() => Int, { nullable: true })
    offset?: number;

    @Field(() => Int, { nullable: true })
    limit?: number;
}