from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.security import get_password_hash, verify_password, create_access_token
from app.models import User, Profile
from app.schemas import UserCreate, UserLogin, Token
from sqlalchemy.exc import IntegrityError

router = APIRouter(tags=["Authentication"])

@router.post("/register", response_model=Token, status_code=status.HTTP_201_CREATED)
def register_user(user_data: UserCreate, db: Session = Depends(get_db)):
    """
    Handles user registration.
    - Creates a new user with a hashed password.
    - Creates an associated profile.
    - Returns a JWT access token upon successful registration.
    """
    hashed_password = get_password_hash(user_data.password)

    new_user = User(
        email=user_data.email,
        password_hash=hashed_password,
        auth_provider="email"
    )

    db.add(new_user)

    try:
        db.commit()
        db.refresh(new_user)
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="An account with this email already exists.",
        )

    # Create the user's profile
    new_profile = Profile(
        user_id=new_user.id,
        first_name=user_data.first_name,
        date_of_birth=user_data.date_of_birth,
        gender=user_data.gender
    )
    db.add(new_profile)
    db.commit()

    access_token = create_access_token(subject=new_user.id)
    return {"access_token": access_token, "token_type": "bearer"}

@router.post("/login", response_model=Token)
def login_for_access_token(form_data: UserLogin, db: Session = Depends(get_db)):
    """
    Handles user login.
    - Authenticates the user based on email and password.
    - Returns a JWT access token upon successful authentication.
    """
    user = db.query(User).filter(User.email == form_data.email).first()

    if not user or not verify_password(form_data.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    access_token = create_access_token(subject=user.id)
    return {"access_token": access_token, "token_type": "bearer"}
