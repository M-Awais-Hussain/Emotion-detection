"""
Emotion Eye Backend API
FastAPI server for emotion detection and related services
"""

from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import Optional, List
import uvicorn
import os
from pathlib import Path
from dotenv import load_dotenv

from services.emotion_detection import EmotionDetectionService
from services.chat_service import ChatService
from services.email_service import EmailService

# Load environment variables
_ENV_PATH = Path(__file__).resolve().parent / ".env"
load_dotenv(dotenv_path=_ENV_PATH)

# Initialize FastAPI app
app = FastAPI(
    title="Emotion Eye API",
    description="Backend API for Emotion Eye mobile application",
    version="1.0.0"
)

# CORS middleware - allow requests from Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your Flutter app's origin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize services
emotion_service = EmotionDetectionService()
chat_service = ChatService()
email_service = EmailService()


# Request/Response models
class ChatRequest(BaseModel):
    message: str
    conversation_history: Optional[List[dict]] = []
    detected_emotion: Optional[str] = "neutral"


class ChatResponse(BaseModel):
    response: str
    emotion: Optional[str] = None


class ContactRequest(BaseModel):
    name: str
    subject: str
    message: str


class HealthResponse(BaseModel):
    status: str
    message: str


# Health check endpoint
@app.get("/", response_model=HealthResponse)
async def root():
    return {"status": "ok", "message": "Emotion Eye API is running"}


@app.get("/health", response_model=HealthResponse)
async def health_check():
    return {"status": "ok", "message": "API is healthy"}


# Emotion detection endpoint
@app.post("/api/v1/predict")
async def predict_emotion(file: UploadFile = File(...)):
    """
    Predict emotion from uploaded image
    
    Args:
        file: Image file (JPEG, PNG, etc.)
    
    Returns:
        JSON with detected emotion
    """
    try:
        # Validate file type
        if not file.content_type.startswith('image/'):
            raise HTTPException(status_code=400, detail="File must be an image")
        
        # Read image data
        image_data = await file.read()
        
        # Detect emotion
        result = await emotion_service.detect_emotion(image_data)
        
        return JSONResponse(content=result)
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing image: {str(e)}")


# Chat endpoint
@app.post("/api/v1/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """
    Chat with AI assistant
    
    Args:
        request: Chat request with message and optional history
    
    Returns:
        AI response
    """
    try:
        response = await chat_service.get_response(
            message=request.message,
            conversation_history=request.conversation_history,
            detected_emotion=request.detected_emotion
        )
        
        return ChatResponse(
            response=response["response"],
            emotion=response.get("emotion")
        )
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error in chat service: {str(e)}")


# Contact/Email endpoint
@app.post("/api/v1/contact")
async def send_contact_email(request: ContactRequest):
    """
    Send contact email
    
    Args:
        request: Contact form data
    
    Returns:
        Success message
    """
    try:
        result = await email_service.send_email(
            name=request.name,
            subject=request.subject,
            message=request.message
        )
        
        if result["success"]:
            return JSONResponse(
                content={"status": "success", "message": "Email sent successfully"},
                status_code=200
            )
        else:
            raise HTTPException(status_code=500, detail=result.get("error", "Failed to send email"))
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error sending email: {str(e)}")


if __name__ == "__main__":
    port = int(os.getenv("PORT", 8000))
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=port,
        reload=True
    )

