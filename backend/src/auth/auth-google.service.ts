import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { FirebaseService } from '../common/firebase/firebase.service';
import * as admin from 'firebase-admin';

export interface GoogleAuthDto {
  email: string;
  name?: string;
  googleId: string;
}

@Injectable()
export class AuthGoogleService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly firebaseService: FirebaseService,
  ) {}

  async signInWithGoogle(googleAuthDto: GoogleAuthDto) {
    const { email, name, googleId } = googleAuthDto;

    try {
      // Vérifier si l'utilisateur existe déjà dans la base de données
      let user = await this.prisma.user.findUnique({
        where: { email },
      });

      // Si l'utilisateur n'existe pas, crée le
      if (!user) {
        user = await this.prisma.user.create({
          data: {
            email,
            password: '', // Pas de mot de passe pour les utilisateurs Google
       
          },
        });
      }

      // Pour le développement, utilisons un JWT simple au lieu d'un custom token Firebase
      // En production, vous pourriez utiliser JWT ou un autre mécanisme d'authentification
      const token = `dev-token-${user.id}-${Date.now()}`;
      
      // Firebase custom tokens plus tard :
      // const customToken = await admin.auth().createCustomToken(user.id.toString(), {
      //   email: user.email,
      //   provider: 'google',
      // });

      // Synchroniser avec Firestore si nécessaire (désactivé en mode dev)
      // await this.syncUserToFirestore(user);

      return {
        access_token: token,
        user: {
          id: user.id,
          email: user.email,
        },
      };
    } catch (error) {
      console.error('Error in Google authentication:', error);
      throw new Error('Erreur lors de l\'authentification Google');
    }
  }

  private async syncUserToFirestore(user: any) {
    try {
      // Utiliser votre service Firebase existant pour synchroniser
      await this.firebaseService.syncUsersAndNotes([{
        id: user.id.toString(),
        email: user.email,
        password: user.password,
        Note: [], // L'utilisateur n'a pas encore de notes
      }]);
    } catch (error) {
      // Log de l'erreur mais ne pas faire échouer l'authentification
      console.error('Error syncing user to Firestore:', error);
    }
  }
}
