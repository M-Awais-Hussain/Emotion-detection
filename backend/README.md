# Emotion Eye Backend

This FastAPI backend provides endpoints for emotion detection, chat responses, and contact emails.

## Quick Start

### Prerequisites
- Python 3.9 or higher (tested on Python 3.13)
- pip package manager

### Running the Server

**Option 1: Using Python script (Recommended)**
```bash
python setup_and_run.py
```

**Option 2: Using batch script (Windows)**
```bash
cd backend
.\start_server.bat
```

**Option 3: Manual setup**
```bash
cd backend
python -m venv venv
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate

pip install -r requirements.txt
python main.py
```

Server will be available at:
- **API**: http://localhost:8000
- **Documentation**: http://localhost:8000/docs

## API Issues & Troubleshooting

### Issue: Backend API Connection Error
If your Flutter app shows "Backend API failed" messages:

1. **Check if server is running**
   - Visit http://localhost:8000/docs in your browser
   - If it doesn't load, the server isn't running

2. **Start the server**
   - Run `python setup_and_run.py` in the backend directory
   - Or run `.\start_server.bat` on Windows

3. **Check the API URL**
   - For local development: `http://localhost:8000` (web/iOS simulator)
   - For Android Emulator: `http://10.0.2.2:8000`
   - For physical device: `http://YOUR_COMPUTER_IP:8000` (e.g., `http://192.168.1.20:8000`)
   - Update `lib/config/api_config.dart` if needed

4. **Check Python dependencies**
   - If dependencies fail to install, ensure you have a C compiler:
     - Windows: Install Microsoft Visual C++ Build Tools
     - macOS: Install Xcode Command Line Tools (`xcode-select --install`)
     - Linux: `sudo apt-get install build-essential`

5. **Check for errors in terminal**
   - Look for error messages in the server terminal
   - Make sure `requirements.txt` has been installed successfully

### Fallback Responses
The Flutter app has built-in fallback responses if the backend API is unavailable. You'll see emotion-specific wellness responses even if the server isn't running.

## Configuration

Copy `.env.example` to `.env` and fill in the values, especially:

```dotenv
GEMINI_API_KEY=your_api_key_here
```

The backend uses the `GEMINI_API_KEY` to contact the Google Generative Language (Gemini) API. Without a valid key, the service falls back to canned responses.

Steps to configure:

1. Copy `.env.example` to `.env` (already done) or edit `backend/.env` directly.
2. Replace `GEMINI_API_KEY=your_api_key_here` with your actual API key.
3. Fill in any other real credentials (SMTP server, email JS IDs, etc.) if you intend to use the contact endpoint.
4. **Restart the backend** so `python-dotenv` re-reads the updated `.env`. For example:

   ```bash
   cd backend
   python setup_and_run.py
   ```

   or use the existing `start_server.bat`/`start_server.sh` scripts.

Other environment variables (SMTP settings, model path, etc.) are also defined in `.env.example`.

## Running

1. **Install dependencies** (preferably inside a virtual environment):

   ```bash
   pip install -r requirements.txt
   ```

2. **Start the server**. If `uvicorn` isn't on your PATH you can invoke it via Python's `-m` switch:

   ```bash
   # from the backend/ directory
   python -m uvicorn main:app --reload
   ```

   On Windows PowerShell you may need to use `python` explicitly rather than `uvicorn`.

   Alternatively you can use the provided scripts:

   ```powershell
   .\start_server.bat    # Windows
   ./start_server.sh      # macOS/Linux
   ```

Make sure to set the environment variables before starting the server.
