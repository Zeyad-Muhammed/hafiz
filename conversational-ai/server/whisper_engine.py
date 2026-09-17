from faster_whisper import WhisperModel

from . import config


class Transcriber:
    def __init__(self, model_name: str = None, device: str = None, compute_type: str = None):
        self.model_name = model_name or config.WHISPER_MODEL
        self.device = device or config.WHISPER_DEVICE
        self.compute_type = compute_type or config.WHISPER_COMPUTE_TYPE
        self._model = None

    def load(self) -> None:
        if self._model is None:
            print(f"[whisper] loading '{self.model_name}' on {self.device} (compute={self.compute_type})...", flush=True)
            self._model = WhisperModel(self.model_name, device=self.device, compute_type=self.compute_type)

    def transcribe_file(self, audio_path: str) -> str:
        self.load()
        segments, info = self._model.transcribe(
            audio_path, beam_size=5, vad_filter=True,
            condition_on_previous_text=False,
        )
        text = " ".join(seg.text.strip() for seg in segments).strip()
        return text

    def transcribe_bytes(self, wav_bytes: bytes) -> str:
        import tempfile

        self.load()
        with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as f:
            f.write(wav_bytes)
            tmp = f.name
        try:
            return self.transcribe_file(tmp)
        finally:
            import os
            os.unlink(tmp)