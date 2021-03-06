(* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)

(* :Title: PartialFourVector *)

(* :Author: Rolf Mertig *)

(* ------------------------------------------------------------------------ *)
(* :History: File created on 22 June '97 at 23:00 *)
(* ------------------------------------------------------------------------ *)

(* ------------------------------------------------------------------------ *)



PartialFourVector::usage =
"PartialFourVector[exp, FourVector[p, mu]]
calculates the partial derivative of exp w.r.t. p(mu).
PartialFourVector[exp, FourVector[p, mu], FourVector[p,nu], ...]
gives the multiple derivative.";

(* ------------------------------------------------------------------------ *)

Begin["`Package`"]
End[]

Begin["`PartialFourVector`Private`"]

PartialFourVector[x_,a_,b__] :=
	PartialFourVector[PartialFourVector[x, a], b];

PartialFourVector[x_, fv_] :=
	Block[ {nx = x /. DiracGamma -> diga,ve = FeynCalcInternal[fv],p,mu,gpa,cont, tliflag = False},
		If[ !FreeQ[nx, TLI],
			nx = TLI2FC[nx];
			tliflag = True
		];
		nx = FeynCalcInternal[nx];
		ve = MomentumCombine[ve, LeafCount -> 1000];
		p  = Select[ve, Head[#] === Momentum&][[1]];
		If[ !FreeQ[p,Plus],
			nx = MomentumCombine[nx, LeafCount -> 1000]
		];
		mu = Select[ve, Head[#] === LorentzIndex&][[1]];
		If[ !FreeQ[nx, FeynAmpDenominator],
			nx = FeynAmpDenominatorSplit[nx]
		];
		nx = D[nx, p] /. Derivative -> deriv;
		nx = nx /. (deriv[1][FeynAmpDenominator][_]) :> 1 /.
							{deriv[1,0][PropagatorDenominator][pe_,b_] :>
								(-2 Pair[pe,mu] *
									FeynAmpDenominator[PropagatorDenominator[pe, b],
																		PropagatorDenominator[pe, b]
																		]
								),
								deriv[1, 0][Pair][p,  a_] :> Pair[a, mu] ,
								deriv[0, 1][Pair][a_, p] :> Pair[a, mu] ,
		deriv[1][diga][p] :> DiracGamma[mu] ,
								deriv[1,0,0,0][Eps][p,c__] :>
							Eps[mu,c] ,
								deriv[0,1,0,0][Eps][a_,p,c__] :>
							Eps[a,mu,c] ,
								deriv[0,0,1,0][Eps][a__,p,c_] :>
							Eps[a,mu,c] ,
								deriv[0,0,0,1][Eps][c__,p] :>
							Eps[c,mu]} /. deriv -> Derivative;
		nx = EpsEvaluate[nx];
		If[ !FreeQ[nx, FeynAmpDenominator],
			nx = FeynAmpDenominatorCombine[nx]
		];
		If[ tliflag===True && FreeQ[nx, LorentzIndex],
			nx = FC2TLI[nx, (Momentum/.Options[TLI2FC])[[1]],
											(Momentum/.Options[TLI2FC])[[2]]
									]
		];
		nx = Contract[nx /. diga->DiracGamma]// ExpandScalarProduct;
		If[ !FreeQ[nx, FeynAmpDenominator],
			nx = ScalarProductCancel[nx]
		];
		nx
	];

FCPrint[1,"PartialFourVector.m loaded."];
End[]
