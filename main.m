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

writeOutputFile[path_,data_] := If[StringMatchQ[path,"*.csv",IgnoreCase->True],
  Export[path,data],Export[path,Image[data/Max[data]]]];


filterPadded[h_,I_] := Module[{rotatedH,paddedI,hRadH,hRadW},
  rotatedH = Reverse[h, {1, 2}]; (* 180\[Degree] rotation needed for conv2 to behave like filter2 *)
  {hRadH,hRadW} = Floor[(Dimensions[rotatedH]-1)/2];
  paddedI = ArrayPad[I,{{hRadH},{hRadW}},"Fixed"];
  ListConvolve[N[rotatedH],N[paddedI]]
]


(* APROXIMATION of BESSELI. Avoids problems *)
approxi1i0[zz_] := Module[{cont,z8,Mn,Md,M,useBesseliAtAll,elz},
  cont = Map[If[#<1.5,1,0]&,zz,{2}];
  z8 = N[8*Map[If[#==0,WHATEVER,#]&,zz,{2}]];
  Mn = 1 - 3/z8 - 15/2/z8^2 - (3*5*21)/6/z8^3;
  Md = 1 + 1/z8 +  9/2/z8^2 +   (25*9)/6/z8^3;
  M = Mn/Md;
  useBesseliAtAll=Count[Total[cont,{1}],x_/;x>1]==Dimensions[zz][[2]];
  MapIndexed[Function[{elM,idx},
    elz=zz[[ Part[idx,1],Part[idx,2] ]];
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


(* Gaussian matrix (Mathematica's GaussianMatrix[] seems to be incorrect? *)
meshgrid[xgrid_List,ygrid_List] := Transpose[Outer[List,xgrid,ygrid],{3,2,1}]

gaussianMatrix[h_,w_,sigma_]:=Module[{h1,h2,hg},
  {h1,h2}=N[meshgrid[Range[-(w-1)/2,(w-1)/2,1],Range[-(h-1)/2,(h-1)/2,1]]];
  hg= Exp[-(h1^2+h2^2)/(2*sigma^2)];
  hg/Total[hg,2]
]


(* LPF low pass filter of images *)
lpf[i_,sigma_]:=Module[{Mx,My,h},
  {My,Mx} = Dimensions[i];
  h = gaussianMatrix[2*My,2*Mx,sigma*2];
  h = h/Max[h];
  h = h[[My+1;;-1,Mx+1;;-1]];
  FourierDCT[FourierDCT[i]*h,3]
]


(* Rician-Gaussian correction for noise estimation *)
coefs = {-0.289549906258443,   -0.0388922575606330,   0.409867108141953,
         -0.355237628488567,    0.149328280945610,   -0.0357861117942093,
          0.00497952893859122, -0.000374756374477592, 1.18020229140092*^-5};
correctRiceGauss[a1_]:=Module[{fc},
  fc = coefs[[1]]      + coefs[[2]]*a1   + coefs[[3]]*a1^2
     + coefs[[4]]*a1^3 + coefs[[5]]*a1^4 + coefs[[6]]*a1^5
     + coefs[[7]]*a1^6 + coefs[[8]]*a1^7 + coefs[[9]]*a1^8;
  fc * Map[If[#<=7,1,0]&,a1,{2}]
]


(* Prior values *)
noisyMrImage = readInputFile[inputfilename];
{m2,sigman} = emmlRice[noisyMrImage,exiterations,3];
sigman2 = lpf[sigman,lpffSNR];
exWindowRadius = Floor[(exwindowsize-1)/2];
m1 = filterPadded[BoxMatrix[exWindowRadius]/(exWindowRadius*2+1)^2,noisyMrImage];
snr = If[StringLength[inputfilenamesnr]==0,m2/sigman,readInputFile[inputfilenamesnr]];


(* Gauss *)
rn = Abs[noisyMrImage-m1];
lrn = Log[Map[If[#==0,0.001,#]&,rn,{2}]];
lpf2 = lpf[lrn,lpff];
mapa2 = Exp[lpf2];
mapag = mapa2 * (2 / Sqrt[2] * Exp[-PolyGamma[1]/2]);


(* Rician *)
localMean = If[exfiltertype==1,m1,m2];
rn = Abs[noisyMrImage-localMean];
lrn = Log[Map[If[#==0,0.001,#]&,rn,{2}]];
lpf2 = lpf[lrn,lpff];
fc1 = correctRiceGauss[snr];
lpf1 = lpf2-fc1;
lpf1 = lpf[lpf1,lpffRice];
mapa1 = Exp[lpf1];
mapar = mapa1 * (2 / Sqrt[2] * Exp[-PolyGamma[1]/2]);


(* export *)
writeOutputFile[outputfilenameGaussian,mapag];
writeOutputFile[outputfilenameRician,  mapar];


(* errors when compared to MATLAB impl. ~= 10\.af\.b9\.b9 \[Divide] 10\.af\.b9\.b2 *)


EndPackage[]
