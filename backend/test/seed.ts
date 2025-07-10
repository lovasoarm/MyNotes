import {PrismaClient} from "../generated/prisma";
import {faker} from '@faker-js/faker';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

const numberToGenerate = parseInt(process.argv[2] || '500', 10);
const maxDays = parseInt(process.argv[3] || '30', 10);
const email = process.argv[4] || faker.internet.email().toLowerCase();
const password = process.argv[5] || 'test';

async function main() {
    // Optional: Create a single user to assign notes to
    const user = await prisma.user.create({
        data: {
            email: email,
            password: await bcrypt.hash(password, 10),
        },
    });

    for (let i = 0; i < numberToGenerate; i++) {
        await prisma.note.create({
            data: {
                title: faker.lorem.sentence(),
                content: faker.lorem.paragraph(),
                userId: user.id,
                createdAt: faker.date.recent({days: maxDays}),
            },
        });
    }

    console.log(`✅ Created ${numberToGenerate} notes for ${email} (max ${maxDays} days old)`);
}

// Call the main function and handle errors
main()
    .catch((e) => {
        console.error('❌ Error while seeding:', e);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
