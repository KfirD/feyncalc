(* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)

(* :Title: FunctionalD *)

(* :Author: Rolf Mertig *)

(* ------------------------------------------------------------------------ *)
(* :History: File created on 26 February '99 at 16:36 *)
(* ------------------------------------------------------------------------ *)

(* :Summary: functional differentiation *)

(* extension: March 1998 on request of Peter Cho *)

(* ------------------------------------------------------------------------ *)

FunctionalD::usage =
"FunctionalD[expr,
{QuantumField[name, LorentzIndex[mu], ..., SUNIndex[a]][p], ...}] calculates
the functional derivative of expr with respect to the field list (with
incoming momenta p, etc.) and does the fourier transform.

FunctionalD[expr, {QuantumField[name, LorentzIndex[mu], ...
SUNIndex[a]], ...}] calculates the functional derivative and does
partial integration but omits the x-space delta functions.";

(* ------------------------------------------------------------------------ *)

Begin["`Package`"]
End[]

Begin["`FunctionalD`Private`"]

(* ********************************************************************** *)
(* products of metric tensors  and SU(N) deltas *)
g[{}, {}] = d[{}, {}] = 1;
g[{x__} ,{y__}] :=
	g[{x}, {y}] =
	(PairContract3[{x}[[1]], {y}[[1]]] g[Rest[{x}], Rest[{y}]]);
d[{x__} ,{y__}] :=
	d[{x}, {y}] =
	(SUNDeltaContract[{x}[[1]], {y}[[1]]] d[Rest[{x}], Rest[{y}]]);
field = QuantumField;
(* ********************************************************************** *)

ddl[FCPartialD[Momentum[OPEDelta]^m_]][p_] :=
	(-1)^m I^m Pair[Momentum[p], Momentum[OPEDelta]]^m;

ddl[][_] :=
	1;
ddl[pa:FCPartialD[Momentum[OPEDelta]..]][p_] :=
	(-1)^Length[{pa}] I^Length[{pa}] *
	Pair[Momentum[p], Momentum[OPEDelta]]^Length[{pa}];
ddl[pa:FCPartialD[Momentum[OPEDelta]]..][p_] :=
	(-1)^Length[{pa}] I^Length[{pa}] *
	Pair[Momentum[p], Momentum[OPEDelta]]^Length[{pa}];

ddl[FCPartialD[LorentzIndex[m_]]][p_] :=
	(-I) dDelta[Momentum[p], LorentzIndex[m]];
ddl[a___,FCPartialD[LorentzIndex[m_]], x___][p_] :=
	(-I) dDelta[Momentum[p], LorentzIndex[m]] ddl[a, x][p];

ddl[FCPartialD[Momentum[m_]]][p_] :=
	(-I) dDelta[Momentum[p], Momentum[m]];
ddl[a___,FCPartialD[Momentum[m_]], x___][p_] :=
	(-I) dDelta[Momentum[p], Momentum[m]] ddl[a, x][p];
ddl[a___,FCPartialD[Momentum[OPEDelta]^m_], x___][p_] :=
	(-1)^m I^m Pair[Momentum[p], Momentum[OPEDelta]]^m  ddl[a, x][p];

dot2[___,0,___] :=
	0;
dot2[a___,1,b___] :=
	DOT[a,b];


(* functional differentation function:  FunctionalD *)
FunctionalD[y_, fi_QuantumField, op___] :=
	FunctionalD[y,{fi}, op];
(* product rule, recursive *)


FunctionalD[y_, {fi__, a_ }, op___] :=
	FunctionalD[FunctionalD[y, {a}, op], {fi}, op];

(*Added ExplicitSUNIndex. F.Orellana, 16/9-2002*)
FunctionalD[y_/;!FreeQ[y,field[__][___]],
			{field[nam_, lor___LorentzIndex, sun___SUNIndex|sun___ExplicitSUNIndex][pp___]}] :=
	Block[ {xX},
		D[If[ !FreeQ[y, FieldStrength],
			Explicit[y],
			y
		] /.
		field[a___, nam, b___][pe___] -> field[a,nam,b][pe][xX], xX] /.
		{field[py___FCPartialD, nam, li___LorentzIndex, col___SUNIndex|col___ExplicitSUNIndex][]'[xX] :>
		If[ {py} === {},
			1,
			ddl[py][pp]
		] * g[{lor}, {li}] d[{sun}, {col}],
		field[py___FCPartialD, nam, li___Momentum, col___SUNIndex|col___ExplicitSUNIndex][]'[xX] :>
		If[ {py} === {},
			1,
			ddl[py][pp]
		] * g[{lor}, {li}] d[{sun}, {col}]
		} /.
			{field[aa___, nam, bb___][pee___][xX] :> field[aa, nam, bb][pee],
			SUNDelta  :> SUNDeltaContract, Pair :> PairContract3
			} /. DOT -> dot2 /. dot2 -> DOT /. dDelta -> PairContract3/.
				{SUNDeltaContract :> SUNDelta,  PairContract3 :> Pair}
	];



(*Definition below added by Frederik Orellana 25/2-1999*)

FunctionalD[y_/;FreeQ[y,field[__][___]],
{field[nam_, lor___LorentzIndex, sun___SUNIndex|sun___ExplicitSUNIndex][pp___]}] :=
	Block[ {xX},
		D[y /.
		field[a___, nam, b___] -> field[a,nam,b][xX], xX] /.
		{field[py___FCPartialD, nam, li___LorentzIndex, col___SUNIndex|col___ExplicitSUNIndex]'[xX] :>
		If[ {py} === {},
			1,
			ddl[py][pp]
		] * g[{lor}, {li}] d[{sun}, {col}],
		field[py___FCPartialD, nam, li___Momentum, col___SUNIndex|col___ExplicitSUNIndex]'[xX] :>
		If[ {py} === {},
			1,
			ddl[py][pp]
		] * g[{lor}, {li}] d[{sun}, {col}]
		} /.
			{field[aa___, nam, bb___][xX] -> field[aa, nam, bb] /.
					SUNDelta  :> SUNDeltaContract, Pair :> PairContract3
			} /. DOT -> dot2 /. dot2 -> DOT /. dDelta -> PairContract3/.
				{SUNDeltaContract :> SUNDelta,  PairContract3 :> Pair}
	];

(*End add*)

(* stay in x-space, but omit deltafunctions *)
		(* op: { first entry:
					how to replace derivatives of deltafunctions, i.e.,
					how to do integration by parts,
				second entry:
					final substitutions
				}
		*)
FunctionalD[y_, {field[nam_, lor___LorentzIndex, sun___SUNIndex|sun___ExplicitSUNIndex]
				}, opin_:{-RightPartialD[#]&, {}}
			] :=
	Block[ {xX,  pard, r, lastrep = {}, op = opin, ddelta, partiald2},
(* ddelta stands for the derivative of the delta funtion *)
		If[ Head[op] =!= List,
			op = {op}
		];
		pard = (ExplicitPartialD[DOT[##] /. partiald2 -> First[op]])&;
		If[ Length[op] > 1,
			lastrep = Flatten[Rest[op]]
		];
		r =
		(
		D[If[ !FreeQ[y, FieldStrength],
			Explicit[y],
			y
		] /.
		field[a___, nam, b___] -> field[a,nam,b][][xX], xX]
		) /.
		{field[py___FCPartialD, nam, li___LorentzIndex, col___SUNIndex|col___ExplicitSUNIndex][]'[xX] :>
		If[ {py} === {},
			1,
			(ddelta[py] /. FCPartialD ->
			partiald2)
		] * g[{lor}, {li}] d[{sun}, {col}]
		} /.
			{field[aa___, nam, bb___][][xX] :> field[aa, nam, bb] ,
			SUNDelta  :> SUNDeltaContract, PairContract3 :> PairContract
			} /. Times -> DOT /. DOT -> dot2 /. dot2 -> DOT /.
				{SUNDeltaContract :> SUNDelta, Pair :> PairContract} /.
				PairContract -> Pair;
		r = Expand[DotSimplify[r]] //.
				{ SUNDeltaContract :> SUNDelta, Pair :> PairContract } /.
					PairContract ->Pair;
	(* operate from the left *)
		If[ !FreeQ[r, ddelta],
			If[ Head[r] =!= Plus,
				r = ExpandPartialD[((SelectNotFree[r, ddelta] /. ddelta -> pard) .
									SelectFree[r, ddelta])/.Times->DOT
									],
				r = Sum[ExpandPartialD[((SelectNotFree[r[[i]], ddelta] /.
											ddelta -> pard) .
										SelectFree[r[[i]], ddelta]
											) /. Times -> DOT
											],
						{i, Length[r]}]
			]
		];
		r = Expand[r, Pair] /. Pair->PairContract /.
			{PairContract:>Pair, PairContract3 :> Pair};
		If[ (!FreeQ2[r, {LeftPartialD, RightPartialD}]) && !FreeQ[r, Eps],
			If[ Head[r] === Plus,
				r = Map[ExpandPartialD, r],
				r = ExpandPartialD[r]
			]
		];
		r = r /. lastrep /. DOT -> dot2 /. dot2 -> DOT;
		r
	];

FCPrint[1,"FunctionalD.m loaded."];
End[]
