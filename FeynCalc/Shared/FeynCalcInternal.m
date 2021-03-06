(* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)

(* :Title: FeynCalcInternal *)

(* :Author: Rolf Mertig *)

(* ------------------------------------------------------------------------ *)
(* :History: File created on 20 December '98 at 21:07 *)
(* ------------------------------------------------------------------------ *)

(* :Summary: Changes certain objects ("Symbols") into the FeynCalc
						internal representation *)

(* ------------------------------------------------------------------------ *)


FCI::usage=
"FCI is just an abbreviation of FeynCalcInternal.";

FeynCalcInternal::usage=
"FeynCalcInternal[exp] translates exp into the internal FeynCalc
representation. User defined rules can be given
by the option FinalSubstitutions.";

(* ------------------------------------------------------------------------ *)

Begin["`Package`"]
End[]

Begin["`FeynCalcInternal`Private`"]

FCI = FeynCalcInternal;

Options[FeynCalcInternal] = {FinalSubstitutions -> {}};

SetAttributes[FeynCalcInternal, HoldFirst];

sdeltacont[a_, b_] :=
	SUNDelta[SUNIndex[a], SUNIndex[b]];

sfdeltacont[a_, b_] :=
	SUNFDelta[SUNFIndex[a], SUNFIndex[b]];

tosund[a_,b_,c_] :=
	SUND[SUNIndex[a], SUNIndex[b], SUNIndex[c]];

sdeltacontr[a_, b_] :=
	SUNDeltaContract[SUNIndex[a], SUNIndex[b]];

sfdeltacontr[a_, b_] :=
	SUNFDeltaContract[SUNFIndex[a], SUNFIndex[b]];


FeynCalcInternal[x_, opts___Rule] :=
	Block[{ru, revru, uru},
		uru = FinalSubstitutions /. {opts} /. Options[FeynCalcInternal];
		uru = Flatten[{uru}];

		ru =  Join[
			{SpinorU :> tospinor},
			{SpinorV :> tospinorv},
			{SpinorVBar :> tospinorv},
			{SpinorUBar :> tospinor},
			{SUNF :> tosunf},
			{MetricTensor :> metricT},
			{DiracMatrix  :> diracM},
			{DiracSlash :> diracS},
			{FourVector :> fourV},
			{SD :> sdeltacont},
			{SDF :> sfdeltacont},
			{SUNDelta :> sdeltacont},
			{SUNFDelta :> sfdeltacont},
			{SUND :> tosund},
			{SUNDeltaContract :> sdeltacontr},
			{SUNFDeltaContract :> sfdeltacontr},
			{SUNT :> sunTint},
			{SUNTF :> sunTFint},
			{FAD :> fadint},
			{FVD :> fvd},
			{FVE :> fve},
			{FV :> fv},
			{LeviCivita :> levicivita},
			{LC :> lc},
			{LCD :> lcd},
			{MT :> mt},
			{MTD :> mtd},
			{MTE :> mte},
			{GA :> ga},
			{GAD :> gad},
			{GAE :> gae},
			{GS :> gs},
			{GSD :> gsd},
			{GSE :> gse},
			{SP :> sp},
			{SPD :> spd},
			{SPE :> spe},
			{SO :> so},
			{SOD :> sod},
			{PropagatorDenominator :> propagatorD},
			{ScalarProduct :> scalarP},
			{Dot -> DOT},
			If[$BreitMaison === True,
				{ChiralityProjector[1] :> 1/2 + 1/2 DiracGamma[5],
				ChiralityProjector[-1]:> 1/2 - 1/2 DiracGamma[5]},
				{ChiralityProjector[1] :> DiracGamma[6],
				ChiralityProjector[-1]:> DiracGamma[7]}
			]
		];
		(* Dropped the last rules to avoid e.g.
		(1/2 + DiracGamma[5]/2 // ExpandProductExpand ---> DiracGamma[6],
		when $BreitMaison=True. 19/1-2003, F.Orellana*)
		revru =
			If[$BreitMaison === True,
				Map[Reverse, Drop[ru, -2]],
				Map[Reverse, ru]
			];

		If[uru =!={},
				ru = Join[ru,uru]
		];
		(*
		Print["fci time = ",ti//FeynCalcForm];
		Print["ru= ",ru];
		*)

		If[ru =!={}, ReplaceRepeated[x//.{
			LC[a___][b___] :> lcl[{a},{b}],
			LCD[a___][b___] :> lcdl[{a},{b}],
			LeviCivita[a___][b___] :> levicivital[{a},{b}]}, Dispatch[ru], MaxIterations -> 20] /.
				{mt :> MT,
				fv :>  FV} /. Dispatch[revru], x
		]
	];

loin1[x_,___] :=
	x;

metricT[ x_, y_,op_:{} ] :=
	Pair[ LorentzIndex[x,Dimension/.op/.Options[MetricTensor] ],
	LorentzIndex[y,Dimension/.op/.Options[MetricTensor] ];						];

metricT[a_ b_, opt___] :=
	metricT[a, b, opt];

metricT[a_^2 , opt___] :=
	metricT[a, a, opt];

metricT[x__] :=
	(metricT@@({x} /. LorentzIndex -> loin1));

metricT[x_, x_,op_:{}] :=
	(Dimension/.op/.Options[MetricTensor]);

Options[diracM] = {Dimension -> 4, FCI -> True};

diracM[n_?NumberQ y:Except[_?OptionQ], opts:OptionsPattern[]] :=
	n diracM[y,opts];
diracM[x_,y:Except[_?OptionQ], opts:OptionsPattern[]] :=
	DOT[diracM[x,opts],diracM[y,opts]];
diracM[x_,y:Except[_?OptionQ]..,opts:OptionsPattern[]] :=
	diracM[DOT[x,y],opts];
diracM[x_ y_Plus,opts:OptionsPattern[]] :=
	diracM[Expand[x y],opts];
diracM[x_Plus,opts:OptionsPattern[]] :=
	diracM[#,opts]& /@ x;
diracM[DOT[x_,y__],opts:OptionsPattern[]] :=
	diracM[#,opts]& /@ DOT[x,y];
diracM[5, OptionsPattern[]] :=
	DiracGamma[5]/; OptionValue[Dimension]===4;
diracM[6, OptionsPattern[]] :=
	DiracGamma[6]/; OptionValue[Dimension]===4;
diracM[7, OptionsPattern[]] :=
	DiracGamma[7]/; OptionValue[Dimension]===4;
diracM["+", OptionsPattern[]] :=
	DiracGamma[6]/; OptionValue[Dimension]===4;
diracM["-", OptionsPattern[]] :=
	DiracGamma[7]/; OptionValue[Dimension]===4;
diracM[x:Except[5|6|7], OptionsPattern[]] :=
	DiracGamma[LorentzIndex[x, OptionValue[Dimension]],
	OptionValue[Dimension]]/;(Head[x]=!=DOT && !StringQ[x]);

Options[diracS] = {Dimension -> 4, FCI -> True};

ndot[]=1;
ndot[a___,ndot[b__],c___] :=
	ndot[a,b,c];
ndot[a___,b_Integer,c___] :=
	b ndot[a,c];
ndot[a___,b_Integer x_,c___]:=
	b ndot[a,x,c];
diracS[x_,y:Except[_?OptionQ].., opts:OptionsPattern[]]:=
	diracS[ndot[x,y],opts];
diracS[x:Except[_?OptionQ].., opts:OptionsPattern[]]:=
	(diracS@@({x,opts}/.DOT->ndot) )/;!FreeQ[{x},DOT];
diracS[n_Integer x_ndot, opts:OptionsPattern[]]:=
	n diracS[x,opts];
diracS[x_ndot,opts:OptionsPattern[]] := Expand[ (diracS[#,opts]& /@ x) ]/.ndot->DOT;
(*   pull out a common numerical factor *)
diracS[x_, OptionsPattern[]] :=
	Block[{dtemp,dix,eins,numf,resd},
		dix = Factor2[ eins Expand[x]];
		numf = NumericalFactor[dix];
		resd = numf DiracGamma[ Momentum[Cancel[(dix/.eins->1)/numf],
					OptionValue[Dimension]],
					OptionValue[Dimension]]

	]/;((Head[x]=!=DOT)&&(Head[x]=!=ndot));

Options[fourV] = {Dimension -> 4, FCI -> True};
(*   pull out a common numerical factor *)

fourV[x_,y_, OptionsPattern[]]:=
	Block[{nx,numfa,one},
		nx = Factor2[one x];
		numfa = NumericalFactor[nx];
		(numfa Pair[LorentzIndex[y,OptionValue[Dimension]],
		Momentum[Cancel[nx/numfa]/.one->1, OptionValue[Dimension]]])
	]/; !FreeQ[x, Plus];

fourV[x_, y_, OptionsPattern[]] :=
	Pair[LorentzIndex[y,OptionValue[Dimension]],
	Momentum[x,OptionValue[Dimension]]]/; FreeQ[x, Plus];

propagatorD[x_] :=
	propagatorD[x, 0] /; FreeQ2[x, {Pattern, Pair, ScalarProduct}];

propagatorD[x_, y_] := (propagatorD[x, y] =
	PropagatorDenominator[MomentumExpand[ Momentum[x,D] ],y]) /;FreeQ2[x,{Momentum, Pattern,HoldForm}];

propagatorD[x_, y_] := (propagatorD[x, y] =
	PropagatorDenominator[x//MomentumExpand, y]) /; (FreeQ[{x,y}, Pattern] ) &&	(MomentumExpand[x] =!= x);

propagatorD[x_, y_] :=
	PropagatorDenominator[x, y] /; (MomentumExpand[x] === x);

sunTint[x__] :=
	sunT[x] /. sunT -> SUNT;

sunT[b_]  := sunT[SUNIndex[b]] /;
	FreeQ2[b, {SUNIndex,ExplicitSUNIndex}] && FreeQ[b, Pattern] && !IntegerQ[b];

sunT[b_?NumberQ]  := sunT[ExplicitSUNIndex[b]];

SetAttributes[setdel, HoldRest];

setdel[x_, y_] :=
	SetDelayed[x, y];

setdel[HoldPattern[sunT[dottt[x__]]] /. dottt -> DOT, DOT@@( sunT/@{x})];
setdel[HoldPattern[sunT[sunind[dottt[x__]]]] /. dottt -> DOT /. sunind ->
	SUNIndex, DOT@@( sunT/@{x})];

sunT[a_, y__] :=
	Apply[DOT, sunT /@ {a, y}];

sunTFint[{a__},b_,c_] :=
	SUNTF[Map[SUNIndex, ({a} /. SUNIndex -> Identity)],
	SUNFIndex@(b /. SUNFIndex -> Identity),
	SUNFIndex@(c /. SUNFIndex -> Identity)];

scalarP[a_ b_, opt:OptionsPattern[ScalarProduct]] :=
	scalarP[a, b, opt];
scalarP[a_^2 , opt:OptionsPattern[ScalarProduct]] :=
	scalarP[a, a, opt];

scalarP[ x_, y_,opt:OptionsPattern[ScalarProduct]] :=
	If[FreeQ[x, Momentum] || FreeQ[y, Momentum],
		Pair[ Momentum[x, OptionValue[ScalarProduct,{opt},Dimension]],
		Momentum[y,	OptionValue[ScalarProduct,{opt},Dimension]]],
		Pair[x, y]
	];

scalarP[ x_, y_,opt___BlankNullSequence] :=
	If[(FreeQ[x, Momentum]) || FreeQ[y, Momentum],
		Pair[ Momentum[x,opt], Momentum[y,opt] ],
		Pair[x, y]
	];

fadint[a__] :=
	fadint2 @@ Map[Flatten[{#}]&, {a}];

propp[{x_}]:=
	PropagatorDenominator[Momentum[x, OptionValue[FAD, Dimension]],0]//MomentumExpand;

propp[{repeated[{x_, m_}]}]:=
	Repeated[PropagatorDenominator[Momentum[x, OptionValue[FAD, Dimension]],
	m] // MomentumExpand];

propp[{x_, m_}]:=
	PropagatorDenominator[Momentum[x, OptionValue[FAD, Dimension]],
	m] // MomentumExpand;

fadint2[b__List] :=
	FeynAmpDenominator @@ Map[propp, {b}/.Repeated->repeated];

sp[a_,b_] :=
	Pair[Momentum[a], Momentum[b]];
spd[a_,b_] :=
	Pair[Momentum[a, D], Momentum[b,D]];
spe[a_,b_] :=
	Pair[Momentum[a, D-4], Momentum[b,D-4]];
so[a_] :=
	Pair[Momentum[a], Momentum[OPEDelta]];
sod[a_] :=
	Pair[Momentum[a,D], Momentum[OPEDelta,D]];

fvd[a_,b_] :=
	Pair[Momentum[a, D], LorentzIndex[b,D]];
fve[a_,b_] :=
	Pair[Momentum[a, D-4], LorentzIndex[b,D-4]];
fv[a_,b_] :=
	Pair[Momentum[a], LorentzIndex[b]];
mt[a_,b_] :=
	Pair[LorentzIndex[a], LorentzIndex[b]];
mtd[a_,b_] :=
	Pair[LorentzIndex[a, D], LorentzIndex[b, D]];
mte[a_,b_] :=
	Pair[LorentzIndex[a, D-4], LorentzIndex[b, D-4]];

gs[a_] :=
	DiracGamma[Momentum[a]];
gsd[a_] :=
	DiracGamma[Momentum[a,D],D];
gse[a_] :=
	DiracGamma[Momentum[a,D-4],D-4];

ga[5] =
	DiracGamma[5];
ga[6] =
	DiracGamma[6];
ga[7] =
	DiracGamma[7];
ga[a_] :=
	DiracGamma[LorentzIndex[a]]/; !IntegerQ[a];
gad[a_] :=
	DiracGamma[LorentzIndex[a,D],D]/; !IntegerQ[a];
gae[a_] :=
	DiracGamma[LorentzIndex[a,D-4],D-4]/; !IntegerQ[a];
ga[a_Integer] :=
	DiracGamma[ExplicitLorentzIndex[a]]/; (a=!=5 && a=!=6 && a=!=7);
gad[a_Integer] :=
	DiracGamma[ExplicitLorentzIndex[a,D],D]/; (a=!=5 && a=!=6 && a=!=7);
gae[a_Integer] :=
	DiracGamma[ExplicitLorentzIndex[a,D-4],D-4]/; (a=!=5 && a=!=6 && a=!=7);


lc[a__]  := (Eps@@Join[(LorentzIndex/@{a}),{Dimension->4}])/;
	FreeQ[{a},Rule] && (Length[{a}] === 4);

lcd[a__]  := (Eps@@Join[(LorentzIndex[#,D]&/@{a}),{Dimension->D}])/;
	FreeQ[{a},Rule] && (Length[{a}] === 4);

lcl[{x___},{y___}]:= (Eps@@Join[LorentzIndex/@{x},
	Momentum/@{y},{Dimension->4}]/;	Length[Join[{x},{y}]]===4);

lcdl[{x___},{y___}]:= (Eps@@Join[Map[LorentzIndex[#, D]& ,{x}],
	Map[Momentum[#, D]& ,{y}],{Dimension->D}]/;	Length[Join[{x},{y}]]===4);

levicivita[x:Except[_?OptionQ].., opts:OptionsPattern[LeviCivita]] :=
	Eps@@Join[(LorentzIndex[#,OptionValue[LeviCivita,{opts},Dimension]]&/@{x}),
	{Dimension->OptionValue[LeviCivita,{opts},Dimension]}]/; Length[{x}]===4;

levicivital[{x:Except[_?OptionQ]..., opts1:OptionsPattern[LeviCivita]},{y:Except[_?OptionQ]..., opts2:OptionsPattern[LeviCivita]}] :=
	Eps@@Join[Map[LorentzIndex[#, OptionValue[LeviCivita,{opts1},Dimension]]& ,{x}],
	Map[Momentum[#, OptionValue[LeviCivita,{opts1},Dimension]]& ,{y}],
	{Dimension->OptionValue[LeviCivita,{opts1},Dimension]}]/; Length[{x,y}]===4 &&
	OptionValue[LeviCivita,{opts1},Dimension]===OptionValue[LeviCivita,{opts2},Dimension];

tosunf[a_, b_, c_] :=
	SUNF@@Map[SUNIndex, ({a,b,c} /. SUNIndex->Identity)];

tospinor[a__] :=
	Spinor[a];
tospinorv[a_,0,b__] :=
	Spinor[a,0,b];
tospinorv[a_] :=
	Spinor[a];
tospinorv[a_,b__] :=
	Spinor[-a,b];

FCPrint[1,"FeynCalcInternal.m loaded."];
End[]
