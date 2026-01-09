import os
from supabase import Client, create_client


def init_supabase():
    url: str = os.getenv("SUPABASE_URL")
    key: str = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
    supabase_admin: Client = create_client(url, key)

    return supabase_admin
