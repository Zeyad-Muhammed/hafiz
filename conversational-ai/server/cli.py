import sys
import time

from . import config
from .llm import LLMClient
from .mic import MicRecorder, play_wav
from .tts_engine import TTSEngine
from .whisper_engine import Transcriber


def run_cli() -> int:
    print("=" * 60)
    print("  Local Conversational AI  (llama.cpp + Whisper + Coqui TTS)")
    print("=" * 60)
    print("  Say 'quit', 'exit', or 'goodbye' to stop.", flush=True)

    transcriber = Transcriber()
    tts = TTSEngine()
    llm = LLMClient()
    recorder = MicRecorder()

    print("[startup] loading speech models (this happens once)...", flush=True)
    t0 = time.time()
    transcriber.load()
    tts.load()
    print(f"[startup] speech models ready in {time.time()-t0:.1f}s", flush=True)

    while True:
        print("\n--- You (speak) ---", flush=True)
        wav = recorder.record_until_silence()
        if wav is None:
            print("   (no speech detected)", flush=True)
            continue
        print("   [whisper] transcribing...", flush=True)
        t0 = time.time()
        user_text = transcriber.transcribe_bytes(wav)
        print(f"You: {user_text}  ({time.time()-t0:.1f}s)", flush=True)

        low = user_text.lower()
        if any(kw in low for kw in ("quit", "exit", "goodbye", "bye")):
            print("\nGoodbye!", flush=True)
            tts.speak("Goodbye, see you next time.")
            return 0

        if not user_text.strip():
            print("   (empty transcription)", flush=True)
            continue

        print("   [llm] generating reply...", flush=True)
        t0 = time.time()
        reply = ""
        for part in llm.reply_stream(user_text):
            reply += part
            print(part, end="", flush=True)
        print(f"\n   (reply took {time.time()-t0:.1f}s)", flush=True)

        print("   [tts] synthesizing speech...", flush=True)
        t0 = time.time()
        path = tts.speak_to_file(reply)
        print(f"   (tts took {time.time()-t0:.1f}s)", flush=True)
        play_wav(path)

    return 0


if __name__ == "__main__":
    sys.exit(run_cli())