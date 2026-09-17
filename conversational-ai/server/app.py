import os
import threading
import time
import uuid

import imageio_ffmpeg
from flask import Flask, jsonify, request, send_from_directory

from . import config
from .llm import LLMClient
from .tts_engine import TTSEngine
from .whisper_engine import Transcriber

app = Flask(__name__, static_folder=None)
app.config["MAX_CONTENT_LENGTH"] = 32 * 1024 * 1024

transcriber = Transcriber()
tts = TTSEngine()
llm = LLMClient()

_locks = {"transcribe": threading.Lock(), "tts": threading.Lock()}

_FFMPEG = None


def _ffmpeg():
    global _FFMPEG
    if _FFMPEG is None:
        _FFMPEG = imageio_ffmpeg.get_ffmpeg_exe()
    return _FFMPEG


def _webm_to_wav(webm_bytes: bytes, out_path: str) -> str:
    src = os.path.join(config.AUDIO_DIR, "in_%s.webm" % uuid.uuid4().hex[:8])
    from io import BytesIO
    with open(src, "wb") as f:
        f.write(webm_bytes)
    import subprocess
    exe = _ffmpeg()
    r = subprocess.run([exe, "-y", "-i", src, "-ac", "1", "-ar", "16000", out_path],
                       capture_output=True, timeout=60)
    os.unlink(src)
    if r.returncode != 0:
        raise RuntimeError(r.stderr.decode("utf-8", "replace"))
    return out_path


@app.get("/")
def index():
    return send_from_directory(config.WEBUI_DIR, "index.html")


@app.get("/api/health")
def health():
    try:
        import requests
        r = requests.get(f"http://{config.LLAMA_HOST}:{config.LLAMA_PORT}/health", timeout=3)
        llm_ok = r.status_code == 200
    except Exception:
        llm_ok = False
    return jsonify({"llm": llm_ok, "whisper_loaded": transcriber._model is not None,
                    "tts_loaded": tts._tts is not None})


@app.post("/api/turn")
def turn():
    """Accept {text} or an uploaded audio blob, return AI reply + TTS audio."""
    data = request.form if request.form else request.get_json(silent=True) or {}
    user_text = data.get("text") or ""

    audio = request.files.get("audio")
    if audio is not None and audio.filename:
        wav_path = os.path.join(config.AUDIO_DIR, "in_%s.wav" % uuid.uuid4().hex[:8])
        _webm_to_wav(audio.read(), wav_path)
        with _locks["transcribe"]:
            user_text = transcriber.transcribe_file(wav_path)
        try:
            os.unlink(wav_path)
        except OSError:
            pass

    if not user_text.strip():
        return jsonify({"reply": "", "audio_url": None, "user_text": ""})

    reply = ""
    for part in llm.reply_stream(user_text):
        reply += part

    audio_name = None
    if reply.strip():
        out = os.path.join(config.AUDIO_DIR, "audio_%s.wav" % uuid.uuid4().hex[:8])
        with _locks["tts"]:
            tts.speak_to_file(reply, out)
        audio_name = os.path.basename(out)

    return jsonify({"reply": reply, "audio_url": audio_name, "user_text": user_text})


@app.post("/api/reset")
def reset():
    llm.reset()
    return jsonify({"ok": True})


@app.get("/audio/<path:name>")
def audio(name):
    return send_from_directory(config.AUDIO_DIR, name)


def main(host: str = "127.0.0.1", port: int = 5000):
    print(f"[webui] starting on http://{host}:{port}", flush=True)
    app.run(host=host, port=port, threaded=True)


if __name__ == "__main__":
    main()