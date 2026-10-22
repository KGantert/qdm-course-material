"""
Quantitative Dynamic Macroeconomics
Lecture 03: Simulated AR(1) processes x_t = rho * x_{t-1} + eps_t, eps_t ~ N(0,1)

Writes rand1.png ... rand4.png (rho = 0, 0.5, 0.975, 1) to ../latex/figures/.
Requires numpy and matplotlib.
"""
from pathlib import Path

import numpy as np
import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt

rng = np.random.default_rng(2026)
periods, paths = 50, 5
out = Path(__file__).resolve().parent.parent / "latex" / "figures"

for k, rho in enumerate([0, 0.5, 0.975, 1.0], start=1):
    x = np.zeros((paths, periods))
    eps = rng.standard_normal((paths, periods))
    x[:, 0] = eps[:, 0]
    for t in range(1, periods):
        x[:, t] = rho * x[:, t - 1] + eps[:, t]
    fig, ax = plt.subplots(figsize=(6.4, 4.8))
    ax.plot(x.T)
    ax.set_title(f"rho = {rho}")
    fig.savefig(out / f"rand{k}.png", dpi=100)
    plt.close(fig)
print("written", out)
