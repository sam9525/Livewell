import time
import datetime
import os
import jwt
from fastapi import HTTPException
from dotenv import load_dotenv
from jwt.algorithms import ECAlgorithm

# Use a secure secret in production (e.g. from env)
load_dotenv()
AUTH_BEARER_TOKEN = os.environ.get("AUTH_BEARER_TOKEN")
# Your Supabase JWK
SUPABASE_JWK = {
    "x": "zLHBk7mhPIsyBcpBEfrsSwsdwsVV37u04rG5mlvKJDM",
    "y": "BXf8SM2pBj42KW7mura90pgp3gQ2UEpdadeesy2omM4",
    "alg": "ES256",
    "crv": "P-256",
    "kty": "EC",
}

# Convert JWK to public key
public_key = ECAlgorithm.from_jwk(SUPABASE_JWK)
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


def decode_jwt(token: str, algorithm: str) -> dict:
    """
    Decode JWT

    Args: token, algorithm (JWT from google: HS256, JWT from supabase: ES256)
    Returns: decoded token (payload)
    """
    KEY = AUTH_BEARER_TOKEN if algorithm == "HS256" else public_key

    try:
        decoded_token = jwt.decode(
            token, KEY, algorithms=[algorithm], audience="authenticated"
        )
        return decoded_token
    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=401, detail="Token is expired / Token is invalid"
        )
    except jwt.InvalidSignatureError:
        raise HTTPException(
            status_code=401,
            detail="Signature verification failed. Check KEY.",
        )
    except Exception as e:
        raise HTTPException(status_code=401, detail=f"JWT Decode Error (General): {e}")
