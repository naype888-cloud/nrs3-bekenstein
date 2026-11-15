/-
Copyright (c) 2026 Eduardo Nava-Hernandez. All rights reserved.
Released under the NRS Noncommercial License 1.0.0 as described in the file LICENSE.
Authors: Eduardo Nava-Hernandez
-/
module

public import NRS3Bekenstein.BoundaryBits
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum

/-!
# The Universal Bekenstein Bound and Black Hole Saturation

In 1981, Jacob Bekenstein formulated the universal upper bound on the entropy `S` of any
confined quantum system with total mass-energy `M` enclosed in a sphere of radius `R`:
`S ≤ 2 π R M c / ℏ`.

In Planck units where `G = c = ℏ = 1` and `ℓ_P² = G ℏ / c³`, the bound becomes:
`S_bound = 2 π R M / ℓ_P²`.

For a black hole of Schwarzschild radius `R_s = 2 M ℓ_P²` and area `A = 4 π R_s²`, the
universal Bekenstein bound is saturated exactly:
`S_BH = A / (4 ℓ_P²) = 2 π R_s M / ℓ_P² = S_bound`.

Furthermore, the total information capacity in bits is bounded by the boundary area in
units of the Minkowski fiber area `a² = 4 ℓ_P² log 2`.

## Main results

* `bekensteinBound` : the upper bound `2 π R M / ℓ_P²`.
* `schwarzschildRadius` : gravitational radius `2 M ℓ_P²`.
* `schwarzschildArea` : event horizon area `4 π R_s² = 16 π M² ℓ_P⁴`.
* `schwarzschildArea_eq` : explicit area formula `16 π M² ℓ_P⁴`.
* `schwarzschild_saturates_bekenstein_bound` : `S_BH(A_s) = S_bound(R_s, M)`.
* `maxInformationBits` : holographic information capacity `S / log 2`.
* `maxInformationBits_boundaryArea` : `I(Area(N)) = N` bits.
-/

@[expose] public noncomputable section

namespace NRS3Bekenstein

open Real

/-- The universal Bekenstein entropy bound for a region of radius `R` and mass `M`. -/
def bekensteinBound (R M lp : ℝ) : ℝ :=
  2 * π * R * M / lp ^ 2

lemma bekensteinBound_pos {R M lp : ℝ} (hR : 0 < R) (hM : 0 < M) (hlp : lp ≠ 0) :
    0 < bekensteinBound R M lp := by
  unfold bekensteinBound
  have htop : 0 < 2 * π * R * M := by
    have h2pi : 0 < 2 * π := by positivity
    exact mul_pos (mul_pos h2pi hR) hM
  have hbot : 0 < lp ^ 2 := sq_pos_of_ne_zero hlp
  exact div_pos htop hbot

/-- The Schwarzschild radius for a gravitating mass `M`: `2 M`. -/
def schwarzschildRadius (M : ℝ) : ℝ :=
  2 * M

/-- Area of a Euclidean sphere of radius `R` in continuous space ℝ³: `4 π R²`. -/
def sphereArea (R : ℝ) : ℝ :=
  4 * π * R ^ 2

/-- Event horizon area of a Schwarzschild black hole: `sphereArea (schwarzschildRadius M)`. -/
def schwarzschildArea (M : ℝ) : ℝ :=
  sphereArea (schwarzschildRadius M)

/-- Explicit expression for the Schwarzschild horizon area: `16 π M²`. -/
theorem schwarzschildArea_eq (M : ℝ) :
    schwarzschildArea M = 16 * π * M ^ 2 := by
  unfold schwarzschildArea sphereArea schwarzschildRadius
  ring

/-- **Bekenstein Bound Saturation**: For a Schwarzschild black hole, the Bekenstein–Hawking
horizon entropy saturates identically the universal Bekenstein bound. -/
theorem schwarzschild_saturates_bekenstein_bound (M lp : ℝ) (hlp : lp ≠ 0) :
    bekensteinHawkingEntropy (schwarzschildArea M) lp =
      bekensteinBound (schwarzschildRadius M) M lp := by
  unfold bekensteinHawkingEntropy bekensteinBound
  rw [schwarzschildArea_eq]
  unfold schwarzschildRadius
  have hlp2_ne : lp ^ 2 ≠ 0 := (sq_pos_of_ne_zero hlp).ne'
  have h4_ne : (4 : ℝ) ≠ 0 := by norm_num
  have h4lp2_ne : 4 * lp ^ 2 ≠ 0 := mul_ne_zero h4_ne hlp2_ne
  field_simp
  ring

/-- The holographic information capacity in boolean bits: `I = S / log 2`. -/
def maxInformationBits (A lp : ℝ) : ℝ :=
  bekensteinHawkingEntropy A lp / Real.log 2

/-- For a boundary composed of `N` bits of area `a² = 4 ℓ_P² log 2`, the holographic
information capacity is identically `N` bits. -/
theorem maxInformationBits_boundaryArea (lp : ℝ) (N : ℕ) (hlp : lp ≠ 0) :
    maxInformationBits (boundaryArea lp N) lp = (N : ℝ) := by
  unfold maxInformationBits
  rw [bekenstein_hawking_entropy_eq_bits hlp N]
  unfold boundaryBitsEntropy
  have hlog_ne : Real.log 2 ≠ 0 := (Real.log_pos one_lt_two).ne'
  exact mul_div_cancel_right₀ (N : ℝ) hlog_ne

end NRS3Bekenstein
