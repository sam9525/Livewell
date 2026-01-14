# Livewell

Livewell is a comprehensive health management platform designed to help elderly users track their well-being, manage medications, and receive AI-driven health insights. The project consists of a cross-platform mobile application and a robust backend API.

### Download

[Download Livewell](https://drive.google.com/file/d/1KAMqixwfhZejck1s2U3tKJJP8qX1ikYe/view?usp=sharing)

## System Architecture

The Livewell ecosystem is built on a modern tech stack:

- **Frontend**: Flutter (Mobile App)
- **Backend**: Python FastAPI
- **Database & Auth**: Supabase & Firebase
- **AI Engine**: Google Gemini

## Implemented Features

### 1. User Authentication & Profile

- **Google Sign-In**: Secure authentication using Google credentials.
- **Profile Management**: users can manage personal details, health stats, and preferences.
- **Security**: JWT-based session management and secure API communication.

### 2. Health Tracking (Tracking Data)

- **Activity Monitoring**: Tracks daily steps and physical activity.
- **Health Metrics**: Logs and visualizes health data over time.
- **Device Integration**: Supports reading data from device sensors (e.g., Pedometer).

### 3. AI Smart Assistant (Chatbot)

- **Gemini-Powered**: A conversational interface powered by Google's Gemini model.
- **Streaming Responses**: Real-time, typing-like responses for a natural user experience.
- **Medication & Vaccination Management**: The chatbot has access to the user's health context (medications, vaccinations) to help user to manage them.

### 4. Goal Recommendations

- **AI Recommendations**: Generates personalized weekly health goals (e.g., "steps_target: 7000") based on user profile and activity.
- **Weekly Scheduling**: Automated jobs generate new recommendations every Monday.
- **Status Tracking**: Users can accept, track, and complete recommended goals.

### 5. Medication & Vaccination Management

- **Digital Medicine Cabinet**: Users can add and track their current medications.
- **Vaccination Records**: Digital log for vaccination history.
- **Reminders**: Automated notifications to ensure missing doses.

### 6. Local Health Resources

- **Location-Based Search**: Finds nearby activities and health facilities.
- **Service Integration**: Provides details on services available at local health facilities.

### 7. Notifications System

- **FCM Integration**: Uses Firebase Cloud Messaging for reliable push notifications.
- **Smart Alerts**: Reminders for medications, appointments, and goal achievements.
- **Background Handling**: Robust handling of notifications even when the app is simpler.

## Technology Stack

### Frontend (Flutter)

- **State Management**: Provider
- **UI Components**: Material Design, Custom Health Widgets, Charts (`fl_chart`)
- **Services**: `http`, `flutter_local_notifications`, `geolocator`, `shared_preferences`

### Backend (FastAPI)

- **API Framework**: FastAPI with Pydantic models
- **Task Scheduling**: APScheduler for background jobs (cron)
- **AI Integration**: `google.generativeai`
- **Data Layer**: `supabase` (PostgreSQL)
