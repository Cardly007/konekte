from fastapi import FastAPI, Depends, HTTPException, File, UploadFile, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlmodel import SQLModel, Session, create_engine, select, func
from passlib.hash import bcrypt
from jose import JWTError, jwt
from datetime import datetime, timedelta
import random
from pydantic import BaseModel
import os
import io
from dotenv import load_dotenv
import cloudinary
import cloudinary.uploader

# Assurez-vous que ces modèles sont importés de models.py
from .models import (
    User, UserCreate, UserRead, Match, Message,
    Preference, LocationUpdate, Photo, PhotoRead, Interaction
)
from .database import get_session, engine

# --- 1. Configuration ---
load_dotenv()

# Configuration Cloudinary
cloudinary.config(
    cloud_name=os.getenv("CLOUDINARY_CLOUD_NAME"),
    api_key=os.getenv("CLOUDINARY_API_KEY"),
    api_secret=os.getenv("CLOUDINARY_API_SECRET")
)

# Modèle pour la réponse d'upload
class PhotoUploadResponse(BaseModel):
    photo_id: int
    url: str

# -----------------------
# Configurations JWT
# -----------------------
SECRET_KEY = os.getenv("SECRET_KEY", "supersecretkey_fallback")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/token")

class AuthService:
    @staticmethod
    def get_password_hash(password: str) -> str:
        return bcrypt.hash(password)

    @staticmethod
    def verify_password(plain_password: str, hashed_password: str) -> bool:
        return bcrypt.verify(plain_password, hashed_password)

    @staticmethod
    def create_access_token(data: dict, expires_delta: timedelta = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)) -> str:
        to_encode = data.copy()
        expire = datetime.utcnow() + expires_delta
        to_encode.update({"exp": expire})
        return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

    @staticmethod
    def authenticate_user(session: Session, email: str, password: str) -> User | None:
        user = session.exec(select(User).where(User.email == email)).first()
        if not user or not AuthService.verify_password(password, user.hashed_password):
            return None
        return user

    @staticmethod
    def get_current_user(token: str = Depends(oauth2_scheme), session: Session = Depends(get_session)) -> User:
        credentials_exception = HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
        try:
            payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
            email: str = payload.get("sub")
            if email is None:
                raise credentials_exception
        except JWTError:
            raise credentials_exception
        user = session.exec(select(User).where(User.email == email)).first()
        if user is None:
            raise credentials_exception
        return user

    get_current_active_user = get_current_user


# -----------------------
# Init FastAPI & DB
# -----------------------
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# -----------------------
# Endpoints
# -----------------------
from pydantic import Field as PydanticField

class UserRegister(UserCreate):
    password: str = PydanticField(..., min_length=8)

@app.post("/api/register", response_model=UserRead)
def register_user(user_data: UserRegister, session: Session = Depends(get_session)):
    # Check for existing email
    existing_email = session.exec(select(User).where(User.email == user_data.email)).first()
    if existing_email:
        raise HTTPException(status_code=400, detail="Cet email est déjà utilisé.")

    # Check for existing username
    if user_data.username:
        existing_username = session.exec(select(User).where(User.username == user_data.username)).first()
        if existing_username:
            raise HTTPException(status_code=400, detail="Ce nom d'utilisateur est déjà pris.")

    hashed_password = AuthService.get_password_hash(user_data.password)

    db_user = User(
        nom=user_data.nom,
        username=user_data.username,
        email=user_data.email,
        description=user_data.description,
        hashed_password=hashed_password,
        birthdate=user_data.birthdate,
        last_seen=datetime.utcnow()
    )
    session.add(db_user)
    session.commit()
    session.refresh(db_user)

    default_prefs = Preference(
        user_id=db_user.id,
        min_age=18,
        max_age=55,
        max_distance_km=50,
        target_gender="everyone"
    )
    session.add(default_prefs)
    session.commit()
    return db_user

@app.post("/api/token")
def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), session: Session = Depends(get_session)):
    user = AuthService.authenticate_user(session, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    user.last_seen = datetime.utcnow()
    session.add(user)
    session.commit()
    session.refresh(user)

    access_token = AuthService.create_access_token(data={"sub": user.email})
    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/api/me", response_model=UserRead)
def read_users_me(current_user: User = Depends(AuthService.get_current_user)):
    return current_user

@app.get("/api/profils")
def get_profils(session: Session = Depends(get_session)):
    profils = session.exec(select(User)).all()
    random.shuffle(profils)
    return profils

@app.post("/api/interact")
def add_interaction(inter: Interaction, current_user: User = Depends(AuthService.get_current_user), session: Session = Depends(get_session)):
    inter.user_id = current_user.id
    session.add(inter)
    session.commit()
    session.refresh(inter)

    reciprocal = session.exec(
        select(Interaction).where(
            Interaction.user_id == inter.profil_id,
            Interaction.profil_id == current_user.id,
            Interaction.action == "like"
        )
    ).first()

    if inter.action == "like" and reciprocal:
        existing_match = session.exec(
            select(Match).where(
                ((Match.user1_id == current_user.id) & (Match.user2_id == inter.profil_id)) |
                ((Match.user1_id == inter.profil_id) & (Match.user2_id == current_user.id))
            )
        ).first()

        if not existing_match:
            new_match = Match(user1_id=current_user.id, user2_id=inter.profil_id)
            session.add(new_match)
            session.commit()
            session.refresh(new_match)
            return {"interaction": inter, "match": True}

    return {"interaction": inter, "match": False}


#----------------------
# Gestion photos
# ---------------------
@app.post("/api/profile/me/photos", response_model=PhotoUploadResponse)
async def upload_user_photo(
    file: UploadFile = File(...),
    session: Session = Depends(get_session),
    current_user: User = Depends(AuthService.get_current_active_user)
):
    user_id = current_user.id
    photo_count = session.exec(select(func.count()).select_from(Photo).where(Photo.user_id == user_id)).one()
    if photo_count >= 6:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Maximum of 6 photos allowed per user."
        )

    try:
        upload_result = cloudinary.uploader.upload(
            file.file,
            folder=f"konekte/users/{user_id}",
            resource_type="image",
            overwrite=True,
            unique_filename=True
        )
        secure_url = upload_result.get("secure_url")
        max_order_result = session.exec(select(func.max(Photo.order)).where(Photo.user_id == user_id)).first()
        new_order = (max_order_result if max_order_result is not None else 0) + 1

        new_photo = Photo(
            user_id=user_id,
            url=secure_url,
            order=new_order
        )
        session.add(new_photo)
        session.commit()
        session.refresh(new_photo)

        return PhotoUploadResponse(photo_id=new_photo.id, url=new_photo.url)

    except Exception as e:
        print(f"Cloudinary Upload Error: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error uploading photo: {e}"
        )

@app.delete("/api/profile/me/photos/{photo_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_user_photo(
    photo_id: int,
    session: Session = Depends(get_session),
    current_user: User = Depends(AuthService.get_current_active_user)
):
    photo = session.exec(
        select(Photo)
        .where(Photo.id == photo_id)
        .where(Photo.user_id == current_user.id)
    ).first()

    if not photo:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Photo non trouvée ou n'appartient pas à l'utilisateur."
        )

    try:
        path_segments = photo.url.split('/')
        start_index = path_segments.index('konekte')
        filename_with_ext = path_segments[-1]
        filename_without_ext = os.path.splitext(filename_with_ext)[0]
        public_id = '/'.join(path_segments[start_index:-1] + [filename_without_ext])
        cloudinary.uploader.destroy(public_id)
    except Exception as e:
        print(f"Cloudinary Deletion Error: {e}")

    session.delete(photo)
    session.commit()
    return

class PhotoOrder(BaseModel):
    photo_ids: List[int]

@app.put("/api/profile/me/photos/order")
def reorder_photos(order: PhotoOrder, current_user: User = Depends(AuthService.get_current_user), session: Session = Depends(get_session)):
    if len(order.photo_ids) != len(current_user.photos):
        raise HTTPException(status_code=400, detail="La liste des IDs de photos ne correspond pas au nombre de photos de l'utilisateur.")

    for i, photo_id in enumerate(order.photo_ids):
        photo = session.get(Photo, photo_id)
        if photo and photo.user_id == current_user.id:
            photo.order = i + 1
            session.add(photo)

    session.commit()
    return {"message": "L'ordre des photos a été mis à jour."}

#========================== PROFILE UPDATE ==============================
class LifestyleUpdate(BaseModel):
    drinking: Optional[str] = None
    smoking: Optional[str] = None
    pets: Optional[str] = None

class ProfileUpdate(BaseModel):
    nom: Optional[str] = None
    description: Optional[str] = None
    job: Optional[str] = None
    company: Optional[str] = None
    school: Optional[str] = None
    lifestyle: Optional[LifestyleUpdate] = None

@app.put("/api/profile/me", response_model=UserRead)
def update_my_profile(
    profile_data: ProfileUpdate,
    session: Session = Depends(get_session),
    current_user: User = Depends(AuthService.get_current_active_user)
):
    """Met à jour les informations du profil de l'utilisateur connecté."""

    update_data = profile_data.model_dump(exclude_unset=True)

    for key, value in update_data.items():
        if key == "lifestyle":
            if current_user.lifestyle:
                lifestyle_data = value
                for ls_key, ls_value in lifestyle_data.items():
                    setattr(current_user.lifestyle, ls_key, ls_value)
            else:
                # Si l'utilisateur n'a pas encore de 'lifestyle', on en crée un
                new_lifestyle = Lifestyle(**value, user_id=current_user.id)
                session.add(new_lifestyle)
        elif hasattr(current_user, key):
            setattr(current_user, key, value)

    current_user.last_seen = datetime.utcnow()

    session.add(current_user)
    session.commit()
    session.refresh(current_user)
    return current_user
