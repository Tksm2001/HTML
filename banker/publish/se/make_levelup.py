"""レベルアップの効果音を合成する（numpy だけ。権利フリー）。
構成: 上がっていく 4 音のアルペジオ（ベル＋矩形波）→ 明るい長三和音の「ジャーン」→ キラキラの粒が散る。
長さ約 1.7 秒、44.1kHz ステレオ。出力: levelup.wav
"""
import numpy as np
import wave

SR = 44100
rng = np.random.default_rng(7)


def note_freq(n):  # MIDI 番号 → Hz
    return 440.0 * 2 ** ((n - 69) / 12)


def env_adsr(n, a=0.005, d=0.08, s=0.55, r=0.25, total=None):
    total = total or n / SR
    t = np.arange(n) / SR
    e = np.ones(n)
    e[t < a] = t[t < a] / a
    m = (t >= a) & (t < a + d)
    e[m] = 1 - (1 - s) * (t[m] - a) / d
    e[t >= a + d] = s
    rel = t > total - r
    e[rel] *= np.clip((total - t[rel]) / r, 0, 1)
    return e


def bell(f, dur, amp=1.0):
    n = int(dur * SR)
    t = np.arange(n) / SR
    # FM ベル（澄んだ金属音）
    mod = np.sin(2 * np.pi * f * 3.5 * t) * np.exp(-t * 6) * 2.2
    car = np.sin(2 * np.pi * f * t + mod)
    return car * np.exp(-t * 3.2) * amp


def square(f, dur, amp=1.0, duty=0.5):
    n = int(dur * SR)
    t = np.arange(n) / SR
    ph = (t * f) % 1.0
    w = np.where(ph < duty, 1.0, -1.0)
    # 角を少し丸める（耳に痛くない 8bit 風）
    k = np.ones(24) / 24
    w = np.convolve(w, k, mode="same")
    return w * env_adsr(n, a=0.004, d=0.06, s=0.5, r=0.05) * amp


def place(buf, sig, start):
    i = int(start * SR)
    j = min(len(buf), i + len(sig))
    buf[i:j] += sig[: j - i]


total = 1.75
L = np.zeros(int(total * SR))
R = np.zeros(int(total * SR))

# 1) 上がっていくアルペジオ C5 E5 G5 C6（少しずつ右へ広がる）
arp = [72, 76, 79, 84]
step = 0.075
for i, n in enumerate(arp):
    f = note_freq(n)
    s = bell(f, 0.6, 0.55)
    sq = square(f, 0.11, 0.18, duty=0.25)
    s[: len(sq)] += sq
    pan = 0.35 + i * 0.1
    place(L, s * (1 - pan), i * step)
    place(R, s * pan, i * step)

# 2) 「ジャーン」: C メジャー（C5 E5 G5 C6 E6）＋下に C4
t0 = len(arp) * step + 0.02
for n, a in [(60, 0.30), (72, 0.32), (76, 0.28), (79, 0.28), (84, 0.25), (88, 0.18)]:
    f = note_freq(n)
    dur = total - t0
    nn = int(dur * SR)
    tt = np.arange(nn) / SR
    # ゆっくり揺れるパッド（デチューン 2 本）＋ベル
    pad = (np.sin(2 * np.pi * f * tt) + np.sin(2 * np.pi * f * 1.004 * tt + 0.7)) * 0.5
    pad *= env_adsr(nn, a=0.01, d=0.25, s=0.45, r=0.6, total=dur)
    s = pad * a + bell(f, dur, a * 0.6)
    place(L, s, t0)
    place(R, s * 0.95, t0 + 0.004)  # ほんの少しずらして広がりを出す

# 3) キラキラ（高い短い粒がランダムに、左右に散る）
for k in range(14):
    st = t0 + 0.02 + k * 0.055 + rng.uniform(-0.01, 0.01)
    n = rng.choice([96, 100, 103, 108, 112])
    s = bell(note_freq(n), 0.25, 0.12 * (1 - k / 16))
    pan = rng.uniform(0.1, 0.9)
    place(L, s * (1 - pan), st)
    place(R, s * pan, st)

# 4) 軽いディレイ（響き）
def delay(x, sec, fb):
    y = x.copy()
    d = int(sec * SR)
    for rep in range(1, 4):
        y[d * rep:] += x[: -d * rep] * (fb ** rep)
    return y

L = delay(L, 0.11, 0.28)
R = delay(R, 0.13, 0.28)

# 正規化とフェード
st = np.stack([L, R], axis=1)
st /= np.max(np.abs(st)) / 0.89
fade = int(0.05 * SR)
st[-fade:] *= np.linspace(1, 0, fade)[:, None]
pcm = (st * 32767).astype(np.int16)
with wave.open("levelup.wav", "wb") as w:
    w.setnchannels(2)
    w.setsampwidth(2)
    w.setframerate(SR)
    w.writeframes(pcm.tobytes())
print("levelup.wav", len(pcm) / SR, "sec")
