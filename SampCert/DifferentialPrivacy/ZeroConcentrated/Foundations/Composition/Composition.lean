import SampCert.DifferentialPrivacy.ZeroConcentrated.DP

noncomputable section

open Classical Nat Int Real ENNReal MeasureTheory Measure

namespace SLang

def Compose (nq1 nq2 : List T → SLang ℤ) (l : List T) : SLang (ℤ × ℤ) := do
  let A ← nq1 l
  let B ← nq2 l
  return (A,B)

theorem ENNReal_toTeal_NZ (x : ENNReal) (h1 : x ≠ 0) (h2 : x ≠ ⊤) :
  x.toReal ≠ 0 := by
  unfold ENNReal.toReal
  unfold ENNReal.toNNReal
  simp
  intro H
  cases H
  . contradiction
  . contradiction

theorem simp_α_1 {α : ℝ} (h : 1 < α) : 0 < α := by
  apply @lt_trans _ _ _ 1 _ _ h
  simp only [zero_lt_one]

theorem RenyiNoisedQueryNonZero {nq : List T → SLang ℤ} {α ε : ℝ} (h1 : 1 < α) {l₁ l₂ : List T} (h2 : Neighbour l₁ l₂) (h3 : DP nq ε) (h4 : NonZeroNQ nq) (h5 : NonTopRDNQ nq) (nts : NonTopNQ nq) :
  (∑' (i : ℤ), nq l₁ i ^ α * nq l₂ i ^ (1 - α)).toReal ≠ 0 := by
  simp [DP] at h3
  replace h3 := h3 α h1 l₁ l₂ h2
  simp [RenyiDivergence] at h3
  simp [NonZeroNQ] at h4
  simp [NonTopRDNQ] at h5
  replace h5 := h5 α h1 l₁ l₂ h2
  have h6 := h4 l₁
  have h7 := h4 l₂
  apply ENNReal_toTeal_NZ
  . by_contra CONTRA
    rw [ENNReal.tsum_eq_zero] at CONTRA
    replace CONTRA := CONTRA 42
    replace h6 := h6 42
    replace h7 := h7 42
    rw [_root_.mul_eq_zero] at CONTRA
    cases CONTRA
    . rename_i h8
      rw [rpow_eq_zero_iff_of_pos] at h8
      contradiction
      apply simp_α_1 h1
    . rename_i h8
      rw [ENNReal.rpow_eq_zero_iff] at h8
      cases h8
      . rename_i h8
        cases h8
        contradiction
      . rename_i h8
        cases h8
        rename_i h8 h9
        replace nts := nts l₂ 42
        contradiction
  . exact h5

theorem compose_sum_rw (nq1 nq2 : List T → SLang ℤ) (b c : ℤ) (l : List T) :
  (∑' (a : ℤ), nq1 l a * ∑' (a_1 : ℤ), if b = a ∧ c = a_1 then nq2 l a_1 else 0) = nq1 l b * nq2 l c := by
  have A : ∀ a b : ℤ, (∑' (a_1 : ℤ), if b = a ∧ c = a_1 then nq2 l a_1 else 0) = if b = a then (∑' (a_1 : ℤ), if c = a_1 then nq2 l a_1 else 0) else 0 := by
    intro x  y
    split
    . rename_i h
      subst h
      simp
    . rename_i h
      simp
      intro h
      contradiction
  conv =>
    left
    right
    intro a
    right
    rw [A]
  rw [ENNReal.tsum_eq_add_tsum_ite b]
  simp
  have B : ∀ x : ℤ, (@ite ℝ≥0∞ (x = b) (instDecidableEqInt x b) 0
    (@ite ℝ≥0∞ (b = x) (instDecidableEqInt b x) (nq1 l x * ∑' (a_1 : ℤ), @ite ℝ≥0∞ (c = a_1) (instDecidableEqInt c a_1) (nq2 l a_1) 0) 0)) = 0 := by
    intro x
    split
    . simp
    . split
      . rename_i h1 h2
        subst h2
        contradiction
      . simp
  conv =>
    left
    right
    right
    intro x
    rw [B]
  simp
  congr 1
  rw [ENNReal.tsum_eq_add_tsum_ite c]
  simp
  have C :∀ x : ℤ,  (@ite ℝ≥0∞ (x = c) (propDecidable (x = c)) 0 (@ite ℝ≥0∞ (c = x) (instDecidableEqInt c x) (nq2 l x) 0)) = 0 := by
    intro x
    split
    . simp
    . split
      . rename_i h1 h2
        subst h2
        contradiction
      . simp
  conv =>
    left
    right
    right
    intro X
    rw [C]
  simp

theorem DPCompose {nq1 nq2 : List T → SLang ℤ} {ε₁ ε₂ ε₃ ε₄ : ℕ+} (h1 : DP nq1 ((ε₁ : ℝ) / ε₂))  (h2 : DP nq2 ((ε₃ : ℝ) / ε₄)) (nn1 : NonZeroNQ nq1) (nn2 : NonZeroNQ nq2) (nt1 : NonTopRDNQ nq1) (nt2 : NonTopRDNQ nq2) (nts1 : NonTopNQ nq1) (nts2 : NonTopNQ nq2) :
  DP (Compose nq1 nq2) (((ε₁ : ℝ) / ε₂) + ((ε₃ : ℝ) / ε₄)) := by
  simp [Compose, RenyiDivergence, DP]
  intro α h3 l₁ l₂ h4
  have X := h1
  have Y := h2
  simp [DP] at h1 h2
  replace h1 := h1 α h3 l₁ l₂ h4
  replace h2 := h2 α h3 l₁ l₂ h4
  simp [RenyiDivergence] at h1 h2
  rw [tsum_prod' ENNReal.summable (fun b : ℤ => ENNReal.summable)]
  . simp
    conv =>
      left
      right
      right
      right
      right
      intro b
      right
      intro c
      rw [compose_sum_rw]
      rw [compose_sum_rw]
      rw [ENNReal.mul_rpow_of_ne_zero (nn1 l₁ b) (nn2 l₁ c)]
      rw [ENNReal.mul_rpow_of_ne_zero (nn1 l₂ b) (nn2 l₂ c)]
      rw [mul_assoc]
      right
      rw [mul_comm]
      rw [mul_assoc]
      right
      rw [mul_comm]
    conv =>
      left
      right
      right
      right
      right
      intro b
      right
      intro c
      rw [← mul_assoc]
    conv =>
      left
      right
      right
      right
      right
      intro b
      rw [ENNReal.tsum_mul_left]
    rw [ENNReal.tsum_mul_right]
    rw [ENNReal.toReal_mul]
    rw [Real.log_mul]
    . rw [mul_add]
      have D := _root_.add_le_add h1 h2
      apply le_trans D
      rw [← add_mul]
      rw [mul_le_mul_iff_of_pos_right]
      . rw [← mul_add]
        rw [mul_le_mul_iff_of_pos_left]
        . ring_nf
          simp
        . simp
      . apply lt_trans zero_lt_one h3
    . apply RenyiNoisedQueryNonZero h3 h4 X nn1 nt1 nts1
    . apply RenyiNoisedQueryNonZero h3 h4 Y nn2 nt2 nts2

theorem DPCompose_NonZeroNQ {nq1 nq2 : List T → SLang ℤ} (nn1 : NonZeroNQ nq1) (nn2 : NonZeroNQ nq2) :
  NonZeroNQ (Compose nq1 nq2) := by
  simp [NonZeroNQ] at *
  intro l a b
  replace nn1 := nn1 l a
  replace nn2 := nn2 l b
  simp [Compose]
  exists a
  simp
  intro H
  cases H
  . rename_i H
    contradiction
  . rename_i H
    contradiction

theorem DPCompose_NonTopNQ {nq1 nq2 : List T → SLang ℤ} (nt1 : NonTopNQ nq1) (nt2 : NonTopNQ nq2) :
  NonTopNQ (Compose nq1 nq2) := by
  simp [NonTopNQ] at *
  intro l a b
  replace nt1 := nt1 l a
  replace nt2 := nt2 l b
  simp [Compose]
  rw [compose_sum_rw]
  rw [mul_eq_top]
  intro H
  cases H
  . rename_i H
    cases H
    contradiction
  . rename_i H
    cases H
    contradiction

theorem DPCompose_NonTopSum {nq1 nq2 : List T → SLang ℤ} (nt1 : NonTopSum nq1) (nt2 : NonTopSum nq2) :
  NonTopSum (Compose nq1 nq2) := by
  simp [NonTopSum] at *
  intro l
  replace nt1 := nt1 l
  replace nt2 := nt2 l
  simp [Compose]
  rw [ENNReal.tsum_prod']
  conv =>
    right
    left
    right
    intro a
    right
    intro b
    simp
    rw [compose_sum_rw]
  conv =>
    right
    left
    right
    intro a
    rw [ENNReal.tsum_mul_left]
  rw [ENNReal.tsum_mul_right]
  rw [mul_eq_top]
  intro H
  cases H
  . rename_i H
    cases H
    contradiction
  . rename_i H
    cases H
    contradiction

theorem DPCompose_NonTopRDNQ {nq1 nq2 : List T → SLang ℤ} (nt1 : NonTopRDNQ nq1) (nt2 : NonTopRDNQ nq2) (nn1 : NonZeroNQ nq1) (nn2 : NonZeroNQ nq2) :
  NonTopRDNQ (Compose nq1 nq2) := by
  simp [NonTopRDNQ] at *
  intro α h1 l₁ l₂ h2
  replace nt1 := nt1 α h1 l₁ l₂ h2
  replace nt2 := nt2 α h1 l₁ l₂ h2
  simp [Compose]
  rw [ENNReal.tsum_prod']
  simp
  conv =>
    right
    left
    right
    intro x
    right
    intro y
    congr
    . left
      rw [compose_sum_rw]
    . left
      rw [compose_sum_rw]
  conv =>
    right
    left
    right
    intro x
    right
    intro y
    rw [ENNReal.mul_rpow_of_ne_zero (nn1 l₁ x) (nn2 l₁ y)]
    rw [ENNReal.mul_rpow_of_ne_zero (nn1 l₂ x) (nn2 l₂ y)]
    rw [mul_assoc]
    right
    rw [mul_comm]
    rw [mul_assoc]
    right
    rw [mul_comm]
  conv =>
    right
    left
    right
    intro x
    right
    intro y
    rw [← mul_assoc]
  conv =>
    right
    left
    right
    intro x
    rw [ENNReal.tsum_mul_left]
  rw [ENNReal.tsum_mul_right]
  intro H
  rw [mul_eq_top] at H
  cases H
  . rename_i h3
    cases h3
    rename_i h4 h5
    contradiction
  . rename_i h3
    cases h3
    rename_i h4 h5
    contradiction

end SLang
