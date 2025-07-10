import {Injectable, BadRequestException, ConflictException, InternalServerErrorException} from '@nestjs/common';
import {Args, Mutation, Query, Resolver} from '@nestjs/graphql';
import {User} from './model/user.model';
import {CreateUserInput} from './dto/create-user.input';
import {LoginInput} from './dto/login.input';
import {PrismaService} from '../prisma.service';
import * as bcrypt from 'bcrypt';
import {FirebaseService} from "../common/firebase/firebase.service";

@Injectable()
@Resolver(() => User)
export class UserResolver {
    constructor(private readonly prisma: PrismaService, private readonly firebaseService: FirebaseService) {
    }

    // Méthode pour trouver ou créer un utilisateur (utile pour Google Auth)
    @Mutation(() => User)
    async findOrCreateUser(@Args('data') data: CreateUserInput): Promise<User> {
        let user = await this.prisma.user.findUnique({
            where: { email: data.email },
        });

        if (!user) {
            const hashed = await bcrypt.hash(data.password, 10);
            user = await this.prisma.user.create({
                data: {
                    email: data.email,
                    password: hashed,
                },
            });
        }

        return user;
    }

@Mutation(() => User)
async createUser(@Args('data') data: CreateUserInput): Promise<User> {
  const existingUser = await this.prisma.user.findUnique({
    where: { email: data.email },
  });

  if (existingUser) {
    // Au lieu de lancer une erreur, retourner l'utilisateur existant
    // Ceci permet aux utilisateurs Google de se connecter sans problème
    //hialàana creatinguser injato
    return existingUser;
  }

  const hashed = await bcrypt.hash(data.password, 10);

  return this.prisma.user.create({
    data: {
      email: data.email,
      password: hashed,
    },
  });
}

    @Query(() => [User])
    async getAllUsers(): Promise<User[]> {
        return this.prisma.user.findMany();
    }

    @Mutation(() => User)
    async login(@Args('data') data: LoginInput): Promise<User> {
        const user = await this.prisma.user.findUnique({
            where: {email: data.email},
        });

        if (!user) {
            throw new BadRequestException('Invalid email or password');
        }

        const isPasswordValid = await bcrypt.compare(data.password, user.password);

        if (!isPasswordValid) {
            throw new BadRequestException('Invalid email or password');
        }

        return user;
    }
}
