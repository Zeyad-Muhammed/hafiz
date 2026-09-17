import json
import time

import requests

from . import config


class LLMClient:
    def __init__(self, base_url: str = config.LLAMA_URL):
        self.base_url = base_url
        self.history: list[dict] = []
        self.system = config.SYSTEM_PROMPT

    def reset(self) -> None:
        self.history = []

    def _messages(self) -> list[dict]:
        msgs = [{"role": "system", "content": self.system}]
        msgs.extend(self.history[-12:])
        return msgs

    def reply_stream(self, user_text: str, max_tokens: int = 256):
        self.history.append({"role": "user", "content": user_text})
        messages = self._messages()
        payload = {
            "model": config.LLAMA_MODEL_NAME,
            "messages": messages,
            "max_tokens": max_tokens,
            "temperature": 0.7,
            "top_p": 0.9,
            "stream": True,
        }
        parts: list[str] = []
        with requests.post(self.base_url, json=payload, stream=True, timeout=180) as r:
            r.raise_for_status()
            buffer = ""
            for raw in r.iter_lines(decode_unicode=True):
                if not raw:
                    continue
                buffer = raw if not buffer else buffer
                if buffer.startswith("data: "):
                    data = buffer[6:]
                    buffer = ""
                    if data == "[DONE]":
                        break
                    try:
                        chunk = json.loads(data)
                        delta = chunk["choices"][0]["delta"].get("content", "")
                        if delta:
                            parts.append(delta)
                            yield delta
                    except (json.JSONDecodeError, KeyError, IndexError):
                        continue
                else:
                    buffer = raw
        self.history.append({"role": "assistant", "content": "".join(parts)})


def wait_for_server(base_url: str, timeout: float = 120.0) -> bool:
    url = base_url.replace("/v1/chat/completions", "/health")
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            r = requests.get(url, timeout=3)
            if r.status_code == 200:
                return True
        except requests.RequestException:
            pass
        time.sleep(1.5)
    return False