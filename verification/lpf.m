function If=lpf(I,sigma,MODO)
%
% LPF low pass filter of images 
%       If=lpf(I,sigma,MODO)
% 
% INPUT:
%   	I:	Input Image
%		sigma:	standard deviation of Gaussian window in 
%               frequancy domain (related to filter bandwidth)
%		MODO:   1: DFT filtering
%               2: DCT filtering
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
%
if(~exist('MODO','var'))
    MODO=2;
end

%MODO==1 DFT
if MODO==1
    [Mx,My]=size(I);
    h=fspecial('gaussian',size(I),sigma);
    h=h./max(h(:));

    if (Mx==1)||(My==1) %1D
        lRnF=fftshift(fft(I));
        %Filtering
        lRnF2=lRnF.*h;
        If=real(ifft(fftshift(lRnF2)));

    else %2D
        lRnF=fftshift(fft2(I));
        %Filtering
        lRnF2=lRnF.*h;
        If=real(ifft2(fftshift(lRnF2)));
    end
%MODO==2 DCT
elseif MODO==2
    [Mx,My]=size(I);
    h=fspecial('gaussian',2.*[Mx,My],sigma.*2);
    h=h./max(h(:));
    h=h((Mx+1):end,(My+1):end);

    if (Mx==1)||(My==1) %1D
        lRnF=dct(I);
        %Filtering
        lRnF2=lRnF.*h;
        If=real(idct(lRnF2));

    else %2D
        lRnF=dct2(I);
        %Filtering
        lRnF2=lRnF.*h;
        If=real(idct2(lRnF2));
    end
end
