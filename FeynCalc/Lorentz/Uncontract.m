(* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)

(* :Title: Uncontract *)

(* :Author: Rolf Mertig *)

(* ------------------------------------------------------------------------ *)
(* :History: File created on 22 June '97 at 23:01 *)
(* ------------------------------------------------------------------------ *)

(* ------------------------------------------------------------------------ *)

Uncontract::usage = "Uncontract[exp,q1,q2, ...] uncontracts Eps
and DiracGamma. Uncontract[exp,q1,q2, Pair->{p}] uncontracts
also p.q1 and p.q2; Pair -> All uncontracts all except
OPEDelta. Dimension -> Automatic leaves dimensions unchanged.";


(* ------------------------------------------------------------------------ *)

Begin["`Package`"]
End[]

Begin["`Uncontract`Private`"]

Options[Uncontract] = {Dimension -> Automatic (*D*) (*Change 6/10-2002. F.Orellana*),
											DimensionalReduction -> False,
											Pair -> {}, Unique   -> True};

Uncontract[x_Plus, q__] :=
	Map[Uncontract[#,q]&, x];
Uncontract[x_List, q__] :=
	Map[Uncontract[#,q]&, x];

Uncontract[x_, q1__, q2:Except[_?OptionQ], opt:OptionsPattern[]
				] :=
	Uncontract[Uncontract[x,q2,opt(*bug fix. F.Orellana.21/9-2002*)],q1, opt];

Uncontract[ex_, q:Except[_?OptionQ], OptionsPattern[]
				] :=
	Block[ {exp,eeps,nex,li,li1,li2,dim,par,dre,dummy,inc,
					   a$AL,dr, lidr,seq},
		dre = OptionValue[DimensionalReduction];
		par = OptionValue[Pair];
		lidr[z_] :=
			If[ dre === True,
				z/.{LorentzIndex[aa_,_]:>LorentzIndex[aa]/.
													   Momentum[bb_,_]  :> Momentum[bb]
												   },
				z
			];
		exp = FeynCalcInternal[ex];
		If[ OptionValue[Unique] === True,
			a$AL = Unique[$AL],
			a$AL = $AL
		];
		If[ par===All,
			par = Map[First, SelectFree[Cases2[exp, Momentum], OPEDelta]]
		];
		If[ (par === {} && FreeQ2[exp, {Eps, DiracGamma}]) ||
			(Head[dummy exp] =!= Times),
			exp,
			nex = exp;
			dim = OptionValue[Dimension];
			If[ FreeQ[nex, a$AL],
				inc = 0,
				inc = (Max @@ Map[First, Cases2[nex, a$AL]]);
			];
			If[ !FreeQ[nex,Eps],
				nex = nex /. Eps -> eeps;
				nex = nex /. eeps[aaa__]^2 :> TIMES[eeps[aaa],eeps[aaa]];
				nex = nex //. {eeps[a___,Momentum[(c: q | Polarization[q,__]),d___],b___] :>
											(*Changed dim to If[...]. F.Orellana. 6/10-2002*)
											(li = LorentzIndex[a$AL[inc = inc+1],If[ dim===Automatic,
																					 seq[d],
																					 dim
																				 ](*dim*)];
											 Pair[Momentum[c,If[ dim===Automatic,
																 seq[d],
																 dim
															 ](*dim*)], li] *
											 eeps[a,lidr[li],b]
											)
											} /. eeps -> Eps /. TIMES -> Times;
			];
			If[ !FreeQ[nex, DiracGamma],
				nex = nex /. DiracGamma -> dirg;
				nex = nex //. dirg[Momentum[(c: q | Polarization[q,__]),d___],___] :>
											(li = LorentzIndex[a$AL[inc = inc+1],If[ dim===Automatic,
																					 seq[d],
																					 dim
																				 ]];
											 Pair[Momentum[c,If[ dim===Automatic,
																 seq[d],
																 dim
															 ]], li] *
											 dirg[lidr[li],If[ dim===Automatic,
															   seq[d],
															   dim
														   ]]
											) /. dirg -> DiracGamma;
				nex = DotSimplify[nex,Expanding -> False];
			];
			If[ par=!={} && Length[par]>0 && Head[par]===List,
				nex = nex /. Pair[aa__/;!FreeQ2[{aa}, par]
													]^n_Integer?Positive :> (*Uncontract denominators also.
																												Change by F.Orellana. 3/11-2002*)
																											(*Reverted, RM 06/22-2011 *)
							Apply[times, Table[Pair[aa], {j,Abs[n]}]]^Sign[n];
				If[ MemberQ[par, q],
					nex = nex //. Pair[Momentum[(c1: q | Polarization[q,__]),d___], Momentum[(c2: q | Polarization[q,__]),___]] :>
												(li1 = LorentzIndex[a$AL[inc = inc+1], If[ dim===Automatic,
																						   seq[d],
																						   dim
																					   ]];
												 li2 = LorentzIndex[a$AL[inc = inc+1], If[ dim===Automatic,
																						   seq[d],
																						   dim
																					   ]];
												 Pair[Momentum[c1, If[ dim===Automatic,
																	   seq[d],
																	   dim
																   ]], li1] *
												 (* das ist vielleicht ein Bloedsinn mit dieser dimensionalen Reduktion:
												 HIER darf man li1 und li2 nicht 4-dimensional setzen
												 *)
												 Pair[Momentum[c2, If[ dim===Automatic,
																	   seq[d],
																	   dim
																   ]], li2] *Pair[li1, li2]
												);
					par = SelectFree[par, q];
				];
				nex = nex //.{Pair[Momentum[(c: q | Polarization[q,__]),d___], Momentum[pe_,___]
													] :> (li = LorentzIndex[a$AL[inc = inc+1],If[ dim===Automatic,
																								  seq[d],
																								  dim
																							  ]];
														  Pair[Momentum[c,If[ dim===Automatic,
																			  seq[d],
																			  dim
																		  ]], li] *
														  Pair[Momentum[pe,If[ dim===Automatic,
																			   seq[d],
																			   dim
																		   ]],lidr[li]])/;MemberQ[par,pe]
										} /. times -> Times;
				If[ !FreeQ[nex, (tf_/;Context[tf]==="Global`")[___,Momentum[(q | Polarization[q,__]),___],___]],
					nex = nex //. { (tf_/;Context[tf]==="Global`")[a___,Momentum[(c: q | Polarization[q,__]),d___],b___] :>
													(li = LorentzIndex[a$AL[inc = inc+1],If[ dim===Automatic,
																							 seq[d],
																							 dim
																						 ]];
													 tf[a, li, b] Pair[Momentum[c,If[ dim===Automatic,
																					  seq[d],
																					  dim
																				  ]],lidr[li]]
													)
												}
				];
			(*
(*RM: added on 20110621 on behalf of http://www.feyncalc.org/forum/0639.html *)
				If[!FreeQ[nex, (tf_/;!MemberQ[{DiracGamma,Pair,PropagatorDenominator},tf])[___,Momentum[q,___],___]],
						nex = nex //. { (tf_/;!MemberQ[{DiracGamma,Pair,PropagatorDenominator},tf])[a___,Momentum[q,d___],b___] :>
														(li = LorentzIndex[a$AL[inc=inc+1],If[dim===Automatic,seq[d],dim]];
														tf[a, li, b] Pair[Momentum[q,If[dim===Automatic,seq[d],dim]],lidr[li]]
														)
													}
	];
*)
				];
			nex/.dummy->1/.seq:>Sequence
		]
	];

FCPrint[1,"Uncontract.m loaded."];
End[]
