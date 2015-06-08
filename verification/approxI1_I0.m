function M=approxI1_I0(z)
%APROXIMATION of BESSELI. Avoids problems
%
% M=I1(z)/I0(z)

% Santiago Aja-Fernandez (V1.0)
% LPI 
% www.lpi.tel.uva.es/~santi
% sanaja@tel.uva.es
% LPI Valladolid, Spain
% Original: 06/07/2014, 
% Release   16/12/2014
%
% RICE HOMOMORPHIC TOOLBOX

cont=(z<1.5);
z8=8.*z;

Mn=1-3./z8-15./2./(z8).^2-(3*5*21)./6./(z8).^3;
Md=1+1./z8+9./2./(z8).^2+(25*9)./6./(z8).^3;
M=Mn./Md;

%K=find(isnan(M));
%M(K)=besseli(1,z(K))./besseli(0,z(K));

if (sum(cont)>1)
K=find(z<1.5);
M(K)=besseli(1,z(K))./besseli(0,z(K));
end
K=find(z==0);
M(K)=0;

