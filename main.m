(* ::Package:: *)

BeginPackage["MRI`"]


(* read config *)
ToExpression[Map[
  Function[kv,
    StringReplace[StringTrim[Part[kv,1]],"_"->""]
    <>"="<>
    StringReplace[StringTrim[Part[kv,2]],"'"->"\""]],
    StringSplit[StringCases[ReadString["./config"], RegularExpression["(^|\\s)\\S+\\s*=\\s*([\\d.]+|'.*?')"]],"="]]];


(* I/O functions *)
normalizePixel[max_][pix_] := N[If[Length[pix]<3,First[pix],Total[Take[pix,3]]/3]/max];

readInputFile[path_] := If[StringMatchQ[path,"*.csv",IgnoreCase->True],
  Import[path,"CSV"],
  Map[Function[row,Map[normalizePixel[255],row]],Import[path,"Data"]]];


(* read the input files *)
noisyMrImage := readInputFile[inputfilename];
snr := readInputFile[inputfilenamesnr];


filterPadded[h_,I_] := Module[{rotatedH,paddedI,hRadH,hRadW},
  rotatedH = Reverse[h, {1, 2}]; (* 180\[Degree] rotation needed for conv2 to behave like filter2 *)
  {hRadH,hRadW} = Floor[(Dimensions[rotatedH]-1)/2];
  paddedI = ArrayPad[I,{{hRadH},{hRadW}},"Fixed"];
  ListConvolve[N[rotatedH],N[paddedI]]
]


(* APROXIMATION of BESSELI. Avoids problems *)
approxi1i0[z_] := Module[{cont,z8,Mn,Md,M,useBesseliAtAll,elz},
  cont = Map[If[#<1.5,1,0]&,z,{2}];
  z8 = N[8*Map[If[#==0,WHATEVER,#]&,z,{2}]];
  Mn = 1 - 3/z8 - 15/2/z8^2 - (3*5*21)/6/z8^3;
  Md = 1 + 1/z8 +  9/2/z8^2 +   (25*9)/6/z8^3;
  M = Mn/Md;
  useBesseliAtAll=Count[Total[cont,{1}],x_/;x>1]==Dimensions[z][[2]];
  MapIndexed[Function[{elM,idx},
    elz=z[[ Part[idx,1],Part[idx,2] ]];
    If[elz==0, 0,
      If[useBesseliAtAll && elz<1.5,N[BesselI[1,elz]/BesselI[0,elz]],elM]
    ]
  ],M,{2}]
]


(* EM implementation of Maximum Likelihood for Rician data *)
emmlRice[in_,n_,windowSize_]:=Module[{windowRadius,mask,ak,sigmak2},
  windowRadius = Floor[(windowSize-1)/2];
  mask = BoxMatrix[windowRadius] / (windowRadius*2+1)^2;
  ak = Sqrt[Sqrt[N[Map[Max[#,0]&,2*filterPadded[mask,in^2]^2 - filterPadded[mask,in^4],{2}]]]];
  sigmak2 = 0.5*Map[Max[#,0.01]&,filterPadded[mask,in^2]-ak^2,{2}];
  Do[
    ak = Map[Max[#,0]&,filterPadded[mask,approxi1i0[ak*in/sigmak2]*in],{2}];
    sigmak2 = Map[Max[#,0.01]&,0.5*filterPadded[mask,Abs[in]^2]-ak^2/2,{2}],
    {i,n}
  ];
  {ak,Sqrt[sigmak2]}
]


(* LPF low pass filter of images *)
lpf[i_,sigma_]:=Module[{Mx,My,h},
  {Mx,My} = Dimensions[i];
  h = GaussianMatrix[{{Mx,My},sigma*2}];
  h = h/Max[h];
  h = h[[Mx+1;;2*Mx,My+1;;2*My]];
  FourierDCT[FourierDCT[i]*h,3]
]


EndPackage[]
