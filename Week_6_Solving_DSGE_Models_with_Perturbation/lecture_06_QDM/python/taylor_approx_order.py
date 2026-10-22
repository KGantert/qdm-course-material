"""
Quantitative Dynamic Macroeconomics
Lecture 06: Taylor polynomials of log(1+x) of different order

Illustrates that the fit of a Taylor approximation does not increase monotonically in the order.
Writes ../latex/figures/taylor_approx_order.png.  Requires numpy and matplotlib.
"""
from math import factorial
from pathlib import Path

import numpy as np
import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt


def taylor_log1p(x, order):
    """Taylor polynomial of log(1+x) around 0: sum_{k=1}^n (-1)^(k+1) x^k / k."""
    return sum((-1) ** (k + 1) * x ** k / k for k in range(1, order + 1))


x = np.linspace(-1.5, 1.5, 2001)
fig, ax = plt.subplots(figsize=(5, 5))
with np.errstate(invalid="ignore", divide="ignore"):
    ax.plot(x[x > -1], np.log1p(x[x > -1]), color="orange", lw=2.5, label=r"$\log(1+x)$")
for order, color in zip([4, 7, 11, 16], ["red", "green", "blue", "cyan"]):
    ax.plot(x, taylor_log1p(x, order), color=color, lw=1.2, label=rf"$T_{{{order}}}$")
ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-4, 2)
ax.axhline(0, color="gray", lw=0.8)
ax.axvline(0, color="gray", lw=0.8)
ax.grid(True, color="lightgray", lw=0.6)
ax.legend(loc="upper left")
out = Path(__file__).resolve().parent.parent / "latex" / "figures" / "taylor_approx_order.png"
fig.savefig(out, dpi=200, bbox_inches="tight")
print("written", out)
