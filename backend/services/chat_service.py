"""
Chat Service
Handles AI chat functionality using Gemini API
"""

import os
import asyncio
import httpx  # type: ignore[import]
from typing import List, Dict, Optional
from pathlib import Path
from dotenv import load_dotenv

# Load environment variables from .env file
_ENV_PATH = Path(__file__).resolve().parents[1] / ".env"
load_dotenv(dotenv_path=_ENV_PATH)

def _safe_print(message: str) -> None:
    """
    Print without crashing on Windows consoles that can't encode Unicode.
    """
    try:
        print(message)
    except UnicodeEncodeError:
        print(message.encode("ascii", errors="backslashreplace").decode("ascii"))


class ChatService:
    """Service for AI chat functionality"""
    
    def __init__(self):
        """Initialize chat service"""
        # Read API key from standard environment variable configured in .env
        self.api_key = os.getenv("GEMINI_API_KEY", "")
        self.model = os.getenv("GEMINI_MODEL", "gemini-2.0-flash")
        
        # API endpoints to try (in order of preference)
        self.api_endpoints = [
            # Prefer stable, commonly-available models for generateContent.
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent",
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent",
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-latest:generateContent",
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent",
        ]
        
        if not self.api_key:
            # Provide a more actionable warning and mention .env
            _safe_print("Warning: GEMINI_API_KEY not set. Chat service will use fallback responses.")
            _safe_print("  -> Add your key to a .env file or export GEMINI_API_KEY in your environment to enable real AI responses.")

    def _build_contents(
        self,
        message: str,
        detected_emotion: str,
        conversation_history: List[Dict],
    ) -> List[Dict]:
        """
        Build Gemini 'contents' array using roles + parts.
        """
        system_prefix = self._build_prompt("", detected_emotion, conversation_history).rstrip()
        # Remove the trailing "User:"/"Assistant:" structure when message is empty.
        # We'll send system_prefix as part of the user's first message for compatibility.
        system_text = system_prefix

        contents: List[Dict] = []

        # Provide context as first user content (compatible with both SDK + REST).
        contents.append(
            {
                "role": "user",
                "parts": [{"text": f"{system_text}\n\nUser: {message}\nAssistant:"}],
            }
        )

        return contents
    
    def _build_prompt(
        self, 
        message: str, 
        detected_emotion: str, 
        conversation_history: List[Dict]
    ) -> str:
        """
        Build a comprehensive prompt with all context
        
        Args:
            message: Current user message
            detected_emotion: Detected emotion from user
            conversation_history: Previous conversation messages
        
        Returns:
            Complete prompt string
        """
        prompt_parts = []
        
        # System instructions
        prompt_parts.append("You are an intelligent, empathetic companion for the Emotion Detection app.")
        prompt_parts.append("This app uses a camera to detect emotions, tracks study performance, and offers mood-boosting games and activities.")
        prompt_parts.append(f"The user's current detected emotion is: {detected_emotion}.")
        prompt_parts.append("")
        prompt_parts.append("Guidelines:")
        prompt_parts.append("- Tailor your advice specifically to the features of this app (e.g., suggest the study tracker if they need focus, or play games if they need a boost).")
        prompt_parts.append("- Acknowledge their emotional state and validate their feelings.")
        prompt_parts.append("- Provide empathetic, helpful, and encouraging responses.")
        prompt_parts.append("- Be warm, understanding, and non-judgmental.")
        prompt_parts.append("- Keep responses concise (2-3 sentences) and conversational.")
        prompt_parts.append("")
        
        # Add conversation history
        if conversation_history:
            prompt_parts.append("Previous conversation:")
            for msg in conversation_history[-6:]:  # Last 6 messages
                role = msg.get('role', 'user')
                text = msg.get('text', '')
                if role == 'user':
                    prompt_parts.append(f"User: {text}")
                elif role == 'assistant':
                    prompt_parts.append(f"Assistant: {text}")
            prompt_parts.append("")
        
        # Add current message
        prompt_parts.append(f"User: {message}")
        prompt_parts.append("Assistant:")
        
        return "\n".join(prompt_parts)
    
    async def get_response(
        self, 
        message: str, 
        conversation_history: Optional[List[Dict]] = None,
        detected_emotion: str = "neutral"
    ) -> Dict[str, any]:
        """
        Get AI response to user message
        
        Args:
            message: User message
            conversation_history: Previous conversation
            detected_emotion: Detected emotion
        
        Returns:
            Response dictionary
        """
        if conversation_history is None:
            conversation_history = []
        
        try:
            if self.api_key:
                # Use Gemini API
                return await self._get_gemini_response(message, conversation_history, detected_emotion)
            else:
                # Fallback response
                return self._get_fallback_response(message, detected_emotion)
        
        except Exception as e:
            _safe_print(f"Error in chat service: {e}")
            # If Gemini is configured but unavailable (quota, billing, etc.),
            # return a clear message instead of the generic fallback text.
            if self.api_key:
                return {
                    "response": f"Gemini API is unavailable right now: {str(e)}",
                    "emotion": detected_emotion,
                }
            return self._get_fallback_response(message, detected_emotion)
    
    async def _get_gemini_response(
        self, 
        message: str, 
        conversation_history: List[Dict],
        detected_emotion: str
    ) -> Dict[str, any]:
        """Get response from Gemini API"""
        contents = self._build_contents(message, detected_emotion, conversation_history)
        
        _safe_print("Using Gemini API (GEMINI_API_KEY loaded).")
        _safe_print(f"Preferred model: {self.model}")

        # 1) Try official Python SDK if installed.
        try:
            from google import genai  # type: ignore

            client = genai.Client(api_key=self.api_key)

            def _sdk_call():
                return client.models.generate_content(
                    model=self.model,
                    contents=contents,
                    config={
                        "temperature": 0.7,
                        "topK": 40,
                        "topP": 0.95,
                        "maxOutputTokens": 1024,
                    },
                )

            sdk_response = await asyncio.to_thread(_sdk_call)
            sdk_text = getattr(sdk_response, "text", None)
            if sdk_text and str(sdk_text).strip():
                _safe_print("SUCCESS! Got AI response from Gemini SDK.")
                return {"response": str(sdk_text).strip(), "emotion": detected_emotion}
            _safe_print("Gemini SDK returned no text; falling back to REST endpoints.")
        except Exception as e:
            # If SDK isn't installed or fails, fall back to REST implementation below.
            _safe_print(f"Gemini SDK unavailable or failed: {e}. Falling back to REST endpoints.")

        # 2) REST fallback (tries multiple model endpoints)
        _safe_print(f"Trying {len(self.api_endpoints)} REST endpoints for Gemini API")
        
        # Try each endpoint
        for idx, api_url in enumerate(self.api_endpoints, 1):
            try:
                model_name = api_url.split('models/')[1].split(':')[0]
                _safe_print(f"  [{idx}/{len(self.api_endpoints)}] Trying {model_name}...")
                async with httpx.AsyncClient(timeout=30.0) as client:
                    response = await client.post(
                        f"{api_url}?key={self.api_key}",
                        json={
                            "contents": contents,
                            "generationConfig": {
                                "temperature": 0.7,
                                "topK": 40,
                                "topP": 0.95,
                                "maxOutputTokens": 1024,
                            }
                        },
                        headers={"Content-Type": "application/json"}
                    )
                    
                    if response.status_code == 200:
                        data = response.json()
                        
                        if "candidates" in data and len(data["candidates"]) > 0:
                            candidate = data["candidates"][0]
                            if "content" in candidate and "parts" in candidate["content"]:
                                parts = candidate["content"]["parts"]
                                if parts and len(parts) > 0:
                                    ai_response = parts[0].get("text", "")
                                    if ai_response:
                                        _safe_print(f"SUCCESS! Got AI response from {model_name}")
                                        return {
                                            "response": ai_response.strip(),
                                            "emotion": detected_emotion
                                        }
                        
                        # If we got 200 but no valid response, try next endpoint
                        _safe_print(f"No usable candidates returned from {model_name}; trying next model.")
                        continue
                    
                    elif response.status_code in [401, 403]:
                        raise Exception("Invalid API key. Please check your GEMINI_API_KEY.")
                    elif response.status_code == 429:
                        # Surface quota/rate-limit issues clearly instead of silently falling back.
                        try:
                            err = response.json().get("error", {})
                            msg = err.get("message", "Quota/rate limit exceeded.")
                        except Exception:
                            msg = "Quota/rate limit exceeded."
                        raise Exception(f"Gemini quota/rate limit exceeded: {msg}")
                    elif response.status_code == 400:
                        # Often indicates missing/invalid API key or bad request payload
                        _safe_print(f"Bad request ({response.status_code}).")
                        continue
                    else:
                        # Try next endpoint for other errors
                        error_text = response.text[:500] if response.text else "No response body"
                        _safe_print(f"API error {response.status_code} (endpoint: {api_url.split('models/')[1].split(':')[0]}): {error_text}")
                        lastError = Exception(f'API error {response.status_code}')
                        continue
            
            except httpx.TimeoutException:
                if api_url == self.api_endpoints[-1]:
                    raise Exception("Connection timeout. Please check your internet connection.")
                continue
            except Exception as e:
                if "API key" in str(e) or "401" in str(e) or "403" in str(e):
                    raise
                if "quota" in str(e).lower() or "rate limit" in str(e).lower() or "RESOURCE_EXHAUSTED" in str(e):
                    raise
                if api_url == self.api_endpoints[-1]:
                    raise
                continue
        
        # If all endpoints failed, return fallback
        return self._get_fallback_response(message, detected_emotion)
    
    def _map_emotion_to_category(self, emotion: str) -> str:
        """Map all emotions to main categories (matching project's emotion mapping)"""
        emotion_lower = emotion.lower()
        
        # Direct matches
        if emotion_lower in ['happy', 'surprise']:
            return 'happy'
        if emotion_lower == 'sad':
            return 'sad'
        if emotion_lower in ['angry', 'disgust', 'contempt']:
            return 'angry'
        if emotion_lower in ['anxious', 'fear', 'stressed']:
            return 'anxious'
        if emotion_lower == 'neutral':
            return 'neutral'
        
        # Default to neutral for unknown emotions
        return 'neutral'
    
    def _get_fallback_response(self, message: str, detected_emotion: str) -> Dict[str, any]:
        """Fallback response when API is unavailable - supports all emotions in the project"""
        # Map emotion to category
        mapped_emotion = self._map_emotion_to_category(detected_emotion)
        
        responses = {
            "happy": "Great to hear you're feeling good! 😄 Keep up the positive energy. Is there anything specific you'd like to talk about or work on? I'm here to support you. 💙",
            "sad": "I understand you're feeling down. 😢 Remember, it's okay to feel this way. Would you like to try some mood-boosting activities? I'm here to support you through this. 💙",
            "angry": "I can see you're feeling frustrated or angry. 😠 That's completely valid. Let's work through this together. Taking deep breaths can help - try breathing in for 4 counts, holding for 4, and breathing out for 4. Would you like to try a breathing exercise or talk about what's making you feel this way? 💙",
            "anxious": "It sounds like you're feeling anxious or worried. 😰 Try grounding yourself by focusing on your breathing. Name 5 things you can see, 4 things you can touch, 3 things you can hear, 2 things you can smell, and 1 thing you can taste. I'm here to help you feel more calm and centered. 💙",
            "neutral": "I'm here to listen and support you. 😐 How can I help you today? Feel free to share what's on your mind. This is a great time for reflection and self-care. 💙",
            "surprise": "Surprise! 😲 Your brain is learning and adapting. This unexpected moment can be an opportunity for growth. Embrace new experiences and see where they lead you. 💙",
            "fear": "I understand you're feeling afraid or scared. 😨 Fear is a natural response that keeps us safe. Try grounding techniques: name 5 things you see, 4 you can touch, 3 you hear, 2 you smell, and 1 you taste. I'm here to help you feel more secure. 💙",
            "disgust": "I sense you're feeling disgusted or repulsed. 🤢 This feeling often signals something doesn't align with your values. Focus on what matters to you and shift your attention to something positive. I'm here to help. 💙",
            "contempt": "I notice you might be feeling contempt or disdain. 😏 This can create distance in relationships. Try practicing empathy - consider the other person's perspective. Everyone has their struggles. Let's work on understanding together. 💙",
            "stressed": "You're feeling stressed or overwhelmed. 😵 That's completely understandable. Let's prioritize what matters most right now. Take intentional breaks, practice deep breathing, and remember to be kind to yourself. I'm here to support you. 💙",
        }
        
        response = responses.get(mapped_emotion, responses["neutral"])
        
        return {
            "response": response,
            "emotion": detected_emotion
        }
