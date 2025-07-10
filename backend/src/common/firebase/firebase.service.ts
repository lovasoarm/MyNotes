import {Injectable, OnModuleInit} from "@nestjs/common";
import * as admin from 'firebase-admin'
import * as fs from "node:fs";
import * as path from "node:path";

@Injectable()
export class FirebaseService implements OnModuleInit {

    private firestore: admin.firestore.Firestore | null;

    onModuleInit() {

        if (!admin.apps.length) {
            try {
                const serviceAccountPath = path.join(__dirname, '../../../mynotes.json');
                
                if (fs.existsSync(serviceAccountPath)) {
                    const serviceAccount = JSON.parse(
                        fs.readFileSync(serviceAccountPath, 'utf8'),
                    );

                    // Vérifier si c'est un vrai service account (pas un google-services.json)
                    if (serviceAccount.private_key && serviceAccount.client_email && serviceAccount.project_id) {
                        admin.initializeApp({
                            credential: admin.credential.cert(serviceAccount as admin.ServiceAccount),
                        });
                    } else {
                        console.warn('Firebase service account file exists but is not a valid service account. Using project configuration.');
                        // Configuration basique avec le projet ID
                        admin.initializeApp({
                            projectId: 'mynotes-8d8e9',
                        });
                    }
                } else {
                    // Utiliser les variables d'environnement et les informations du projet
                    console.warn('Firebase service account file not found. Using project configuration.');
                    
                    // Configuration basique avec le projet ID
                    admin.initializeApp({
                        projectId: 'mynotes-8d8e9',
                        // Note: Pour la production, vous devriez utiliser un vrai service account
                    });
                }
            } catch (error) {
                console.error('Error initializing Firebase:', error);
                // Configuration minimale pour les tests
                admin.initializeApp({
                    projectId: 'mynotes-8d8e9',
                });
            }
        }

        try {
            this.firestore = admin.firestore();
        } catch (error) {
            console.warn('Firestore not available:', error.message);
            // Créer un mock firestore pour les tests
            this.firestore = null;
        }

    }

    async syncUsersAndNotes(users: {
        id: string;
        email: string;
        password: string;
        Note: {
            id: number;
            title: string;
            content: string;
            createdAt: Date;
            updatedAt: Date;
        }[];
    }[]) {
        if (!this.firestore) {
            console.warn('Firestore not available, skipping sync');
            return {message: `Skipped sync for ${users.length} users (Firestore not available).`};
        }

        try {
            const batch = this.firestore.batch();

            for (const user of users) {
                const userRef = this.firestore.collection('users').doc(user.id.toString());
                batch.set(userRef, {
                    id: user.id,
                    email: user.email,
                    password: user.password,
                });

                for (const note of user.Note) {
                    const noteRef = this.firestore
                        .collection(`users/${user.id}/notes`)
                        .doc(note.id.toString());

                    batch.set(noteRef, {
                            id: note.id,
                            title: note.title,
                            content: note.content,
                            createdAt: note.createdAt,
                            updatedAt: note.updatedAt,
                        });
                }
            }

            await batch.commit();
            return {message: `Synced ${users.length} users and all their notes.`};
        } catch (error) {
            console.error('Error syncing to Firestore:', error);
            return {message: `Error syncing ${users.length} users.`};
        }
    }

    async getUserByEmail(email: string): Promise<{ id: string; email: string; password: string } | null> {
        if (!this.firestore) {
            console.warn('Firestore not available for getUserByEmail');
            return null;
        }

        try {
            const usersRef = this.firestore.collection('users');
            const querySnapshot = await usersRef.where('email', '==', email).get();

            if (querySnapshot.empty) {
                return null;
            }

            const doc = querySnapshot.docs[0];
            const data = doc.data();

            return {
                id: data.id,
                email: data.email,
                password: data.password,
            };
        } catch (error) {
            console.error('Error getting user by email from Firestore:', error);
            return null;
        }
    }

    async getUserWithNotesByEmail(email: string): Promise<{
        id: string;
        email: string;
        password: string;
        notes: {
            id: string;
            title: string;
            content: string;
            createdAt: Date;
            updatedAt: Date;
        }[];
    } | null> {
        if (!this.firestore) {
            console.warn('Firestore not available for getUserWithNotesByEmail');
            return null;
        }

        try {
            const usersRef = this.firestore.collection('users');
            const querySnapshot = await usersRef.where('email', '==', email).get();

            if (querySnapshot.empty) {
                return null;
            }

            const userDoc = querySnapshot.docs[0];
            const userData = userDoc.data();

            const notesSnapshot = await userDoc.ref.collection('notes').get();
            const notes = notesSnapshot.docs.map(noteDoc => {
                const noteData = noteDoc.data();
                return {
                    id: noteData.id,
                    title: noteData.title,
                    content: noteData.content,
                    createdAt: noteData.createdAt.toDate?.() || new Date(noteData.createdAt),
                    updatedAt: noteData.updatedAt.toDate?.() || new Date(noteData.updatedAt),
                };
            });

            return {
                id: userData.id,
                email: userData.email,
                password: userData.password,
                notes,
            };
        } catch (error) {
            console.error('Error getting user with notes from Firestore:', error);
            return null;
        }
    }


}