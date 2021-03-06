(* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)

(* :Title: FourLaplacian*)

(* :Author: Rolf Mertig *)

(* ------------------------------------------------------------------------ *)
(* :History: File created on 22 June '97 at 22:59 *)
(* ------------------------------------------------------------------------ *)

(* ------------------------------------------------------------------------ *)

FourLaplacian::usage = "FourLaplacian[exp, p, q] is d/dp_mu d/dq_mu exp.";

(* ------------------------------------------------------------------------ *)

Begin["`Package`"]
End[]

Begin["`FourLaplacian`Private`"]

Options[FourLaplacian] = {Dimension -> D};

FourLaplacian[x_, i_, j_, opt___Rule] :=
	FourLaplacian[x,
		Momentum[i, Dimension /. {opt} /. Options[FourLaplacian]] ,
		Momentum[j, Dimension /. {opt} /. Options[FourLaplacian]] ,
		opt        ] /; (Head[i] =!= Momentum) &&
						(Head[j] =!= Momentum);

FourLaplacian[x_, i_Momentum, j_Momentum, opt___Rule] :=
	FourDivergence[
	FourDivergence[ChangeDimension[x//FeynCalcInternal,
						Dimension /. {opt} /. Options[FourLaplacian]
						] , Pair[i,
		LorentzIndex[muu,  Dimension /. {opt} /. Options[FourLaplacian]]
								]
					],  Pair[j,
		LorentzIndex[muu,  Dimension /. {opt} /. Options[FourLaplacian]]
							]
					];

FCPrint[1,"FourLaplacian.m loaded."];
End[]
