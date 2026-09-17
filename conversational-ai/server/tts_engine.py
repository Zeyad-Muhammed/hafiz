import os
import shutil

import soundfile as sf

from . import config


class TTSEngine:
    def __init__(self, device: str = None):
        self.device = device or config.TTS_DEVICE
        self._tts = None

    def load(self) -> None:
        if self._tts is None:
            print(f"[tts] loading Coqui model '{config.TTS_MODEL}' on {self.device} (first run downloads voice files)...", flush=True)
            from TTS.api import TTS

            self._tts = TTS(model_name=config.TTS_MODEL, progress_bar=False)
            self._tts.to(self.device)

    def speak_to_file(self, text: str, out_path: str = None) -> str:
        self.load()
        out_path = out_path or os.path.join(config.AUDIO_DIR, "reply.wav")
        os.makedirs(os.path.dirname(out_path), exist_ok=True)
        # Coqui saves at 22050 Hz; write a proper WAV for playback
        tmp = out_path + ".tmp"
        self._tts.tts_to_file(text=text, file_path=tmp)
        data, sr = sf.read(tmp)
        sf.write(out_path, data, sr, subtype="PCM_16")
        if os.path.exists(tmp):
            os.unlink(tmp)
        return out_path

    def speak(self, text: str) -> None:
        path = self.speak_to_file(text)
        import winsound
        winsound.PlaySound(path, winsound.SND_FILENAME | winsound.SND_NODEFAULT)