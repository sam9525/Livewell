import time
import datetime
import os
import jwt
from dotenv import load_dotenv

# Use a secure secret in production (e.g. from env)
load_dotenv()
AUTH_BEARER_TOKEN = os.environ.get("AUTH_BEARER_TOKEN")
JWT_ALGORITHM = "HS256"


def create_jwt(user_id: str, email: str) -> str:
    """
    Generate JWT

    Args: user_id, email
    Returns: Decoded JWT
    """
    now = datetime.datetime.utcnow()

    payload = {
        "sub": str(user_id),
        "email": email,
        "role": "authenticated",
        "aud": "authenticated",
        "iss": "supabase",
        "iat": now,
        "exp": now + datetime.timedelta(hours=24),
    }

    return jwt.encode(payload, AUTH_BEARER_TOKEN, algorithm=JWT_ALGORITHM)


def decode_jwt(token: str) -> dict:
    """
    Decode JWT

    Args: token
    Returns: decoded token
    """
    try:
        decoded_token = jwt.decode(token, AUTH_BEARER_TOKEN, algorithms=[JWT_ALGORITHM])
        return decoded_token
    except:
        return None
