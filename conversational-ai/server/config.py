import os
import sys

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODELS_DIR = os.path.join(BASE_DIR, "models")
TOOLS_DIR = os.path.join(BASE_DIR, "tools")
WEBUI_DIR = os.path.join(BASE_DIR, "webui")
AUDIO_DIR = os.path.join(BASE_DIR, "audio_cache")

os.makedirs(MODELS_DIR, exist_ok=True)
os.makedirs(TOOLS_DIR, exist_ok=True)
os.makedirs(AUDIO_DIR, exist_ok=True)

# llama.cpp server
LLAMA_BIN_DIR = os.path.join(TOOLS_DIR, "llama.cpp")
LLAMA_SERVER_BIN = os.path.join(LLAMA_BIN_DIR, "llama-server.exe")
LLAMA_HOST = "127.0.0.1"
LLAMA_PORT = 8080
LLAMA_URL = f"http://{LLAMA_HOST}:{LLAMA_PORT}/v1/chat/completions"
LLAMA_MODEL_NAME = "local"

# Model to download (bartowski's reliable GGUF conversions)
LLAMA_GGUF_FILENAME = "Llama-3.2-3B-Instruct-Q4_K_M.gguf"
LLAMA_GGUF_URL = (
    "https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/resolve/main/"
    "Llama-3.2-3B-Instruct-Q4_K_M.gguf"
)

# Whisper
WHISPER_MODEL = "small"          # "tiny" | "base" | "small" | "medium"
# CPU keeps the 4 GB VRAM free for llama.cpp. Set env WHISPER_DEVICE=cuda to
# use the GPU instead (requires CUDA 12.x + cuDNN 8 installed system-wide).
WHISPER_DEVICE = "cpu"
WHISPER_COMPUTE_TYPE = "int8"
try:
    WHISPER_DEVICE = os.environ.get("WHISPER_DEVICE", WHISPER_DEVICE)
    WHISPER_COMPUTE_TYPE = os.environ.get("WHISPER_COMPUTE_TYPE", WHISPER_COMPUTE_TYPE)
    WHISPER_MODEL = os.environ.get("WHISPER_MODEL", WHISPER_MODEL)
except Exception:
    pass

# Coqui TTS
TTS_MODEL = "tts_models/en/ljspeech/vits"
TTS_DEVICE = "cpu"

# System prompt / persona
SYSTEM_PROMPT = (
    "You are a friendly, helpful voice assistant running entirely on the user's "
    "local PC. Keep your answers concise, warm, and conversational. Reply in a "
    "way that sounds natural when spoken aloud. Use 2-4 sentences unless asked "
    "for detail."
)


def log(msg: str) -> None:
    print(f"[setup] {msg}", flush=True)