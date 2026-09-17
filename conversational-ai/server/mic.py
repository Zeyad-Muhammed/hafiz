import io
import os
import tempfile
import wave

import numpy as np
import sounddevice as sd


class MicRecorder:
    def __init__(self, sample_rate: int = 16000):
        self.sample_rate = sample_rate
        self.silence_threshold = 0.012

    @staticmethod
    def list_devices():
        return sd.query_devices()

    def record_until_silence(self, silence_seconds: float = 1.2, max_seconds: float = 30.0):
        """Record from default mic, stopping after a quiet gap."""
        print("   (listening... speak now, I stop automatically on silence)", flush=True)
        block = int(self.sample_rate * 0.2)
        frames = []
        silent_blocks = 0
        silence_blocks_needed = int(silence_seconds / 0.2)
        max_blocks = int(max_seconds / 0.2)
        spoken = False

        with sd.InputStream(samplerate=self.sample_rate, channels=1, dtype="float32", blocksize=block) as stream:
            for _ in range(max_blocks):
                data, _ = stream.read(block)
                frames.append(data.copy())
                rms = float(np.sqrt(np.mean(data ** 2)))
                if rms >= self.silence_threshold:
                    spoken = True
                    silent_blocks = 0
                else:
                    if spoken:
                        silent_blocks += 1
                if spoken and silent_blocks >= silence_blocks_needed:
                    break

        if not spoken:
            return None
        audio = np.concatenate(frames)
        return self._to_wav_bytes(audio)

    def _to_wav_bytes(self, audio: np.ndarray) -> bytes:
        pcm = (np.clip(audio, -1.0, 1.0) * 32767).astype(np.int16)
        buf = io.BytesIO()
        with wave.open(buf, "wb") as wf:
            wf.setnchannels(1)
            wf.setsampwidth(2)
            wf.setframerate(self.sample_rate)
            wf.writeframes(pcm.tobytes())
        return buf.getvalue()

    def save_temp(self, wav_bytes: bytes) -> str:
        fd, path = tempfile.mkstemp(suffix=".wav", prefix="mic_")
        os.close(fd)
        with open(path, "wb") as f:
            f.write(wav_bytes)
        return path


def play_wav(path: str) -> None:
    import winsound
    winsound.PlaySound(path, winsound.SND_FILENAME | winsound.SND_NODEFAULT)