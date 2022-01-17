From Coq Require Import Arith.Arith.
From Coq Require Import Arith.EqNat.
From Coq Require Import Arith.PeanoNat. Import Nat.
From Coq Require Import omega.Omega.
From Coq Require Import Lists.List.
From Coq Require Import Bool.Bool.
From Coq Require Import Reals.Reals. Import Rdefinitions. Import RIneq.
From Coq Require Import ZArith.Zdiv.
From Coq Require Import ZArith.Int.
From Coq Require Import ZArith.Znat.
From Coq Require Import Setoids.Setoid.
From Coq Require Import Logic.FunctionalExtensionality.
From Coq Require Import Classes.Morphisms.

From ATL Require Import Tactics.

Set Warnings "-omega-is-deprecated,-deprecated".

Open Scope Z_scope.

Definition div_ceil (n d : Z) : Z := (n + d - 1) / d.
  
Notation "a // b" := (div_ceil a b) (at level 10, left associativity).

Theorem zero_div : forall n, 0 < n -> 0 // n = 0.
Proof.
  intros.
  apply Zdiv_small.
  omega.
Qed.

Theorem div_zero : forall n, n // 0 = 0.
Proof.  intros. unfold div_ceil. apply Zdiv_0_r. Qed.

Definition div_ceil_n (n d : nat) : nat := ((n + d - 1) / d)%nat.

Notation "a //n b" := (div_ceil_n a b) (at level 10, left associativity).
Arguments div_ceil_n : simpl never.

Theorem of_nat_div_distr : forall n c,
    (Z.of_nat n) // (Z.of_nat c) = Z.of_nat ( n //n c).
Proof.
  intros.
  destruct c.
  - rewrite div_zero. reflexivity.
  - unfold div_ceil, div_ceil_n.
    rewrite <- Nat2Z.inj_add.
    replace 1 with (Z.of_nat (S O)) by reflexivity.
    rewrite <- Nat2Z.inj_sub by omega.
    rewrite <- div_Zdiv by omega.
    reflexivity.
Qed.

Theorem znat_id_distr : forall n c,
    (Z.to_nat (Z.of_nat n // (Z.of_nat c))) =
    (Z.to_nat (Z.of_nat n)) //n (Z.to_nat (Z.of_nat c)).
Proof.
  intros.
  rewrite of_nat_div_distr.
  repeat rewrite Nat2Z.id.
  reflexivity.
Qed.
      
Theorem mul_add_lt : forall i j n m,
    0 <= i ->
    i < n ->
    0 <= j ->
    j < m ->
    i * m + j < n * m.
Proof.
  intros.
  assert (i*m <= (n-1) * m).
  {
    apply Z.mul_le_mono_nonneg_r. omega. omega.
  }
  assert ((n-1)*m + j < (n-1)*m + m).
  {
    apply Zplus_lt_compat_l. auto.
  }
  assert (i*m + j <= (n-1)*m + j).
  {
    apply Zplus_le_compat_r. auto.
  }
  eapply Z.le_lt_trans.
  apply H5.
  rewrite Zmult_succ_l_reverse in H4.
  assert (Z.succ (n-1) = n). omega.
  rewrite H6 in H4. auto.
Qed.

Close Scope Z_scope.

Theorem nat_mul_div_id : forall n m,
    0 < m ->
    (n * m) //n m = n.
Proof.
  intros.
  unfold div_ceil_n.
  rewrite <- add_sub_assoc by omega.
  rewrite div_add_l by omega.
  rewrite div_small. omega. omega.
Qed.

Theorem ndiv_pos : forall n m,
    0 < n ->
    0 < m ->
    0 < n //n m .
Proof.
  intros.
  unfold "_ //n _".
  destruct n. omega.
  simpl.
  rewrite sub_0_r.
  apply div_str_pos.
  omega.
Qed.
Hint Extern 1 (0 < _ //n _) => apply ndiv_pos : crunch.

Theorem div_pos : forall n m,
    (0 < n)%Z ->
    (0 < m)%Z ->
    (0 < n // m)%Z.
Proof.
  intros. unfold div_ceil.
  apply Z.div_str_pos. omega.
Qed.
Hint Extern 1 ((0 < _ // _)%Z) => apply div_pos : crunch.

Theorem div_nonneg : forall n m,
    (0 <= n)%Z ->
    (0 < m)%Z ->
    (0 <= n // m)%Z.
Proof.
  intros. unfold div_ceil.
  apply Z.div_pos; omega.
Qed.
Hint Extern 1 ((0 <= _ // _)%Z) => apply div_nonneg : crunch.

Lemma of_nat_nonneg : forall x,
    (0 <= Z.of_nat x)%Z.
Proof.
  intros. zify. omega.
Qed.
Hint Extern 1 ((0 <= _)%Z) => apply of_nat_nonneg : crunch.

Lemma znat_lt : forall x n,
    (0 <= x)%Z ->
    (x < Z.of_nat n)%Z ->
    Z.to_nat x < n.
Proof.
  intros.
  zify. omega.
Qed.                   

Hint Extern 5 (Z.to_nat _ < _) => apply znat_lt : crunch.

Lemma pos_nat_succ : forall p, exists n, Pos.to_nat p = S n.
Proof.
  intros p.
  specialize (Pos2Nat.is_pos p); intros.
  destruct (Pos.to_nat p); try omega; eauto.
Qed.

Ltac posnat :=
  match goal with
  | [ |- context[Pos.to_nat ?p] ] => specialize (pos_nat_succ p);
                                     intros [pn Hpos]; rewrite Hpos
  end.

Lemma znat_0lt : forall x, (0 < x)%Z -> 0 < (Z.to_nat x).
Proof.
  intros. zify. omega.
Qed.

Hint Resolve znat_0lt : crunch.

Lemma natz_0lt : forall x, 0 < x -> (0 < (Z.of_nat x))%Z.
Proof.
  intros. zify. omega.
Qed.

Hint Resolve natz_0lt : crunch.

Lemma weaker_Z2Nat_injlt : forall i j,
    Z.to_nat i < Z.to_nat j ->
    (0 <= i)%Z ->
    (i < j)%Z.
Proof.
  intros. destruct j eqn:e.
  - simpl in *. omega.
  - rewrite <- e in *.
    apply Z2Nat.inj_lt in H; auto.
    subst.
    apply Zle_0_pos.
  - simpl in *. omega.
Qed.

Lemma factor_unique : forall i i0 i1 i2 m,
    (0 <= i0 < m)%Z ->
    (0 <= i2 < m)%Z ->    
    ((i * m + i0 =? i1 * m + i2)%Z =
     (i=?i1)%Z && (i0=?i2)%Z).
Proof.
  intros.
  unbool.  
  split; intros.  
  - eapply Z.div_mod_unique.
    left.
    eauto.
    left.
    omega.
    rewrite Z.mul_comm. rewrite H1. rewrite Z.mul_comm. reflexivity.
  - destruct H1. subst. reflexivity.
Qed.  

Lemma div_eucl_div : forall a b,
    (b > 0)%Z ->
    let (q,_) := Z.div_eucl a b in
    q = (a / b)%Z.
Proof.
  intros.
  pose (Z_div_mod a b). peel_hyp.
  destruct (Z.div_eucl a b) eqn:e. destruct y.
  subst.
  rewrite Z.add_comm.
  rewrite Z.mul_comm.
  rewrite Z_div_plus by auto.
  rewrite Zdiv_small; auto.
Qed.  

Lemma mul_lt : forall z k x,
  (0 <= z < k)%Z ->
  ((z < k * x)%Z <-> (0 < x)%Z).
Proof.
  intros.
  split; intros.
  - destruct x. omega. zomega. 
    assert (0 < k * Z.neg p)%Z by omega.
    assert (0 < k)%Z by omega.
    apply Z.lt_0_mul in H1.
    omega.
  - destruct x; zify; try omega.
    assert (1 <= Z.pos p )%Z by (zify; omega).
    replace z with (z * 1)%Z by omega.
    destruct (1 =? Z.pos p)%Z eqn:ee; unbool.
    * rewrite <- ee.
      omega.
    * assert (1 < Z.pos p)%Z by omega.
      apply Z.mul_lt_mono_nonneg; try omega.
Qed.

Lemma mul_le : forall z k x,
    (0 <= z < k)%Z ->
    (k * x <= z <-> x <= 0)%Z.
Proof.
  intros.
  split; intros.
  - destruct x; zify; try omega.
    assert (k < k * Z.pos p)%Z.
    assert (1 <= Z.pos p )%Z by (zify; omega).
    destruct (1 =? Z.pos p)%Z eqn:ee; unbool.
    + rewrite <- ee in *. rewrite Z.mul_1_r in *. omega.
    + assert (1 < Z.pos p)%Z by omega.
      replace k with (k * 1)%Z at 1 by omega.
      apply Zmult_lt_compat_l; omega.
    + omega.
  - destruct (x =? 0)%Z eqn:ee; unbool.
    + subst. rewrite Z.mul_0_r. omega.
    + assert (x < 0)%Z by omega.
      assert (k * x < 0)%Z.
      apply Z.mul_pos_neg; omega.
      omega.
Qed.

Lemma floor_lt_ceil : forall x y,
    (0 <= x)%Z ->
    (0 < y)%Z ->
    (x / y <= x // y)%Z.
Proof.
  intros.
  unfold div_ceil.
  apply Z_div_le. omega. omega.
Qed.

Lemma div_eq_num_diff : forall a b c,
    (0 <= a)%Z ->
    (0 <= b)%Z ->
    (0 < c)%Z ->
    (a / c = b / c)%Z ->
    (a < b)%Z ->
    (b - a < c)%Z.
Proof.
  intros.
  pose (Z_div_mod a c). peel_hyp.
  pose (Z_div_mod b c). peel_hyp.
  destruct (Z.div_eucl a c).
  destruct (Z.div_eucl b c).
  destruct y. destruct y0. subst.
  rewrite Z.sub_add_distr.
  repeat rewrite (Z.mul_comm c) in H2.
  repeat rewrite Z.div_add_l in H2 by omega.
  repeat rewrite Z.div_small in H2 by omega.
  repeat rewrite Z.add_0_r in H2.
  subst. omega.
Qed.

Lemma floor_lt_ceil_mono_l : forall i k n,
    (0 <= i)%Z ->
    (i < n)%Z ->
    (0 < k)%Z ->
    (0 < n)%Z ->
    (i / k < n // k)%Z.
Proof.
  intros. unfold div_ceil.
  pose proof (Z.div_le_mono i (n+k-1)%Z k). peel_hyp; try omega.
  destruct (i / k =? (n + k - 1) / k)%Z eqn:e; unbool.
  - rewrite <- e in *. clear H3.
    apply div_eq_num_diff in e; try omega.
  - omega.
Qed.
Hint Resolve floor_lt_ceil_mono_l : crunch.

Lemma floor_lt_nat_ceil_mono_l : forall i k n,
    (0 <= i)%Z ->
    (i < Z.of_nat n)%Z ->
    0 < k ->
    0 < n ->
    (i / Z.of_nat k < Z.of_nat (n //n k))%Z.
Proof.
  intros.
  rewrite <- of_nat_div_distr.
  apply floor_lt_ceil_mono_l; auto with crunch.
Qed.
Hint Resolve floor_lt_nat_ceil_mono_l : crunch.

Theorem pos_zofnat : forall n,
    0 < n ->
    (0 < Z.of_nat n)%Z.
Proof. intros. omega. Qed.
Hint Resolve pos_zofnat : crunch.
Hint Resolve Z.div_pos : crunch.

Lemma expand_Zmod : forall i m,
    (0 < m)%Z ->
    (i - i / m * m = Zmod i m)%Z.
Proof.
  intros. unfold Zmod.
  pose proof (Z_div_mod i m).
  assert (m > 0)%Z by omega.
  apply H0 in H1.
  destruct (Z.div_eucl i m) eqn:e.
  destruct H1.
  rewrite H1.
  rewrite Z.mul_comm.
  rewrite Z_div_plus_full_l by omega.
  rewrite Zdiv_small by omega.
  rewrite Z.add_0_r. omega.
Qed.

Lemma div_ceil_n_lower_bound : forall n k,
    0 < k ->
    n <= n //n k * k.
Proof.
Admitted.
Hint Resolve div_ceil_n_lower_bound : crunch.

Lemma mod_upper_bound : forall k i,
    (0 < k)%Z ->
    (i mod k < k)%Z.
Proof.
  intros.
  pose proof (Z.mod_pos_bound i k).
  peel_hyp. omega.
Qed.

Lemma mod_nonneg : forall k i,
    (0 < k)%Z ->
    (0 <= i mod k)%Z.
Proof.
  intros.
  pose proof (Z.mod_pos_bound i k).
  peel_hyp. omega.
Qed.  

Hint Resolve mod_upper_bound mod_nonneg : crunch.

Theorem div_mod_eq : forall i k,
    (0 < k)%Z ->
    (i / k * k + i mod k = i)%Z.
Proof.
  intros.
  rewrite <- expand_Zmod by omega.
  rewrite Zplus_minus.
  reflexivity.
Qed.

Lemma gt_add_r : forall k a b,
    (0 <= a)%Z ->
    (k <= b)%Z ->
    (k <= a + b)%Z.
Proof. intros. omega. Qed.

Hint Resolve Z.max_lub Z.min_glb Z.le_max_l Z.le_min_r Z.le_min_l : crunch.

Lemma split_floor_rest_nonneg : forall m k,
    (0 < m)%Z ->
    (0 < k)%Z ->
    (0 < m / k + (m mod k) // k)%Z.
Proof.
Admitted.

Lemma floor_div_mul_lt : forall n k i0 i1,
    (0 <= i0)%Z ->
    (i0 < n / k)%Z ->
    (0 <= i1)%Z ->
    (i1 < k)%Z ->
    (i0 * k + i1 < n)%Z.
Proof.
Admitted.

Hint Resolve floor_div_mul_lt split_floor_rest_nonneg Z.div_pos  : crunch.

Lemma ceil_floor_mod : forall n k,
    (0 <= n)%Z ->
    (0 < k)%Z ->
    (n//k = n/k + ((n mod k) // k))%Z.
Proof.
Admitted.

