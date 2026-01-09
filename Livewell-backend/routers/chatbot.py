import os
from fastapi import APIRouter, HTTPException, Body, Header
from fastapi.responses import StreamingResponse
from google import genai
from google.genai import types
from datetime import datetime
from utils import init_supabase
from models import ChatbotRequest
from routers import *
from utils import *

router = APIRouter(prefix="/api/chatbot", tags=["chatbot"])


# Init supabase admin
supabase_admin = init_supabase()


# Init Gemini
genai_client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))
tools = types.Tool(
    function_declarations=[
        create_new_medication_list_declaration,
        create_update_medication_list_declaration,
        create_delete_medication_list_declaration,
        create_new_vaccination_list_declaration,
        create_update_vaccination_list_declaration,
        create_delete_vaccination_list_declaration,
    ]
)

# ============================================================================
# Functions
# ============================================================================


async def handle_function_calls(
    payload: dict,
    client: genai.Client,
    body: ChatbotRequest,
    function_call: types.FunctionCall,
    history_content: types.Content,
):
    """
    Handle function calls from Gemini

    Args:
        function_call (FunctionCall): Function call object, including function name and arguments
        history_content (Content): The model's response content containing the function call

    Returns:
        AsyncGenerator: Response message chunks from AI chatbot
    """
    function_name = function_call.name
    args = dict(function_call.args)
    response_result = None

    if function_name == "create_new_medication_list":
        # Insert new medication list into database
        # Set default values
        if "start_date" not in args:
            args["start_date"] = datetime.now().strftime("%Y-%m-%d")

        if "frequency_time" not in args:
            args["frequency_time"] = "08:00"

        # Convert to MedicationRequest model
        med_request = MedicationRequest(**args)

        await create_medication(payload, med_request)
        response_result = {"result": "Medication added successfully"}

    elif function_name == "update_medication_list":
        # Update medication list in database
        med_id = args.pop("med_id")

        # Get existing medication
        current_med_dict = await get_medication_by_id(payload, med_id)

        # Merge new args into current data
        for key, value in args.items():
            if value is not None:
                current_med_dict[key] = value

        # Convert to MedicationRequest model
        med_request = MedicationRequest(**current_med_dict)

        # Call update function
        await update_medication(payload, med_id, med_request)
        response_result = {"result": "Medication updated successfully"}

    elif function_name == "delete_medication_list":
        # Delete medication list in database
        med_id = args.get("med_id")

        await delete_medication(payload, med_id)
        response_result = {"result": "Medication deleted successfully"}

    elif function_name == "create_new_vaccination_list":
        # Insert new vaccination list into database
        # Convert to VaccinationRequest model
        vac_request = VaccinationRequest(**args)

        await create_vaccination(payload, vac_request)
        response_result = {"result": "Vaccination added successfully"}

    elif function_name == "update_vaccination_list":
        # Update vaccination list in database
        vac_id = args.pop("vac_id")

        # Get existing vaccination
        current_vac_dict = await get_vaccination_by_id(payload, vac_id)

        # Merge new args into current data
        for key, value in args.items():
            if value is not None:
                current_vac_dict[key] = value

        # Convert to VaccinationRequest model
        vac_request = VaccinationRequest(**current_vac_dict)

        await update_vaccination(payload, vac_id, vac_request)
        response_result = {"result": "Vaccination updated successfully"}

    elif function_name == "delete_vaccination_list":
        # Delete vaccination list in database
        vac_id = args.get("vac_id")

        await delete_vaccination(payload, vac_id)
        response_result = {"result": "Vaccination deleted successfully"}

    if response_result:
        # Send result back to Gemini to get a natural response
        function_response_part = types.Part(
            function_response=types.FunctionResponse(
                name=function_name,
                response=response_result,
            )
        )

        success_response = client.models.generate_content_stream(
            model="gemini-3-flash-preview",
            contents=[
                types.Content(role="user", parts=[types.Part(text=body.message)]),
                history_content,
                types.Content(role="user", parts=[function_response_part]),
            ],
            config=config,
        )

        # Stream the response
        for chunk in success_response:
            if (
                chunk.candidates
                and chunk.candidates[0].content
                and chunk.candidates[0].content.parts
            ):
                part = chunk.candidates[0].content.parts[0]
                if part.text:
                    yield part.text


async def chatbot(payload: dict, body: ChatbotRequest):
    """
    Chat with AI chatbot, include ability to CRUD medications and vaccinations tables

    Args:
        payload (dict): Payload dictionary (contains user's information)
        body (dict): Body dictionary (contains user's information)

    Returns:
        Response message from AI chatbot
    """
    user_id = payload["sub"]

    try:
        # Call the function from Supabase SQL function
        user_info = supabase_admin.rpc(
            "get_user_data_tables", {"user_uuid": user_id}
        ).execute()

    except Exception as e:
        raise HTTPException(status_code=400, detail=f"User's info not found: {str(e)}")

    client = genai_client

    # Configure the model
    config = types.GenerateContentConfig(
        system_instruction=f"You are a knowledgeable, empathetic, and supportive Health & Wellness Assistant. Your goal is to help users improve their physical and mental well-being through sustainable lifestyle changes, education, and encouragement. You specialize in nutrition, fitness, sleep hygiene, mindfulness, and stress management. You need to read the user's info below before replying, reply should be under 200 words.\n\nUser's info: {user_info.data}",
        temperature=0.7,
        top_p=0.95,
        top_k=40,
        max_output_tokens=60000,
        tools=[tools],
    )

    # Generate response, which will decide if it needs to call a function and which function to call, and return the response
    response_stream = client.models.generate_content_stream(
        model="gemini-3-flash-preview",
        contents=body.message,
        config=config,
    )

    # Stream the response
    for chunk in response_stream:
        if (
            chunk.candidates
            and chunk.candidates[0].content
            and chunk.candidates[0].content.parts
        ):
            part = chunk.candidates[0].content.parts[0]

            # Check for function calls
            if part.function_call:
                function_call = part.function_call
                # Construct history content for the function call
                history_content = types.Content(
                    role="model", parts=[types.Part(function_call=function_call)]
                )
                async for text in handle_function_calls(
                    payload, client, body, function_call, history_content
                ):
                    yield text
                return

            if part.text:
                yield part.text


# ============================================================================
# API
# ============================================================================


@router.post("/email")
async def chat_google(
    authorization: str = Header(...), body: ChatbotRequest = Body(...)
):
    """
    Chat with AI chatbot

    Args:
        authorization (str): Authorization header (contains jwt token)
        body (dict): Body dictionary (contains user's information)

    Returns:
        Response message from AI chatbot
    """

    payload = await verify_es256_token(authorization)

    return StreamingResponse(chatbot(payload, body), media_type="text/plain")


@router.post("/google")
async def chat_google(
    authorization: str = Header(...), body: ChatbotRequest = Body(...)
):
    """
    Chat with AI chatbot

    Args:
        authorization (str): Authorization header (contains jwt token)
        body (dict): Body dictionary (contains user's information)

    Returns:
        Response message from AI chatbot
    """

    payload = await verify_hs256_token(authorization)

    return StreamingResponse(chatbot(payload, body), media_type="text/plain")
