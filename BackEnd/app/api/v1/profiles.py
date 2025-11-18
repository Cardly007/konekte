from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.api.dependencies import get_current_user
from app.models import User, Profile
from app.schemas import ProfileRead, ProfileUpdate

router = APIRouter(tags=["Profiles"])

@router.get("/me", response_model=ProfileRead)
def read_current_user_profile(current_user: User = Depends(get_current_user)):
    """
    Get the profile of the currently authenticated user.
    """
    if not current_user.profile:
        raise HTTPException(status_code=404, detail="Profile not found for the current user.")
    return current_user.profile

@router.put("/me", response_model=ProfileRead)
def update_current_user_profile(
    profile_data: ProfileUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Update the profile of the currently authenticated user.
    """
    profile = current_user.profile
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found for the current user.")

    # Update profile fields
    update_data = profile_data.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(profile, key, value)

    db.add(profile)
    db.commit()
    db.refresh(profile)

    return profile
