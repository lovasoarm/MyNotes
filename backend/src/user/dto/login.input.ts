import { InputType, Field } from '@nestjs/graphql';
import { IsEmail, IsNotEmpty } from 'class-validator';

@InputType()
export class LoginInput {
  @Field()
  @IsEmail({}, {message: 'Invalid email address' })
  email: string;

  @Field()
  @IsNotEmpty({message: 'Password cannot be empty' })
  password: string;
}