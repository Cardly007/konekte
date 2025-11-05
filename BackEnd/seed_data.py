import sys
import os
import asyncio
from faker import Faker
from sqlalchemy.orm import sessionmaker

# Add the project root to the Python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.core.database import engine
from app.models import (
    User, Profile, Photo, Interaction, Match, DeclarativeBase
)
import random
from datetime import date, timedelta
import logging

# Basic logging setup
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize Faker for French data
fake = Faker('fr_FR')

# Database session setup
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

async def seed_data():
    """
    Seeds the database with fake data for 50 users.
    """
    logger.info("Starting database seeding...")

    # Create all tables
    async with engine.begin() as conn:
        await conn.run_sync(DeclarativeBase.metadata.create_all)

    db = SessionLocal()

    try:
        # Check if users already exist
        if db.query(User).count() > 0:
            logger.info("Database already seeded. Exiting.")
            return

        # 1. Create 50 users with profiles and photos
        users = []
        for i in range(50):
            user = User(
                email=fake.unique.email(),
                phone=fake.unique.phone_number(),
                phone_verified=True,
                auth_provider='email',
                password_hash='fake_password_hash', # In a real app, hash a password
                status='active',
                subscription_tier='free'
            )

            profile = Profile(
                user=user,
                first_name=fake.first_name(),
                date_of_birth=fake.date_of_birth(minimum_age=18, maximum_age=40),
                gender=random.choice(['man', 'woman']),
                location_city=fake.city(),
                bio=fake.sentence(nb_words=15),
                show_gender=random.choice(['men', 'women', 'everyone'])
            )

            # Add 3 to 5 photos for each user
            for j in range(random.randint(3, 5)):
                photo = Photo(
                    user=user,
                    cloudinary_public_id=f'fake_photo_{i}_{j}',
                    cloudinary_url=f'https://picsum.photos/id/{i*10+j}/400/600',
                    cloudinary_secure_url=f'https://picsum.photos/id/{i*10+j}/400/600',
                    display_order=j,
                    moderation_status='approved'
                )
                db.add(photo)

            db.add(user)
            db.add(profile)
            users.append(user)

        db.commit()
        logger.info(f"Created {len(users)} users with profiles and photos.")

        # Refresh users to get their IDs
        for user in users:
            db.refresh(user)

        # 2. Create interactions (likes/dislikes)
        interactions = []
        for user in users:
            # Each user swipes on 10 to 30 other users
            targets = random.sample([u for u in users if u.id != user.id], random.randint(10, 30))
            for target in targets:
                interaction = Interaction(
                    user_id=user.id,
                    target_user_id=target.id,
                    action=random.choice(['like', 'like', 'dislike']) # More likes than dislikes
                )
                interactions.append(interaction)

        db.bulk_save_objects(interactions)
        db.commit()
        logger.info(f"Created {len(interactions)} interactions.")

        # 3. Create matches based on mutual likes
        matches = []
        # A bit inefficient, but fine for a seed script
        for i in range(len(users)):
            for j in range(i + 1, len(users)):
                user1 = users[i]
                user2 = users[j]

                like1 = db.query(Interaction).filter_by(user_id=user1.id, target_user_id=user2.id, action='like').first()
                like2 = db.query(Interaction).filter_by(user_id=user2.id, target_user_id=user1.id, action='like').first()

                if like1 and like2:
                    # Ensure user1_id < user2_id to maintain order
                    u1_id, u2_id = sorted([user1.id, user2.id])
                    match = Match(
                        user1_id=u1_id,
                        user2_id=u2_id,
                        status='active'
                    )
                    matches.append(match)

        db.bulk_save_objects(matches)
        db.commit()
        logger.info(f"Created {len(matches)} matches.")

        logger.info("Database seeding completed successfully!")

    except Exception as e:
        logger.error(f"An error occurred during seeding: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    asyncio.run(seed_data())
