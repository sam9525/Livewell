# Define function declarations

# Medications
create_new_medication_list_declaration = {
    "name": "create_new_medication_list",
    "description": "Create a new medication list for the user in database.",
    "parameters": {
        "type": "object",
        "properties": {
            "name": {
                "type": "string",
                "description": "Name of the medication",
            },
            "dose_value": {
                "type": "integer",
                "description": "Dosage value of the medication",
            },
            "dose_unit": {
                "type": "string",
                "description": "Unit of the dosage of the medication",
            },
            "frequency_type": {
                "type": "string",
                "description": "Frequency type of the medication (Daily, Twice a day, Weekly)",
            },
            "frequency_time": {
                "type": "string",
                "description": "Time of the medication (e.g. 08:00)",
            },
            "start_date": {
                "type": "string",
                "description": "Start date of the medication (YYYY-MM-DD)",
            },
            "durations": {
                "type": "integer",
                "description": "Duration days of the medication",
            },
            "notes": {
                "type": "string",
                "description": "Notes of the medication",
            },
        },
        "required": ["name", "dose_value", "dose_unit", "frequency_type"],
    },
}

create_update_medication_list_declaration = {
    "name": "update_medication_list",
    "description": "Update an existing medication list for the user in database.",
    "parameters": {
        "type": "object",
        "properties": {
            "med_id": {
                "type": "string",
                "description": "The unique ID of the medication to update",
            },
            "name": {
                "type": "string",
                "description": "Name of the medication",
                "nullable": True,
            },
            "dose_value": {
                "type": "integer",
                "description": "Dosage value of the medication",
                "nullable": True,
            },
            "dose_unit": {
                "type": "string",
                "description": "Unit of the dosage of the medication",
                "nullable": True,
            },
            "frequency_type": {
                "type": "string",
                "description": "Frequency type of the medication (Daily, Twice a day, Weekly)",
                "nullable": True,
            },
            "frequency_time": {
                "type": "string",
                "description": "Time of the medication (e.g. 08:00)",
                "nullable": True,
            },
            "start_date": {
                "type": "string",
                "description": "Start date of the medication (YYYY-MM-DD)",
                "nullable": True,
            },
            "durations": {
                "type": "integer",
                "description": "Duration days of the medication",
                "nullable": True,
            },
            "notes": {
                "type": "string",
                "description": "Notes of the medication",
                "nullable": True,
            },
        },
        "required": ["med_id"],
    },
}

create_delete_medication_list_declaration = {
    "name": "delete_medication_list",
    "description": "Delete an existing medication list for the user in database.",
    "parameters": {
        "type": "object",
        "properties": {
            "med_id": {
                "type": "string",
                "description": "The unique ID of the medication to delete",
            },
        },
        "required": ["med_id"],
    },
}

# Vaccinations
create_new_vaccination_list_declaration = {
    "name": "create_new_vaccination_list",
    "description": "Create a new vaccination record for the user in database.",
    "parameters": {
        "type": "object",
        "properties": {
            "name": {
                "type": "string",
                "description": "Name of the vaccination",
            },
            "dose_date": {
                "type": "string",
                "description": "Date of the vaccination (YYYY-MM-DD)",
            },
            "next_dose_date": {
                "type": "string",
                "description": "Date of the next dose (YYYY-MM-DD)",
            },
            "location": {
                "type": "string",
                "description": "Location where the vaccination was administered",
            },
            "notes": {
                "type": "string",
                "description": "Notes of the vaccination",
            },
        },
        "required": ["name", "dose_date"],
    },
}

create_update_vaccination_list_declaration = {
    "name": "update_vaccination_list",
    "description": "Update an existing vaccination record for the user in database.",
    "parameters": {
        "type": "object",
        "properties": {
            "vac_id": {
                "type": "string",
                "description": "The unique ID of the vaccination to update",
            },
            "name": {
                "type": "string",
                "description": "Name of the vaccination",
                "nullable": True,
            },
            "dose_date": {
                "type": "string",
                "description": "Date of the vaccination (YYYY-MM-DD)",
                "nullable": True,
            },
            "next_dose_date": {
                "type": "string",
                "description": "Date of the next dose (YYYY-MM-DD)",
                "nullable": True,
            },
            "location": {
                "type": "string",
                "description": "Location where the vaccination was administered",
                "nullable": True,
            },
            "notes": {
                "type": "string",
                "description": "Notes of the vaccination",
                "nullable": True,
            },
        },
        "required": ["vac_id"],
    },
}

create_delete_vaccination_list_declaration = {
    "name": "delete_vaccination_list",
    "description": "Delete an existing vaccination record for the user in database.",
    "parameters": {
        "type": "object",
        "properties": {
            "vac_id": {
                "type": "string",
                "description": "The unique ID of the vaccination to delete",
            },
        },
        "required": ["vac_id"],
    },
}
