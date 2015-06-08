% Example of USAGE
% Variable noise map out of SENSE magnetic resonance data using 
% the homomorphic approach proposed in:
%
%       Spatially variant noise estimation in MRI: A homomorphic approach
%       S Aja-Fernández, T Pieciak, G Vegas-Sánchez-Ferrero
%       Medical Image Analysis, 2014
%
% Santiago Aja-Fernandez (V1.0)
% LPI 
% www.lpi.tel.uva.es/~santi
% sanaja@tel.uva.es
% LPI Valladolid, Spain
% Original: 06/07/2014, 
% Release   16/12/2014

clear all
%LOAD NOISE MAP-----------------------------------
load Mapa_grappa.mat
Mapa=Mapa;
%LOAD IMAGEN----------------------------
load mri.mat
In=abs(I+Mapa.*randn(256)+Mapa.*j.*randn(256));
SNR=I./Mapa;

%Estimation with known SNR

[MapaR MapaG]=rice_homomorf_est(In,SNR,3.4,2);


%Estimation with unknown SNR

[MapaR2 MapaG2]=rice_homomorf_est(In,0,3.4,2);

imagesc([Mapa MapaR MapaR2 MapaG2])
colorbar




