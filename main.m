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


(* EM implementation of Maximum Likelihood for Rician data *)
emmlRice[in_,n_,windowSize_]:=Module[{windowRadius,mask,ak},
  windowRadius = Floor[(windowSize-1)/2];
  mask = BoxMatrix[windowRadius] / (windowRadius*2+1)^2;
  ak = Sqrt[Sqrt[N[Map[Max[#,0]&,2*filterPadded[mask,in^2]^2 - filterPadded[mask,in^4],{2}]]]];
  ak
]


EndPackage[]
