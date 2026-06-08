"""
Emotion Detection Service
Handles emotion detection from facial images using the trained model
"""

# Try to import ML dependencies, but make them optional
try:
    import numpy as np
    HAS_NUMPY = True
except ImportError:
    HAS_NUMPY = False
    np = None

try:
    import cv2
    HAS_CV2 = True
except ImportError:
    HAS_CV2 = False
    cv2 = None

try:
    import tensorflow as tf
    from tensorflow import keras
    HAS_TENSORFLOW = True
except ImportError:
    HAS_TENSORFLOW = False
    tf = None
    keras = None

from io import BytesIO
try:
    from PIL import Image
except ImportError:
    Image = None
import os
from typing import Dict

class EmotionDetectionService:
    """Service for detecting emotions from facial images"""
    
    def __init__(self, model_path: str = None):
        """
        Initialize emotion detection service
        
        Args:
            model_path: Path to the H5 model file
        """
        if model_path is None:
            # Default path - adjust based on your project structure
            model_path = os.path.join(os.path.dirname(__file__), "../../emotion_detection/face_model.h5")
        
        self.model_path = model_path
        self.model = None
        self.emotion_labels = ['angry', 'disgust', 'fear', 'happy', 'neutral', 'sad', 'surprise']
        
        # Check if dependencies are available
        if not HAS_TENSORFLOW or not HAS_CV2 or not HAS_NUMPY:
            print("Warning: Emotion detection dependencies not installed")
            print("   Install with: pip install tensorflow opencv-python numpy")
            print("   Using fallback emotion detection")
        else:
            self._load_model()
    
    def _load_model(self):
        """Load the emotion detection model"""
        if not HAS_TENSORFLOW:
            print("TensorFlow not installed - using fallback emotion detection")
            return
            
        try:
            if os.path.exists(self.model_path):
                print(f"Loading model from {self.model_path}")
                self.model = keras.models.load_model(self.model_path)
                print("Model loaded successfully")
            else:
                print(f"Warning: Model file not found at {self.model_path}")
                print("Using fallback emotion detection")
                self.model = None
        except Exception as e:
            print(f"Error loading model: {e}")
            print("Using fallback emotion detection")
            self.model = None
    
    def _preprocess_image(self, image_data: bytes) -> "np.ndarray":
        """
        Preprocess image for model input
        
        Args:
            image_data: Raw image bytes
        
        Returns:
            Preprocessed image array
        """
        if not HAS_CV2 or not HAS_NUMPY:
            raise ValueError("OpenCV and NumPy required for image preprocessing. Install with: pip install opencv-python numpy")
        
        try:
            # Convert bytes to numpy array using OpenCV
            nparr = np.frombuffer(image_data, np.uint8)
            image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            
            if image is None:
                # Try with PIL as fallback
                if Image is not None:
                    pil_image = Image.open(BytesIO(image_data))
                    if pil_image.mode != 'RGB':
                        pil_image = pil_image.convert('RGB')
                    image_array = np.array(pil_image)
                    image = cv2.cvtColor(image_array, cv2.COLOR_RGB2BGR)
            
            if image is None:
                raise ValueError("Could not decode image")
            
            # Convert to grayscale for emotion detection
            if len(image.shape) == 3:
                gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
            else:
                gray = image
            
            # Detect and crop face if possible
            try:
                face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
                faces = face_cascade.detectMultiScale(gray, 1.3, 5)
                
                if len(faces) > 0:
                    # Crop to face region
                    x, y, w, h = faces[0]
                    # Add some padding
                    padding = 10
                    x = max(0, x - padding)
                    y = max(0, y - padding)
                    w = min(gray.shape[1] - x, w + 2 * padding)
                    h = min(gray.shape[0] - y, h + 2 * padding)
                    gray = gray[y:y+h, x:x+w]
            except:
                # If face detection fails, use whole image
                pass
            
            # Resize to model input size (typically 48x48 or 64x64)
            # Adjust based on your model's input size
            resized = cv2.resize(gray, (48, 48))
            
            # Normalize pixel values to [0, 1]
            normalized = resized.astype('float32') / 255.0
            
            # Reshape for model input (add batch and channel dimensions)
            # Shape: (1, 48, 48, 1) for grayscale
            reshaped = normalized.reshape(1, 48, 48, 1)
            
            return reshaped
        
        except Exception as e:
            raise ValueError(f"Error preprocessing image: {str(e)}")
    
    def _detect_face(self, image_data: bytes) -> tuple:
        """
        Detect face in image using OpenCV Haar Cascade
        
        Args:
            image_data: Raw image bytes
        
        Returns:
            Tuple of (face_detected: bool, face_roi: np.ndarray or None)
        """
        if not HAS_CV2 or not HAS_NUMPY:
            print("⚠️  OpenCV or NumPy not available - using fallback emotion detection")
            return True, None  # Return True to allow fallback
        
        try:
            # Convert bytes to numpy array
            nparr = np.frombuffer(image_data, np.uint8)
            image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            
            if image is None:
                # Try alternative decoding
                try:
                    from PIL import Image
                    pil_image = Image.open(BytesIO(image_data))
                    if pil_image.mode != 'RGB':
                        pil_image = pil_image.convert('RGB')
                    image_array = np.array(pil_image)
                    image = cv2.cvtColor(image_array, cv2.COLOR_RGB2BGR)
                except:
                    print("Error: Could not decode image")
                    return False, None
            
            if image is None:
                return False, None
            
            # Convert to grayscale
            if len(image.shape) == 3:
                gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
            else:
                gray = image
            
            # Load face cascade
            try:
                cascade_path = cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
                face_cascade = cv2.CascadeClassifier(cascade_path)
                
                if face_cascade.empty():
                    print("Warning: Face cascade not loaded, using whole image")
                    return True, gray
                
                # Detect faces with improved parameters
                faces = face_cascade.detectMultiScale(
                    gray, 
                    scaleFactor=1.1,
                    minNeighbors=5,
                    minSize=(30, 30),
                    flags=cv2.CASCADE_SCALE_IMAGE
                )
                
                if len(faces) > 0:
                    # Use the largest face
                    largest_face = max(faces, key=lambda rect: rect[2] * rect[3])
                    x, y, w, h = largest_face
                    face_roi = gray[y:y+h, x:x+w]
                    return True, face_roi
                else:
                    print("No face detected in image")
                    return False, None
            except Exception as e:
                print(f"Face detection error: {e}, using whole image")
                # If cascade fails, use the whole image (still try to detect emotion)
                return True, gray
        
        except Exception as e:
            print(f"Error in face detection: {e}")
            import traceback
            traceback.print_exc()
            return False, None
    
    def _map_emotion(self, emotion: str) -> str:
        """
        Map 7 model emotions to 5 app emotions
        
        Args:
            emotion: Detected emotion from model
        
        Returns:
            Mapped emotion for app
        """
        emotion_lower = emotion.lower()
        
        mapping = {
            'angry': 'angry',
            'happy': 'happy',
            'sad': 'sad',
            'neutral': 'neutral',
            'disgusted': 'disgust',
            'disgust': 'disgust',
            'fear': 'fear',
            'surprise': 'surprise'
        }
        
        return mapping.get(emotion_lower, 'neutral')
    
    async def detect_emotion(self, image_data: bytes) -> Dict[str, any]:
        """
        Detect emotion from image
        
        Args:
            image_data: Raw image bytes
        
        Returns:
            Dictionary with emotion and confidence
        """
        try:
            # Detect face first
            face_detected, face_image = self._detect_face(image_data)
            
            if not face_detected:
                return {
                    "emotion": "none",
                    "confidence": 0.0,
                    "message": "No face detected in the image"
                }
            
            # If model is loaded, use it
            if self.model is not None:
                try:
                    # Preprocess image
                    processed_image = self._preprocess_image(image_data)
                    
                    # Predict emotion
                    predictions = self.model.predict(processed_image, verbose=0)
                    
                    # Get emotion with highest probability
                    emotion_index = np.argmax(predictions[0])
                    emotion = self.emotion_labels[emotion_index]
                    confidence = float(predictions[0][emotion_index])
                    
                    # Map to app emotions
                    mapped_emotion = self._map_emotion(emotion)
                    
                    return {
                        "emotion": mapped_emotion,
                        "confidence": confidence,
                        "raw_emotion": emotion,
                        "all_predictions": {
                            label: float(pred) 
                            for label, pred in zip(self.emotion_labels, predictions[0])
                        }
                    }
                except Exception as e:
                    print(f"Error in model prediction: {e}")
                    import traceback
                    traceback.print_exc()
                    # Fallback to simple detection
                    return {
                        "emotion": "neutral",
                        "confidence": 0.5,
                        "message": f"Model prediction error: {str(e)}"
                    }
            else:
                # Fallback: return neutral if model not available
                print("Warning: Model not loaded, returning neutral")
                return {
                    "emotion": "neutral",
                    "confidence": 0.5,
                    "message": "Model not available, using fallback"
                }
        
        except Exception as e:
            import traceback
            traceback.print_exc()
            raise Exception(f"Error detecting emotion: {str(e)}")

