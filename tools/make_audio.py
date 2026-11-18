"""Membuat musik latar dan efek suara ORIGINAL bernuansa gamolan (alat musik bilah bambu).
Bukan rekaman atau lagu tradisional; ini komposisi sederhana yang disintesis dengan kode.
Pemakaian: python3 tools/make_audio.py   (butuh numpy dan ffmpeg)"""
import numpy as np, subprocess, wave, os

SR = 22050
out = os.path.join(os.path.dirname(__file__), '..', 'assets', 'audio')
os.makedirs(out, exist_ok=True)

def bamboo(freq, dur, amp=1.0):
    t = np.arange(int(SR * dur)) / SR
    s = np.zeros_like(t)
    for ratio, a, tau in [(1.0, 1.0, .55), (3.93, .38, .14), (9.2, .10, .05)]:
        s += a * np.sin(2 * np.pi * freq * ratio * t) * np.exp(-t / tau)
    click = np.random.RandomState(1).randn(len(t)) * np.exp(-t / .004) * .05
    return amp * (s + click)

def gong(freq, dur, amp=1.0):
    t = np.arange(int(SR * dur)) / SR
    s = np.sin(2 * np.pi * freq * t) + .5 * np.sin(2 * np.pi * freq * 2.02 * t) * np.exp(-t / .8)
    return amp * s * np.exp(-t / 1.6) * np.minimum(1, t / .01)

def place(buf, sig, start):
    i = int(start * SR)
    n = min(len(sig), len(buf) - i)
    if n > 0:
        buf[i:i + n] += sig[:n]

def save(name, data, mp3=False):
    data = data / max(1e-9, np.max(np.abs(data))) * .85
    pcm = (data * 32767).astype(np.int16)
    wav = os.path.join(out, name + '.wav')
    with wave.open(wav, 'wb') as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes(pcm.tobytes())
    if mp3:
        r = subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-i', wav, '-codec:a', 'libmp3lame', '-b:a', '96k', os.path.join(out, name + '.mp3')])
        if r.returncode == 0:
            os.remove(wav)

# ---- musik latar: 2 frasa x 32 langkah, skala pentatonik 5 nada per oktaf
base = 392.0
def note(k): return base * 2 ** (k / 5.0)
step = .30
phrases = [
    [0, 2, 4, 2, 3, 2, 0, -1,  0, 2, 4, 5, 4, 2, 3, 2,  0, 2, 4, 2, 3, 5, 4, 2,  3, 2, 0, 2, 0, -1, 0, None],
    [4, 5, 7, 5, 4, 2, 4, 2,  3, 4, 5, 4, 2, 0, 2, None,  4, 5, 7, 9, 7, 5, 4, 2,  3, 2, 0, 2, 3, 2, 0, None],
]
total_steps = 64
dur = total_steps * step
buf = np.zeros(int((dur + 3) * SR))
for pi, ph in enumerate(phrases):
    for i, k in enumerate(ph):
        t0 = (pi * 32 + i) * step
        if k is not None:
            place(buf, bamboo(note(k), 1.4, .8), t0)
        if i % 2 == 1 and k is not None:           # suara pengiring oktaf bawah
            place(buf, bamboo(note(k - 5), 1.0, .35), t0 + step / 2)
    for b in range(4):                              # gong rendah tiap 8 langkah
        place(buf, gong(98.0 if b % 2 == 0 else 130.8, 2.4, .55), (pi * 32 + b * 8) * step)
loop = buf[:int(dur * SR)].copy()
tail = buf[int(dur * SR):]
loop[:len(tail)] += tail                            # lipat ekor agar loop mulus
save('gamolan_loop', loop, mp3=True)

# ---- efek suara
def seq(notes, gap, d=.9):
    b = np.zeros(int((len(notes) * gap + d + .2) * SR))
    for i, k in enumerate(notes):
        place(b, bamboo(note(k), d, .9), i * gap)
    return b
save('sfx_correct', seq([2, 5], .11), True)
save('sfx_win', seq([0, 2, 4, 5, 7, 9], .12, 1.2), True)
save('sfx_tap', bamboo(note(4), .35, 1.0), True)
t = np.arange(int(.45 * SR)) / SR
wrong = np.sin(2 * np.pi * (220 - 90 * t / .45) * t) * np.exp(-t / .14)
save('sfx_wrong', wrong, True)
print(os.listdir(out))
