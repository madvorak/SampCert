/-
Copyright (c) 2024 Amazon.com, Inc. or its affiliates. All Rights Reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jean-Baptiste Tristan
-/

import SampCert.Foundations.Random
import Mathlib.Probability.ProbabilityMassFunction.Constructions

open PMF Nat Classical ENNReal

variable {T}

noncomputable def prob_while_cut (cond : T → Bool) (body : T → RandomM T) (n : Nat) (a : T) : T → ENNReal :=
  match n with
  | zero => λ x : T => 0
  | succ n =>
    if cond a
    then λ x : T => ∑' c, (body a c) * (prob_while_cut cond body n c) x
    else λ x : T => if x = a then 1 else 0

theorem prob_while_cut_monotonic (cond : T → Bool) (body : T → RandomM T) (init : T) (x : T) :
  Monotone (fun n : Nat => prob_while_cut cond body n init x) := sorry

def plop1 (cond : T → Bool) (body : T → RandomM T) (init : T) (x : T) :=
  tendsto_atTop_iSup (prob_while_cut_monotonic cond body init x)

noncomputable def prob_while' (cond : T → Bool) (body : T → RandomM T) (init : T) : T → ENNReal :=
  fun x => ⨆ (i : ℕ), (prob_while_cut cond body i init x)

def terminates (cond : T → Bool) (body : T → RandomM T) : Prop :=
  forall init : T, HasSum (prob_while' cond body init) 1

theorem termination_01_simple (cond : T → Bool) (body : T → RandomM T) :
  (forall init : T, cond init → PMF.map cond (body init) false > 0) →
  terminates cond body := sorry

noncomputable def prob_while (cond : T → Bool) (body : T → RandomM T) (h : terminates cond body) (a : T) : RandomM T :=
  ⟨ prob_while' cond body a , h a ⟩

noncomputable def whileC (cond : T → Bool) (body : T → RandomM T) : T → RandomM T := sorry

-- theorem prob_while_reduction (P : (T → ENNReal) → Prop) (cond : T → Bool) (body : T → PMF T) (h : terminates cond body) (a : T) :
--   (∀ n : ℕ, forall t : T, t ∈ (prob_while_cut cond body n a).support → ¬ cond t → P (prob_while_cut cond body n a)) →
--   P (prob_while' cond body a) := sorry

-- theorem prob_while_reduction' (P : T → Prop) (cond : T → Bool) (body : T → PMF T) (h : terminates cond body) (a : T) :
--   (∀ n : ℕ, ∀ t ∈ (prob_while_cut cond body n a).support, ¬ cond t → P t) →
--   ∀ t ∈ (prob_while cond body h a).support, P t := sorry

-- theorem prob_while_reduction_quant (P : T → Prop) (cond : T → Bool) (body : T → PMF T) (h : terminates cond body) (a : T) (t : T) :
--   (∀ n : ℕ, t ∈ (prob_while_cut cond body n a).support → ¬ cond t → P t) →
--   t ∈ (prob_while cond body h a).support → P t := sorry

-- theorem prob_while_reduction'' (pmf : PMF T) (cond : T → Bool) (body : T → PMF T) (h : terminates cond body) (a : T) :
--   (∀ n : ℕ, ∀ t : T, ¬ cond t → (prob_while_cut cond body n a) t = pmf t) →
--   ∀ t : T, (prob_while cond body h a) t = pmf t := sorry

-- theorem prob_while_reduction''' (pmf : PMF T) (cond : T → Bool) (body : T → PMF T) (h : terminates cond body) (a : T) :
--   (∀ n : ℕ, ∀ t : T, ¬ cond t → f = prob_while_cut cond body n a -> (hf0 : tsum f ≠ 0) → (hf : tsum f ≠ ∞) → normalize f hf0 hf t = pmf t) →
--   ∀ t : T, (prob_while cond body h a) t = pmf t := sorry

-- theorem prob_while_rule (P : RandomM T -> Prop) (cond : T → Bool) (body : T → RandomM T) (h : terminates cond body) (a : T) :
--   (¬ cond a → P (PMF.pure a)) →
--   (forall whil : RandomM T, P whil → forall t : T, t ∈ whil.support → ¬ cond t → P (body t)) →
--   P (prob_while cond body h a) := sorry

-- theorem prob_while_rule' (f : T -> ENNReal) (cond : T → Bool) (body : T → RandomM T) (h : terminates cond body) (a : T) (x : T) :
--   (¬ cond a → (PMF.pure a)) →
--   (forall whil : RandomM T, P whil → forall t : T, t ∈ whil.support → ¬ cond t → P (body t)) →
--   (prob_while cond body h a) x = f x := sorry
