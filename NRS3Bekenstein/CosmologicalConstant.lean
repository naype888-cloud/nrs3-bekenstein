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
# Cosmological Constant and Boundary Bits

The Bekenstein entropy `S = N · log 2` of a boundary with `N` bits fixes the effective
cosmological constant `Λ` of the bounded de Sitter region at curvature length `ℓ`:
`Λ = 3 π / (ℓ² S) = 3 π / (ℓ² N log 2)`.

## Main results

* `cosmologicalConstantBits` : `Λ = 3 π / (ℓ² · N log 2)`.
* `cosmologicalConstantBits_pos` : strictly positive cosmological constant `Λ > 0`.
* `cosmologicalConstantBits_strictAnti` : larger bit count gives strictly smaller `Λ`.
* `horizonArea_cosmologicalConstantBits` : de Sitter horizon area `12 π / Λ = N · a²`.
-/

@[expose] public noncomputable section

namespace NRS3Bekenstein

open Real

/-- The cosmological constant determined by `N` boundary bits: `3 π / (ℓ² S)`. -/
def cosmologicalConstantBits (N : ℕ) (ℓ : ℝ) : ℝ :=
  3 * π / (ℓ ^ 2 * boundaryBitsEntropy N)

theorem cosmologicalConstantBits_eq (N : ℕ) (ℓ : ℝ) :
    cosmologicalConstantBits N ℓ =
      3 * π / (ℓ ^ 2 * ((N : ℝ) * Real.log 2)) := rfl

/-- Strict positivity of the cosmological constant (`Λ > 0`) on continuous space ℝ³. -/
theorem cosmologicalConstantBits_pos {N : ℕ} (hN : 1 ≤ N) {ℓ : ℝ} (hℓ : ℓ ≠ 0) :
    0 < cosmologicalConstantBits N ℓ := by
  unfold cosmologicalConstantBits
  have htop : (0 : ℝ) < 3 * π := by positivity
  have hbot : (0 : ℝ) < ℓ ^ 2 * boundaryBitsEntropy N :=
    mul_pos (sq_pos_of_ne_zero hℓ) (boundaryBitsEntropy_pos hN)
  exact div_pos htop hbot

/-- Anti-monotonicity: a boundary with more bits yields a strictly smaller cosmological constant. -/
theorem cosmologicalConstantBits_strictAnti {N₁ N₂ : ℕ} (hN₁ : 1 ≤ N₁) (hN : N₁ < N₂)
    {ℓ : ℝ} (hℓ : ℓ ≠ 0) :
    cosmologicalConstantBits N₂ ℓ < cosmologicalConstantBits N₁ ℓ := by
  rw [cosmologicalConstantBits_eq, cosmologicalConstantBits_eq]
  have htop : (0 : ℝ) < 3 * π := by positivity
  have hℓ2 : (0 : ℝ) < ℓ ^ 2 := sq_pos_of_ne_zero hℓ
  have hlog : (0 : ℝ) < Real.log 2 := Real.log_pos one_lt_two
  have hN₁_pos : (0 : ℝ) < (N₁ : ℝ) := by exact_mod_cast (Nat.succ_le_iff.mp hN₁)
  have hN_lt : (N₁ : ℝ) < (N₂ : ℝ) := by exact_mod_cast hN
  have hbot₁ : (0 : ℝ) < ℓ ^ 2 * ((N₁ : ℝ) * Real.log 2) :=
    mul_pos hℓ2 (mul_pos hN₁_pos hlog)
  have hbot_lt : ℓ ^ 2 * ((N₁ : ℝ) * Real.log 2) < ℓ ^ 2 * ((N₂ : ℝ) * Real.log 2) :=
    mul_lt_mul_of_pos_left (mul_lt_mul_of_pos_right hN_lt hlog) hℓ2
  exact div_lt_div_of_pos_left htop hbot₁ hbot_lt

/-- The de Sitter horizon area `12 π / Λ` matches identically the boundary area `N · a²`. -/
theorem horizonArea_cosmologicalConstantBits {N : ℕ} (hN : 1 ≤ N) {ℓ : ℝ} (hℓ : ℓ ≠ 0) :
    12 * π / cosmologicalConstantBits N ℓ = boundaryArea ℓ N := by
  rw [cosmologicalConstantBits_eq]
  unfold boundaryArea minkowskiFiberArea
  have hπ : π ≠ 0 := Real.pi_ne_zero
  have hℓ2 : ℓ ^ 2 ≠ 0 := (sq_pos_of_ne_zero hℓ).ne'
  have hlog : Real.log 2 ≠ 0 := (Real.log_pos one_lt_two).ne'
  have hN_pos : (0 : ℝ) < (N : ℝ) := by exact_mod_cast (Nat.succ_le_iff.mp hN)
  have hN_ne : (N : ℝ) ≠ 0 := hN_pos.ne'
  field_simp
  ring

end NRS3Bekenstein
