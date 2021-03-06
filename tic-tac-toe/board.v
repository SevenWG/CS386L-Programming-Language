(******************************)
(*  Definitions of the Board  *)
(*  Author: Shuangquan Feng   *)
(*  Date:    Apr 29. 2018     *)
(******************************)

(* Possible symbols on the board: X O and E(mpty) *)
Inductive sym : Type:= 
  | X : sym
  | O : sym
  | E : sym.

(* two symbols are the same *)
Inductive sym_eq: sym->sym->Prop :=
  | eqX : sym_eq X X
  | eqO : sym_eq O O
  | eqE : sym_eq E E.

Definition beq_sym (x y:sym) : bool :=
  match x,y with
  | X,X
  | O,O
  | E,E => true
  | _,_ =>false
  end.

(* symbol equals Empty *)
Definition beq_E (x:sym) :bool := beq_sym x E.

Hint Constructors sym.

(* a board has nine symbols *)
Inductive board: Type :=
  | bd:sym->sym->sym->sym->sym->sym->sym->sym->sym->board.

Definition empty_board:=
  bd E E E E E E E E E.

(* nine cell names of the board *)
Inductive cell: Type :=
  | c00 : cell
  | c01 : cell
  | c02 : cell
  | c10 : cell
  | c11 : cell
  | c12 : cell
  | c20 : cell
  | c21 : cell
  | c22 : cell.

(* two cell names are equal *)
Inductive cell_eq: cell->cell->Prop :=
  | eq00: cell_eq c00 c00
  | eq01: cell_eq c01 c01
  | eq02: cell_eq c02 c02
  | eq10: cell_eq c10 c10
  | eq11: cell_eq c11 c11
  | eq12: cell_eq c12 c12
  | eq20: cell_eq c20 c20
  | eq21: cell_eq c21 c21
  | eq22: cell_eq c22 c22.

Definition isE (b:board) (c:cell):Prop :=
  match b with
  | bd s00 s01 s02 s10 s11 s12 s20 s21 s22=>
    match c with
    | c00 => sym_eq s00 E
    | c01 => sym_eq s01 E
    | c02 => sym_eq s02 E
    | c10 => sym_eq s10 E
    | c11 => sym_eq s11 E
    | c12 => sym_eq s12 E
    | c20 => sym_eq s20 E
    | c21 => sym_eq s21 E
    | c22 => sym_eq s22 E
    end
  end.

(* one step made by a player,
   pick a cell, put a symbol(X or O) *)
Inductive step: Type := 
  | st : cell->sym->step.

(* a round consists of two steps, one for each player.
   For a round to be valid, following conditions should be met *)
Definition valid_round (b:board) (x y:step): Prop :=
  match x,y with
  | st c1 s1, st c2 s2 =>
  (sym_eq s1 X) /\ (sym_eq s2 O)  (*P1 put X, P2 put O *)
  /\ (not (cell_eq c1 c2))        (*not put in a same cell*)
  /\ (isE b c1) /\ (isE b c2)     (*both cells are initially empty*)
  end.

(* In case P1 only needs one step to win
   so this only apply to X. *)
Definition valid_move (b:board) (x:step): Prop :=
  match x with
  | st c s => (sym_eq s X) /\ (isE b c)
  end.

(* Change the states of the board according to the step 
   just change the corresponding symbol *)
Definition move (b:board) (st:step): board :=
  match st,b with
  | st c x,
    bd s00 s01 s02 s10 s11 s12 s20 s21 s22=>
    match c with
    | c00 => bd x s01 s02 s10 s11 s12 s20 s21 s22
    | c01 => bd s00 x s02 s10 s11 s12 s20 s21 s22
    | c02 => bd s00 s01 x s10 s11 s12 s20 s21 s22
    | c10 => bd s00 s01 s02 x s11 s12 s20 s21 s22
    | c11 => bd s00 s01 s02 s10 x s12 s20 s21 s22
    | c12 => bd s00 s01 s02 s10 s11 x s20 s21 s22
    | c20 => bd s00 s01 s02 s10 s11 s12 x s21 s22
    | c21 => bd s00 s01 s02 s10 s11 s12 s20 x s22
    | c22 => bd s00 s01 s02 s10 s11 s12 s20 s21 x
    end
  end.

(* possible state of the board *)
Inductive state : Type :=
  | win : state        (* P1(X) wins, P2(O) loses *)
  | lose: state        (* P1(X) loses, P2(O) wins *)
  | tie : state        (* no one wins, no empty cells to proceed *)
  | incomplete: state. (* no one wins yet, still has empty cells *)

(* check if P1(X) wins *)
Definition final_x_win (b:board) : bool :=
  match b with
  | bd X _ _ X _ _ X _ _ => true
  | bd _ X _ _ X _ _ X _ => true
  | bd _ _ X _ _ X _ _ X => true
  | bd X X X _ _ _ _ _ _ => true
  | bd _ _ _ X X X _ _ _ => true
  | bd _ _ _ _ _ _ X X X => true
  | bd X _ _ _ X _ _ _ X => true
  | bd _ _ X _ X _ X _ _ => true
  | bd _ _ _ _ _ _ _ _ _ => false
  end.

(* check if P2(O) wins *)
Definition final_o_win (b:board) : bool :=
  match b with
  | bd O _ _ O _ _ O _ _ => true
  | bd _ O _ _ O _ _ O _ => true
  | bd _ _ O _ _ O _ _ O => true
  | bd O O O _ _ _ _ _ _ => true
  | bd _ _ _ O O O _ _ _ => true
  | bd _ _ _ _ _ _ O O O => true
  | bd O _ _ _ O _ _ _ O => true
  | bd _ _ O _ O _ O _ _ => true
  | bd _ _ _ _ _ _ _ _ _ => false
  end.

(* check if the board still has any empty cells *)
Definition has_empty (b:board) : bool :=
  match b with
  | bd s00 s01 s02 s10 s11 s12 s20 s21 s22=>
  if (beq_E s00) then true else 
  if (beq_E s01) then true else 
  if (beq_E s02) then true else 
  if (beq_E s10) then true else 
  if (beq_E s11) then true else 
  if (beq_E s12) then true else 
  if (beq_E s20) then true else 
  if (beq_E s21) then true else 
  if (beq_E s22) then true else false
  end.

(* get the state of the board *)
Definition get_state (b:board) : state :=
  (* check lose condition first, 
     in case there are both 3Xs and 3Os in a row,
     we should return lose.  *)
  if (final_o_win b) 
    then lose
  else if (final_x_win b)
    then win
  else if (has_empty b)
    then incomplete
  else
    tie.

(* one handy helper theorem *)
Theorem sym_eq_iff:
 forall (x y:sym),
  sym_eq x y -> x=y.
Proof.
  intros.
  induction H; reflexivity.
Qed.
