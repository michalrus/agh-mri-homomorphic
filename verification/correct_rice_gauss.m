function Fc=correct_rice_gauss(SNR);

% CORRECT_RICE_GAUSS Rician-Gaussian correction for noise estimation
%   FC=correct_rice_gauss(SNR,TIPO,MODO);
%
% The function corrects the bias of the mean of logRice vs logGaussian 
% USAGE:
%   Fc=correct_rice_gauss(SNR,1,3);
%   Fc=correct_rice_gauss(SNR);
%
% INPUTS:
%           SNR:    signal SNR
%
% OUTPUT:   Fc:     correction curve
%
% Santiago Aja-Fernandez (V1.0)
% LPI 
% www.lpi.tel.uva.es/~santi
% sanaja@tel.uva.es
% LPI Valladolid, Spain
% Original: 06/07/2014, 
% Release   16/12/2014
%
% RICE HOMOMORPHIC TOOLBOX
%

if( nargin<1 )
    error('At least the input image and modos shouls be provided');
end


a1=SNR;
load coef_SNR_8

Fc=Coefs(1)+Coefs(2).*a1+Coefs(3).*a1.^2+Coefs(4).*a1.^3+Coefs(5).*a1.^4+Coefs(6).*a1.^5+Coefs(7).*a1.^6+Coefs(8).*a1.^7+Coefs(9).*a1.^8;

Fc=Fc.*(a1<=7);       
        


