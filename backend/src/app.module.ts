import {Module} from '@nestjs/common';
import {GraphQLModule} from '@nestjs/graphql';
import {UserResolver} from './user/user.resolver';
import {NoteResolver} from "./note/note.resolver";
import {join} from 'path';
import {ApolloDriver, ApolloDriverConfig} from '@nestjs/apollo';
import {PrismaService} from './prisma.service';
import {SyncModule} from "./controller/sync.module";
import {FirebaseModule} from "./common/firebase/firebase.module";
import {AuthGoogleModule} from "./auth/auth-google.module";

@Module({
    imports: [
        GraphQLModule.forRoot<ApolloDriverConfig>({
            driver: ApolloDriver,
            autoSchemaFile: join(process.cwd(), 'src/schema.gql'),
            playground: true,
            path: '/graphql',
        }),
        SyncModule,
        FirebaseModule,
        AuthGoogleModule
    ],
    providers: [PrismaService, UserResolver, NoteResolver],
})
export class AppModule {
}
