function I_out=filter2B(h,I)
%FILTER2B
% Correction of MATLAB filter2 function to avoid
% border effetcs. h must be NxN, with N odd.
%
% INPUT:
%   	h:	convolution mask (NxN, N odd)
%		I:	image
%		Ws:	Window Size [3 3], [7,7]...
% Santiago Aja-Fernandez (V1.0)
% LPI 
% www.lpi.tel.uva.es/~santi
% sanaja@tel.uva.es
% LPI Valladolid, Spain
% Original: 06/07/2014, 
% Release   16/12/2014
%
% RICE HOMOMORPHIC TOOLBOX

[Mx, My]=size(h);
if (rem(Mx,2)==0)||(rem(My,2)==0)
        error('h size must be odd');
end

Nx=(Mx-1)/2;
Ny=(My-1)/2;
It=padarray(I, [Nx,Ny], 'replicate');
%It=im_expand(I,Nx,Ny);

I2=filter2(h,It);
I_out=I2((Nx+1):end-Nx,(Ny+1):end-Ny);
