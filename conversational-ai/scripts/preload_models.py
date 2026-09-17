import sys

print("[preload] downloading/fetching Whisper model...", flush=True)
from faster_whisper import WhisperModel
m = WhisperModel("small", device="cpu", compute_type="int8")
print("[preload] Whisper model ready.", flush=True)

print("[preload] downloading/fetching Coqui TTS voice... (pulling PyTorch + voice files)", flush=True)
from TTS.api import TTS
t = TTS(model_name="tts_models/en/ljspeech/vits", progress_bar=False)
print("[preload] Coqui TTS voice ready.", flush=True)
print("[preload] DONE", flush=True)