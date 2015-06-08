function [MapaR MapaG]=rice_homomorf_est(In,SNR,LPF,Modo)
%
% RICE_HOMOMORF_EST Noise estimation in SENSE MR 
%  [MapaR MapaG Sigma_n2 Sigma_n]=rice_homomorf_est(In,Tipo,SNR,LPF)
%  estimates the variable map of noise out of SENSE magnetic resonance
%  data using a homomorphic approach.
%
% V1.0
%
% USAGE:
%
%   NoiseMap=rice_homomorf_est(In);
%   NoiseMap=rice_homomorf_est(In,SNR,4.5);
%
% GENERAL:
%
%   [MapaR MapaG]=rice_homomorf_est(In,SNR,LPF)
%
% INPUTS:
%       In:     noisy rician data
%
% OPTIONAL INPUTS
%
%       SNR:    Signal to noise ratio
%               =0 estimated from data using EM
%       LPF     Threshold for LPF 
%               ==0 default value (4.8)
%       Modo    Calculation of the local mean to be substracted to the image
%               1: Local mean
%               2: ML estimation of signal and noise (Default)
%               3: No substraction of the mean
%
% OUTPUT
%       MapaR:  Rician Map
%       MapaG:  Gaussian Map
%
% Algorithm proposed in:
%
%       Spatially variant noise estimation in MRI: A homomorphic approach
%       S Aja-Fernández, T Pieciak, G Vegas-Sánchez-Ferrero
%       Medical Image Analysis, 2014
%
%
% Santiago Aja-Fernandez (V1.0)
% LPI 
% www.lpi.tel.uva.es/~santi
% sanaja@tel.uva.es
% LPI Valladolid, Spain
% Original: 06/07/2014, 
% Release   16/12/2014

if( nargin<1 )
    error('At least the input image and modos shouls be provided');
end
if( nargin<2 )
    SNR=0;
    LPF=4.8;
    Modo=2;
end
if( nargin<3 )
    LPF=4.8;
    Modo=2;
end
if( nargin<4 )
    Modo=2;
end

% Euler gamma:
eg=0.5772156649015328606;

%Prior Values------------

%Estimate mean and noise using EM
[M2 Sigma_n]=em_ml_rice2D(In,10,[3,3]);
%Low pass filter of noise to avoid high frequancy components
Sigma_n2=lpf(Sigma_n,1.2);
% Local Mean
M1=filter2B(ones(5)./25,In);


%SNR estimation (using RIcian EM)
if (length(SNR)==1)&&(SNR==0)
    SNR=M2./Sigma_n;
end

%Homomorfic filtering-------------------
%Gauss----------------------
Rn=abs(In-M1);
lRn=log(Rn.*(Rn~=0)+0.001.*(Rn==0));
LPF2=lpf((lRn),LPF);
Mapa2=exp(LPF2);
MapaG=Mapa2.*2./sqrt(2).*exp(-psi(1)./2);

%Rician-------------------------
if Modo==1
    LocalMean=M1;
elseif Modo==2
    LocalMean=M2;
else
    LocalMean=0;
end

Rn=abs(In-LocalMean);
lRn=log(Rn.*(Rn~=0)+0.001.*(Rn==0));
LPF2=lpf((lRn),LPF);
Fc1=correct_rice_gauss(SNR);
LPF1=LPF2-Fc1;
LPF1=lpf((LPF1),LPF+2,2);
Mapa1=exp(LPF1);
MapaR=Mapa1.*2./sqrt(2).*exp(-psi(1)./2);



