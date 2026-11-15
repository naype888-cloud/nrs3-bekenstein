/-
Copyright (c) 2026 Eduardo Nava-Hernandez. All rights reserved.
Released under the NRS Noncommercial License 1.0.0 as described in the file LICENSE.
Authors: Eduardo Nava-Hernandez
-/
module

public import Mathlib.Analysis.SpecialFunctions.Pow.Real
public import Mathlib.Analysis.SpecialFunctions.Log.Basic
public import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum

/-!
# Boundary Bits: Jacob Bekenstein's Principle and the Minkowski Fiber

In continuous Euclidean space ℝ³, physical boundaries carry thermodynamic information
quantized in boolean bits: each bit carries entropy `log 2`.

Spacetime is the Minkowski manifold `ℝ³ × S¹` with a proper time fiber on `S¹` at
generator scale `a`. The area required to host one Bekenstein bit on any causal or
transverse boundary is identically the geometric area of the Minkowski fiber:
`a² = 4 ℓ_P² log 2`.

## Main results

* `bekensteinBitEntropy` : the entropy of one bit of information, `log 2`.
* `minkowskiFiberArea` : the area `a² = 4 ℓ_P² log 2` of the Minkowski fiber on `S¹`.
* `boundaryBitsEntropy` : total entropy `N · log 2` of `N` independent boundary bits.
* `boundaryArea` : total geometric area `N · a²` of `N` boundary bits.
* `bekensteinHawkingEntropy` : the Bekenstein–Hawking formula `A / (4 ℓ_P²)`.
* `bekenstein_bit_area_eq_fiber_area` : the area of one Bekenstein bit is identically `a²`.
* `bekenstein_hawking_entropy_eq_bits` : `S_BH(Area(N)) = N · log 2`.
* `bekenstein_hawking_iff_bit_area` : `S_BH(N · a²) = N · log 2` iff `a² = 4 ℓ_P² log 2`.
-/

@[expose] public noncomputable section

namespace NRS3Bekenstein

open Real

/-- The entropy of a single boolean bit of information: `log 2`. -/
def bekensteinBitEntropy : ℝ := Real.log 2

lemma bekensteinBitEntropy_pos : 0 < bekensteinBitEntropy :=
  Real.log_pos one_lt_two

/-- The geometric area of the Minkowski proper time fiber on `S¹` at scale `a`:
`a² = 4 ℓ_P² log 2`. -/
def minkowskiFiberArea (lp : ℝ) : ℝ := 4 * lp ^ 2 * Real.log 2

lemma minkowskiFiberArea_pos {lp : ℝ} (hlp : lp ≠ 0) : 0 < minkowskiFiberArea lp := by
  unfold minkowskiFiberArea
  have h4 : (0 : ℝ) < 4 := by norm_num
  have hlp2 : 0 < lp ^ 2 := sq_pos_of_ne_zero hlp
  have hlog : 0 < Real.log 2 := Real.log_pos one_lt_two
  exact mul_pos (mul_pos h4 hlp2) hlog

/-- Total entropy of `N` independent Bekenstein bits on a boundary: `N · log 2`. -/
def boundaryBitsEntropy (N : ℕ) : ℝ := (N : ℝ) * Real.log 2

theorem boundaryBitsEntropy_eq_log (N : ℕ) :
    boundaryBitsEntropy N = (N : ℝ) * Real.log 2 := rfl

theorem boundaryBitsEntropy_add (N₁ N₂ : ℕ) :
    boundaryBitsEntropy (N₁ + N₂) = boundaryBitsEntropy N₁ + boundaryBitsEntropy N₂ := by
  unfold boundaryBitsEntropy
  push_cast
  ring

theorem boundaryBitsEntropy_pos {N : ℕ} (hN : 1 ≤ N) : 0 < boundaryBitsEntropy N := by
  unfold boundaryBitsEntropy
  have hN_pos : (0 : ℝ) < (N : ℝ) := by positivity
  have hlog : (0 : ℝ) < Real.log 2 := Real.log_pos one_lt_two
  exact mul_pos hN_pos hlog

/-- Total geometric boundary area occupied by `N` bits at scale `a`: `N · a²`. -/
def boundaryArea (lp : ℝ) (N : ℕ) : ℝ := (N : ℝ) * minkowskiFiberArea lp

theorem boundaryArea_eq (lp : ℝ) (N : ℕ) :
    boundaryArea lp N = (N : ℝ) * (4 * lp ^ 2 * Real.log 2) := rfl

theorem boundaryArea_pos {lp : ℝ} (hlp : lp ≠ 0) {N : ℕ} (hN : 1 ≤ N) :
    0 < boundaryArea lp N := by
  unfold boundaryArea
  have hN_pos : (0 : ℝ) < (N : ℝ) := by positivity
  exact mul_pos hN_pos (minkowskiFiberArea_pos hlp)

/-- The standard Bekenstein–Hawking entropy for an area `A` in Planck units: `A / (4 ℓ_P²)`. -/
def bekensteinHawkingEntropy (A lp : ℝ) : ℝ := A / (4 * lp ^ 2)

/-- **Primary Theorem**: The area of a single Bekenstein bit on the boundary is
identically the area of the Minkowski proper time fiber `a² = 4 ℓ_P² log 2`. -/
theorem bekenstein_bit_area_eq_fiber_area (lp : ℝ) :
    minkowskiFiberArea lp = 4 * lp ^ 2 * Real.log 2 := rfl

/-- Bekenstein–Hawking entropy on the boundary area of `N` bits evaluates
identically to `N · log 2`. -/
theorem bekenstein_hawking_entropy_eq_bits {lp : ℝ} (hlp : lp ≠ 0) (N : ℕ) :
    bekensteinHawkingEntropy (boundaryArea lp N) lp = boundaryBitsEntropy N := by
  unfold bekensteinHawkingEntropy boundaryArea minkowskiFiberArea boundaryBitsEntropy
  have hlp2 : 4 * lp ^ 2 ≠ 0 := by
    have h4 : (4 : ℝ) ≠ 0 := by norm_num
    have hp : lp ^ 2 ≠ 0 := (sq_pos_of_ne_zero hlp).ne'
    exact mul_ne_zero h4 hp
  field_simp

/-- The Bekenstein–Hawking area law `S = A / (4 ℓ_P²)` holds for `N` boundary units of area `a²`
if and only if `a²` is the Minkowski fiber area `4 ℓ_P² log 2`. -/
theorem bekenstein_hawking_iff_bit_area {lp a : ℝ} (hlp : lp ≠ 0) {N : ℕ} (hN : 1 ≤ N) :
    bekensteinHawkingEntropy ((N : ℝ) * a ^ 2) lp = boundaryBitsEntropy N ↔
      a ^ 2 = minkowskiFiberArea lp := by
  unfold bekensteinHawkingEntropy boundaryBitsEntropy minkowskiFiberArea
  have hN_pos : (0 : ℝ) < (N : ℝ) := by positivity
  have hN_ne : (N : ℝ) ≠ 0 := hN_pos.ne'
  have h4lp2_pos : 0 < 4 * lp ^ 2 := mul_pos (by norm_num) (sq_pos_of_ne_zero hlp)
  have h4lp2_ne : 4 * lp ^ 2 ≠ 0 := h4lp2_pos.ne'
  constructor
  · intro h
    have h1 : (N : ℝ) * a ^ 2 = (N : ℝ) * Real.log 2 * (4 * lp ^ 2) := by
      exact (div_eq_iff h4lp2_ne).mp h
    have h2 : a ^ 2 = Real.log 2 * (4 * lp ^ 2) := by
      have : (N : ℝ) * a ^ 2 = (N : ℝ) * (Real.log 2 * (4 * lp ^ 2)) := by
        rw [h1]; ring
      exact mul_left_cancel₀ hN_ne this
    rw [h2]
    ring
  · intro h
    rw [h]
    field_simp

end NRS3Bekenstein
