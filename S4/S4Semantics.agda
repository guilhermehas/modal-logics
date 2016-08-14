module S4.S4Semantics where

infixl 0 _/_⊢_/_

open import Basics
open import Data.Nat using (ℕ ; zero ; suc)
open import Data.Product renaming (_,_ to pair)
open import Data.Sum renaming (_⊎_ to _+_)
open import S4.DualS4

data One : Set where
  one : One

data Ne (Δ Γ : Cx modal) : (A : Ty modal) -> Set where

  DS4-ne-var : ∀ {A}
  
    -> (p : A ∈ Γ)
    --------------
     -> Ne Δ Γ A

  DS4-ne-modal-var : ∀ {A}
  
    -> (p : A ∈ Δ)
    ------------------------
    -> Ne Δ Γ A

  DS4-ne-app : ∀ {A B}

    -> Ne Δ Γ (A => B)    -> Δ / Γ ⊢ A
    -----------------------------------
              -> Ne Δ Γ B

  DS4-ne-prod2 : ∀ {A B}

    -> Ne Δ Γ (A ∧ B)
    -----------------
       -> Ne Δ Γ A

  DS4-ne-prod3 : ∀ {A B}

    -> Ne Δ Γ (A ∧ B)
    -----------------
      -> Ne Δ Γ B

  DS4-ne-boxE : ∀ {A C}

    -> Ne Δ Γ (□ A)    ->  (Δ , A) / Γ ⊢ C
    --------------------------------------
               -> Ne Δ Γ C


data Nf (Δ Γ : Cx modal) : (A : Ty modal) -> Set where


  DS4-nf-ne : ∀ {A}

    -> Ne Δ Γ A
    -----------
    -> Nf Δ Γ A


  DS4-nf-lam : ∀ {A B}

    -> Nf Δ (Γ , A) B
    -----------------
    -> Nf Δ Γ (A => B)

  DS4-nf-prod1 : ∀ {A B}

    ->  Nf Δ Γ A    -> Nf Δ Γ B
    ---------------------------
       ->  Nf Δ Γ (A ∧ B)

  DS4-nf-boxI : ∀ {A}

      -> Nf Δ · A
    ---------------
    -> Nf Δ Γ (□ A)


insert-ne : ∀ {Δ Γ A} -> Ne Δ Γ A -> Δ / Γ ⊢ A
insert-ne (DS4-ne-var p) = DS4-var p
insert-ne (DS4-ne-modal-var p) = DS4-modal-var p
insert-ne (DS4-ne-app p q) = DS4-app (insert-ne p) q
insert-ne (DS4-ne-prod2 p) = DS4-prod2 (insert-ne p)
insert-ne (DS4-ne-prod3 p) = DS4-prod3 (insert-ne p)
insert-ne (DS4-ne-boxE p q) = DS4-boxE (insert-ne p) q

insert-nf : ∀ {Δ Γ A} -> Nf Δ Γ A -> Δ / Γ ⊢ A
insert-nf (DS4-nf-ne x) = insert-ne x
insert-nf (DS4-nf-lam p) = DS4-lam (insert-nf p)
insert-nf (DS4-nf-prod1 p p₁) = DS4-prod1 (insert-nf p) (insert-nf p₁)
insert-nf (DS4-nf-boxI p) = DS4-boxI {!!}

ne-weak : ∀ {Δ Γ Γ' A} -> Ne Δ Γ A -> Γ ⊆ Γ' -> Ne Δ Γ' A
ne-weak (DS4-ne-var p) q = DS4-ne-var (q p)
ne-weak (DS4-ne-modal-var p) q = DS4-ne-modal-var p
ne-weak (DS4-ne-app p x) q = DS4-ne-app (ne-weak p q) (DS4-weak-many x q)
ne-weak (DS4-ne-prod2 p) q = DS4-ne-prod2 (ne-weak p q)
ne-weak (DS4-ne-prod3 p) q = DS4-ne-prod3 (ne-weak p q)
ne-weak (DS4-ne-boxE p x) q = DS4-ne-boxE (ne-weak p q) (DS4-weak-many x q)

-- Applicatives & Comonads

data Applicative (Q : Set -> Set) : Set1 where
  applicative : (k : {A B : Set} -> Q (A -> B) -> Q A -> Q B) -> Applicative Q

appl : {Q : Set -> Set} -> Applicative Q -> {A B : Set} -> Q (A -> B) -> Q A -> Q B
appl (applicative k) = k

data Comonad (Q : Set -> Set) : Set1 where
  comonad : (extract : {A : Set} -> Q A -> A) ->
            (extend : {A B : Set} -> Q A -> (Q A -> B) -> Q B) ->
            Comonad Q

cextr : {Q : Set -> Set} -> Comonad Q -> {A : Set} -> Q A -> A
cextr (comonad extract extend) = extract

cext : {Q : Set -> Set} -> Comonad Q -> {A B : Set} -> Q A -> (Q A -> B) -> Q B
cext (comonad extract extend) = extend

record NeutralTermInContext : Set where
  constructor Term
  field
    mdctx : Cx modal
    smctx : Cx modal
    type : Ty modal
    t : Ne mdctx smctx (□ type)

data Q : Set -> Set where
  end  : ∀ {A} -> A -> Q A
  letb : ∀ {A} ->  NeutralTermInContext -> Q A -> Q A

cm : Comonad Q
cm  = comonad extr ext
             where extr : {A : Set} -> Q A -> A
                   extr (end x) = x
                   extr (letb x y) = extr y
                   ext : {A B : Set} -> Q A -> (Q A -> B) -> Q B
                   ext x f = end (f x)
  

-- Semantics


[[_]] : Ty modal -> Cx modal -> Cx modal -> Set
[[ P x ]] Δ Γ = Ne Δ Γ (P x)
[[ A => B ]] Δ Γ = ∀ {Γ'} -> Γ ⊆ Γ' -> [[ A ]] Δ Γ' -> [[ B ]] Δ Γ'
[[ A ∧ B ]] Δ Γ = [[ A ]] Δ Γ × [[ B ]] Δ Γ
[[ □ A ]] Δ Γ = Q ([[ A ]] Δ ·)

rename : ∀ {Δ Γ Γ'} -> (A : Ty modal) -> Γ ⊆ Γ' -> [[ A ]] Δ Γ -> [[ A ]] Δ Γ'
rename (P i) p x = ne-weak x p
rename (A => B) = {!!} -- p x q z = {!!} x (incl-trans p q) z
rename (A ∧ B) p x = {!!} -- pair (rename A p (proj₁ x)) (rename B p (proj₂ x))
rename (□ A) p x = {!!} -- x

data _/_⊢_/_ :  Cx modal -> Cx modal -> Cx modal -> Cx modal -> Set where
  empty : ∀ {Δ Γ} -> Δ / Γ ⊢ · / ·
  right : ∀ {Δ Γ Η Θ A} -> (Δ / Γ ⊢ Η / Θ) -> [[ A ]] Δ Γ -> (Δ / Γ ⊢ Η / Θ , A)
  left : ∀ {Δ Γ Η Θ A} -> (Δ / Γ ⊢ Η / Θ) -> Q([[ A ]] Δ ·) -> (Δ / Γ ⊢ Η , A / Θ)

get-env : ∀ {Δ Γ Θ Η A} -> Δ / Γ ⊢ Θ / Η -> A ∈ Η -> [[ A ]] Δ Γ

get-env (right E x) top = x
get-env (left E x) top = get-env E top
get-env (right E x) (pop p) = get-env E p
get-env (left E x) (pop p) = get-env E (pop p)

get-env-modal : ∀ {Δ Γ Θ Η A} -> Δ / Γ ⊢ Θ / Η -> A ∈ Θ -> Q([[ A ]] Δ ·)
get-env-modal (right E x) top = get-env-modal E top
get-env-modal (left E x) top = {!x!}
get-env-modal (right E x) (pop p) = get-env-modal E (pop p)
get-env-modal (left E x) (pop p) = get-env-modal E p

env-weak : ∀ {Δ Γ Γ' Η Θ} -> (Δ / Γ ⊢ Η / Θ) -> (Γ ⊆ Γ') -> (Δ / Γ' ⊢ Η / Θ)
env-weak empty p = empty
env-weak (right {A = A} E x) p = right (env-weak E p) (rename A p x)
env-weak (left E x) p = {!!} -- left (env-weak E p) (inj₁ x)

keep-only-modal : ∀ {Δ Γ Η Θ} -> (Δ / Γ ⊢ Η / Θ) -> (Δ / · ⊢ Η / ·)
keep-only-modal empty = empty
keep-only-modal (right E x) = keep-only-modal E
keep-only-modal (left E x) = left (keep-only-modal E) x


sem : ∀ {Δ Γ Θ Η A} -> Θ / Η ⊢ A -> (E : Δ / Γ ⊢ Θ / Η) -> [[ A ]] Δ Γ

sem (DS4-var x) E = get-env E x
sem {Δ} {Γ} {A = A} (DS4-modal-var x) E = {!!} -- rename {Δ} {·} {Γ} A subsetempty (get-env-modal E x)
sem {Δ} {Γ} (DS4-app p q) E = sem p E (subsetid _) (sem q E)
sem (DS4-lam p) E = {!!}
sem (DS4-prod1 p q) E = pair (sem p E) (sem q E)
sem (DS4-prod2 p) E = proj₁ (sem p E)
sem (DS4-prod3 p) E = proj₂ (sem p E)
sem (DS4-boxI p) E = end (sem p (keep-only-modal E))
sem (DS4-boxE p q) E = sem q (left E (sem p E))


reify :  ∀ {Δ Γ A} -> [[ A ]] Δ Γ  -> Nf Δ Γ A
reflect : ∀ {Δ Γ A} -> Ne Δ Γ A -> [[ A ]] Δ Γ

reify {A = P x} e = DS4-nf-ne e
reify {Δ} {Γ} {A = A => B} e =
  DS4-nf-lam (reify (e (weakone (subsetid _)) (reflect {Δ} {Γ , A} {A} (DS4-ne-var top))))
reify {A = A ∧ B} e = DS4-nf-prod1 (reify (proj₁ e)) (reify (proj₂ e))
reify {A = □ A} e = DS4-nf-boxI (reify (cextr cm e)) -- (reify (cextr cm e))

reflect {A = P x} m = m
reflect {A = A => B} m p x = reflect (DS4-ne-app (ne-weak m p) (insert-nf (reify x)))
reflect {A = A ∧ B} m = pair (reflect (DS4-ne-prod2 m)) (reflect (DS4-ne-prod3 m))
reflect {A = □ A} m = {!!}