function [Signal Sigma_n]=em_ml_rice2D(In,N,Ws)

% EM implementation of Maximum Likelihood for Rician data
% 
% INPUT:
%   	In:	Input Data (Rician Image)
%		N:	Number or iterations in EM
%		Ws:	Window Size [3 3], [7,7]...
%
% OUTPUT
%
%   Signal: EM estimation of Rician signal
%   
% 
% Modified version of the algorithm proposed in
%
%   M.D. DeVore, A.D. Lanterman, J.A. O’Sullivan
%   ATR performance of a Rician model for SAR images
%   AeroSense 2000, International Society for Optics 
%   and Photonics (2000), pp. 34–45
%
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

[Mx, My]=size(In);
In=double(In);

%PARAMETER INITIALIZATION
Mask=ones(Ws)./prod(Ws);
a_k=sqrt(sqrt(max(2.*filter2B(Mask,In.^2).^2-filter2B(Mask,In.^4),0)));
sigma_k2=0.5.*max(filter2B(Mask,In.^2)-a_k.^2,0.01);
	
%EM ALGORITHM
for ii=1:N
		a_k=max(filter2B(Mask,approxI1_I0(a_k.*In./sigma_k2).*In),0);
		sigma_k2=max(0.5.*filter2B(Mask,abs(In).^2)-a_k.^2./2,0.01);
		%sigma_k2=abs(0.5.*localmean3DB(abs(In).^2,Ws)-a_k.^2./2);
end

Signal=a_k;
Sigma_n=sqrt(sigma_k2);






