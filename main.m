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
normalizePixel[max_][pix_]:=N[If[Length[pix]<3,First[pix],Total[Take[pix,3]]/3]/max];

readInputFile[path_]:=If[StringMatchQ[path,"*.csv",IgnoreCase->True],
  Import[path,"CSV"],
  Map[Function[row,Map[normalizePixel[255],row]],Import[path,"Data"]]];


(* read the input files *)
noisyMrImage:=readInputFile[inputfilename];
snr:=readInputFile[inputfilenamesnr];


EndPackage[]
