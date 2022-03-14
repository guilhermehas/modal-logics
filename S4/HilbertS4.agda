module S4.HilbertS4 where

open import Basics

----------------------------------------
-- Hilbert system for constructive S4 --
----------------------------------------

-- Definition.

data ThmS4 (Γ : Cx modal) :  Ty modal → Set where

  S4-var : ∀ {A : Ty modal} → (A ∈ Γ) → ThmS4 Γ A
  S4-k : ∀ {A B : Ty modal} →  ThmS4 Γ (A => (B => A))
  S4-s : ∀ {A B C : Ty modal} → ThmS4 Γ ((A => B => C) => (A => B) => (A => C))
  S4-MP : ∀ {A B : Ty modal} → ThmS4 Γ (A => B) → ThmS4 Γ A → ThmS4 Γ B
  S4-NEC : ∀ {A : Ty modal} → ThmS4 · A → ThmS4 Γ (□ A)
  S4-prod1 : ∀ {A B : Ty modal} → ThmS4 Γ (A => B => A ∧ B)
  S4-prod2 : ∀ {A B : Ty modal} → ThmS4 Γ (A ∧ B => A)
  S4-prod3 : ∀ {A B : Ty modal} → ThmS4 Γ (A ∧ B => B)
  S4-axK : ∀ {A B : Ty modal} → ThmS4 Γ (□(A => B) => □ A => □ B)
  S4-ax4 : ∀ {A : Ty modal} → ThmS4 Γ (□ A => □ □ A)
  S4-axT : ∀ {A : Ty modal} → ThmS4 Γ (□ A => A)
  

-- Weakening, exchange, and contraction.

S4-weak : ∀ {Γ Δ} {A}

    → Γ ⊆ Δ    → ThmS4 Γ A
    ------------------------
         → ThmS4 Δ A

S4-weak p (S4-var x) = S4-var (subsetdef x p)
S4-weak p S4-k = S4-k
S4-weak p S4-s = S4-s
S4-weak p (S4-MP d d₁) = S4-MP (S4-weak p d) (S4-weak p d₁)
S4-weak p (S4-NEC d) = S4-NEC d
S4-weak p S4-axK = S4-axK
S4-weak p S4-prod1 = S4-prod1
S4-weak p S4-prod2 = S4-prod2
S4-weak p S4-prod3 = S4-prod3
S4-weak p S4-ax4 = S4-ax4
S4-weak p S4-axT = S4-axT


S4-exch : ∀ {Γ} {A B C} (Γ' : Cx modal)

    → ThmS4 (Γ , A , B ++ Γ') C
    ---------------------------
    → ThmS4 (Γ , B , A ++ Γ') C
    
S4-exch Γ' (S4-var p) = S4-var (cx-exch {Δ = Γ'} p)
S4-exch Γ' S4-k = S4-k
S4-exch Γ' S4-s = S4-s
S4-exch Γ' (S4-MP p p₁) = S4-MP (S4-exch Γ' p) (S4-exch Γ' p₁)
S4-exch Γ' (S4-NEC p) = S4-NEC p
S4-exch Γ' S4-prod1 = S4-prod1
S4-exch Γ' S4-prod2 = S4-prod2
S4-exch Γ' S4-prod3 = S4-prod3
S4-exch Γ' S4-axK = S4-axK
S4-exch Γ' S4-ax4 = S4-ax4
S4-exch Γ' S4-axT = S4-axT

S4-contr : ∀ {Γ} {A C} (Γ' : Cx modal)

    → ThmS4 (Γ , A , A ++ Γ') C
    ---------------------------
     → ThmS4 (Γ , A ++ Γ') C

S4-contr Γ' (S4-var p) = S4-var (cx-contr {Δ = Γ'} p)
S4-contr Γ' S4-k = S4-k
S4-contr Γ' S4-s = S4-s
S4-contr Γ' (S4-MP p q) = S4-MP (S4-contr Γ' p) (S4-contr Γ' q)
S4-contr Γ' (S4-NEC p) = S4-NEC p
S4-contr Γ' S4-prod1 = S4-prod1
S4-contr Γ' S4-prod2 = S4-prod2
S4-contr Γ' S4-prod3 = S4-prod3
S4-contr Γ' S4-axK = S4-axK
S4-contr Γ' S4-ax4 = S4-ax4
S4-contr Γ' S4-axT = S4-axT


-- Deduction Theorem.

S4-dedthm :  ∀ {Γ : Cx modal} {A B : Ty modal}

   → ThmS4 (Γ , A) B
   -------------------
   → ThmS4 Γ (A => B)

S4-dedthm {Γ} {A} {.A} (S4-var top) = S4-MP (S4-MP S4-s S4-k) (S4-k {Γ} {A} {A})
S4-dedthm (S4-var (pop x)) = S4-MP S4-k (S4-var x)
S4-dedthm S4-k = S4-MP S4-k S4-k
S4-dedthm S4-s = S4-MP S4-k S4-s
S4-dedthm (S4-MP d d₁) = S4-MP (S4-MP S4-s (S4-dedthm d)) (S4-dedthm d₁)
S4-dedthm (S4-NEC d) = S4-MP S4-k (S4-NEC d)
S4-dedthm S4-prod1 = S4-MP S4-k S4-prod1
S4-dedthm S4-prod2 = S4-MP S4-k S4-prod2
S4-dedthm S4-prod3 = S4-MP S4-k S4-prod3
S4-dedthm S4-axK = S4-MP S4-k S4-axK
S4-dedthm S4-ax4 = S4-MP S4-k S4-ax4
S4-dedthm S4-axT = S4-MP S4-k S4-axT

                       
-- Admissibility of Scott's rule.

S4-Scott : ∀ {Γ : Cx modal} {A : Ty modal}

          → ThmS4 Γ A
    ------------------------
    → ThmS4 (boxcx Γ) (□ A)
                 
S4-Scott (S4-var x) = S4-var (box∈cx x)
S4-Scott S4-k = S4-NEC S4-k
S4-Scott S4-s = S4-NEC S4-s
S4-Scott (S4-MP d e) =
  let x = S4-Scott d in
  let y = S4-Scott e in
    S4-MP (S4-MP S4-axK x) y
S4-Scott (S4-NEC d) = S4-NEC (S4-NEC d)
S4-Scott S4-prod1 = S4-NEC S4-prod1
S4-Scott S4-prod2 = S4-NEC S4-prod2
S4-Scott S4-prod3 = S4-NEC S4-prod3
S4-Scott S4-axK = S4-NEC S4-axK
S4-Scott S4-ax4 = S4-NEC S4-ax4
S4-Scott S4-axT = S4-NEC S4-axT


-- Admissibility of the Four rule and its variant.

S4-Four : ∀ {Γ : Cx modal} {A : Ty modal}

     → ThmS4 (boxcx Γ) A
   ------------------------
   → ThmS4 (boxcx Γ) (□ A)

S4-Four {·} (S4-var p) = S4-NEC (S4-var p)
S4-Four {Γ , A} (S4-var top) = S4-MP S4-ax4 (S4-var top)
S4-Four {Γ , A} (S4-var (pop p)) =
  S4-weak (weakone subsetid) (S4-Four {Γ} (S4-var p))
S4-Four S4-k = S4-NEC S4-k
S4-Four S4-s = S4-NEC S4-s
S4-Four (S4-MP p p₁) = S4-MP (S4-MP S4-axK (S4-Four p)) (S4-Four p₁)
S4-Four (S4-NEC p) = S4-NEC (S4-NEC p)
S4-Four S4-prod1 = S4-NEC S4-prod1
S4-Four S4-prod2 = S4-NEC S4-prod2
S4-Four S4-prod3 = S4-NEC S4-prod3
S4-Four S4-axK = S4-NEC S4-axK
S4-Four S4-ax4 = S4-NEC S4-ax4
S4-Four S4-axT = S4-NEC S4-axT


S4-normal4-ded : ∀ {Γ : Cx modal} {A : Ty modal}

   → ThmS4 (boxcx Γ ++ Γ) A
   --------------------------
   → ThmS4 (boxcx Γ) (□ A)

S4-normal4-ded {·} (S4-var x) = S4-NEC (S4-var x)
S4-normal4-ded {Γ , A} (S4-var top) = S4-var top
S4-normal4-ded {Γ , A} (S4-var (pop x))
  with subsetdef x (swap-out (boxcx Γ) Γ (□ A))
... | top = S4-MP S4-ax4 (S4-var top)
... | pop q = S4-weak (concat-subset-1 (boxcx Γ) (· , □ A))
                (S4-normal4-ded (S4-var q))      
S4-normal4-ded S4-k = S4-NEC S4-k
S4-normal4-ded S4-s = S4-NEC S4-s
S4-normal4-ded (S4-MP d d₁) = S4-MP (S4-MP S4-axK (S4-normal4-ded d)) (S4-normal4-ded d₁)
S4-normal4-ded (S4-NEC d) = S4-NEC (S4-NEC d)
S4-normal4-ded S4-prod1 = S4-NEC S4-prod1
S4-normal4-ded S4-prod2 = S4-NEC S4-prod2
S4-normal4-ded S4-prod3 = S4-NEC S4-prod3
S4-normal4-ded S4-axK = S4-NEC S4-axK
S4-normal4-ded S4-ax4 = S4-NEC S4-ax4
S4-normal4-ded S4-axT = S4-NEC S4-axT


-- Admissibility of the T rule.

S4-ruleT : ∀ {Γ : Cx modal} {A : Ty modal}

        → ThmS4 Γ A
    --------------------
    → ThmS4 (boxcx Γ) A

S4-ruleT (S4-var x) = S4-MP S4-axT (S4-var (box∈cx x))
S4-ruleT S4-k = S4-k
S4-ruleT S4-s = S4-s
S4-ruleT (S4-MP p q) = S4-MP (S4-ruleT p) (S4-ruleT q)
S4-ruleT (S4-NEC p) = S4-NEC p
S4-ruleT S4-prod1 = S4-prod1
S4-ruleT S4-prod2 = S4-prod2
S4-ruleT S4-prod3 = S4-prod3
S4-ruleT S4-axK = S4-axK
S4-ruleT S4-ax4 = S4-ax4
S4-ruleT S4-axT = S4-axT


-- Admissibility of the cut rule.

S4-cut : ∀ {Γ : Cx modal} {A B : Ty modal}

   → ThmS4 Γ A    → ThmS4 (Γ , A) B
   -----------------------------------
             → ThmS4 Γ B
                    
S4-cut d (S4-var top) = d
S4-cut d (S4-var (pop x)) = S4-var x
S4-cut d S4-k = S4-k
S4-cut d S4-s = S4-s
S4-cut d (S4-MP e e₁) = S4-MP (S4-cut d e) (S4-cut d e₁)
S4-cut d (S4-NEC e) = S4-NEC e
S4-cut d S4-prod1 = S4-prod1
S4-cut d S4-prod2 = S4-prod2
S4-cut d S4-prod3 = S4-prod3
S4-cut d S4-axK = S4-axK
S4-cut d S4-ax4 = S4-ax4
S4-cut d S4-axT = S4-axT

