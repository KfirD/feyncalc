(* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)

(* :Title: QuarkPropagator *)

(* :Author: Rolf Mertig *)

(* ------------------------------------------------------------------------ *)

(* :Summary: QuarkPropagator *)

(* ------------------------------------------------------------------------ *)

QP::usage =
"QP is an alias for QuarkPropagator.
QP[p] is the massless quark propagator.
QP[{p,m}] gives the  quark propagator with mass m.";

QuarkPropagator::usage =
"QuarkPropagator[p] is the massless quark propagator.
QuarkPropagator[{p,m}] gives the  quark propagator with mass m.";

(* ------------------------------------------------------------------------ *)

Begin["`Package`"]
End[]

Begin["`QuarkPropagator`Private`"]

DeclareNonCommutative[QuarkPropagator];

Options[QuarkPropagator] = {
	CounterTerm -> False,
	CouplingConstant -> Gstrong,
	Dimension -> D,
	Explicit -> False,
	Loop -> 0,
	OPE -> False,
	Polarization -> 0
};

QP = QuarkPropagator;
Abbreviation[QuarkPropagator] = HoldForm[QP];

(*QuarkPropagator[a_, __, b_/;Head[b]=!=Rule, opt:OptionsPattern[]] :=
QuarkPropagator[a, opt];*)

QuarkPropagator[pi:Except[_?OptionQ], opt:OptionsPattern[]] :=
	QuarkPropagator[{pi,0}, opt]/; Head[pi]=!=List;

QuarkPropagator[{pi_, m_},  opt:OptionsPattern[]] :=
	Block[ {dim, re, ope, pol, cou, cop, loo},
		dim    = OptionValue[Dimension];
		ope    = OptionValue[OPE];
		pol    = OptionValue[Polarization];
		cou    = OptionValue[CounterTerm];
		cop    = OptionValue[CouplingConstant];
		loo    = OptionValue[Loop];
		(* one-loop expression *)
		If[ loo === 1 && m === 0,
			(-(Pair[Momentum[pi], Momentum[pi]]/ScaleMu^2))^(Epsilon/2)*
			(-I CF (2 - Epsilon) cop^2 Sn DiracGamma[Momentum[pi,dim],dim])/Epsilon,
			If[ ope =!= True,
				re = 0,
				re = OPE DOT[QuarkPropagator[{pi, m}, OPE -> False, opt],
					Twist2QuarkOperator[pi,Polarization -> pol],
					QuarkPropagator[{pi, m}, OPE -> False, opt]]
			];
			If[ (cou =!= False) && m === 0,
				Which[(cou === True) || ( cou === 1),
							re = re + I cop^2 Sn CF 2/Epsilon *
												DiracGamma[Momentum[pi,dim]],
							cou === All,
							re = re + CounterT Sn I cop^2 CF 2/Epsilon*
												DiracGamma[Momentum[pi,dim]]
				]
			];
			If[ !cou,
				re = re +
				I (DiracGamma[Momentum[pi, dim], dim]+m) FeynAmpDenominator[
				MomentumExpand[PropagatorDenominator[Momentum[pi,dim], m]]]
			];
			re
		]
	]/; OptionValue[Explicit];


QuarkPropagator /:
	MakeBoxes[QuarkPropagator[{p_,_}, OptionsPattern[]],
	TraditionalForm] :=
		RowBox[{SubscriptBox["\[CapitalPi]","q"],
		"(", TBox[p], ")"}];


(*
QuarkPropagator[{pi_, m_}, opt___Rule] :=  Block[{dim},
dim    = Dimension /. {opt} /. Options[QuarkPropagator];
	I (DiracGamma[Momentum[pi, dim], dim]+m) FeynAmpDenominator[
		MomentumExpand[
		PropagatorDenominator[Momentum[pi,dim], m]]]];
*)
FCPrint[1,"QuarkPropagator.m loaded"];
End[]
