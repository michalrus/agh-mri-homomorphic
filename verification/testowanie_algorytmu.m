%% A) wczytywanie danych MR
close all;
clear all;
load Mapa_grappa.mat;
load mri.mat;

% maska binarna
se = strel('disk', 5);
mask = imclose(imfill(I > 5, 'holes'), se);
Omega_delta = sum(mask(:));


%% B) wczytanie estymowanych map i mapy SNR + estymacja
MR_Gaussian_Map = csvread('MR_Gaussian_Map.csv');
MR_Rician_Map = csvread('MR_Rician_Map.csv');
MR_SNR =  csvread('MR_SNR.csv');
MR_noisy =  csvread('MR_noisy.csv');


% UWAGA!
% Ponizej nalezy odkomentowac odpowiedni wariant algorytmu 

% estymacja EM przy znanym SNR
[MapaR, MapaG] = rice_homomorf_est(MR_noisy, MR_SNR, 3.4, 2);

% estymacja EM przy nieznanym SNR
%[MapaR, MapaG] = rice_homomorf_est(MR_noisy, 0, 3.4, 2);

% estymacja local mean przy znanym SNR
%[MapaR, MapaG] = rice_homomorf_est(MR_noisy, MR_SNR, 3.4, 1);

% estymacja local mean przy nieznanym SNR
%[MapaR, MapaG] = rice_homomorf_est(MR_noisy, 0, 3.4, 1);



% 1) Porownanie wizualne estymowanych map
figure(1), imshow([MapaG, MR_Gaussian_Map, MapaR, MR_Rician_Map], []); colorbar; colormap(jet);

% 2) Porownanie wizualne bledow estymowanych map
figure(2), imshow(abs([MapaG-Mapa, MR_Gaussian_Map-Mapa, MapaR-Mapa, MR_Rician_Map-Mapa]./repmat(Mapa, 1, 4)), []); colorbar; colormap(jet); caxis([0, 1]);

% 3) Porownanie wizualne roznicy miedzy estymowanymi mapami
figure(3), imshow(abs([MapaG - MR_Gaussian_Map, MapaR - MR_Rician_Map]), []); colorbar; colormap(jet);


% 4) Wyznaczenie bledow
RE = zeros(1, 4);
RE(1) = sum(sum(mask.*abs(MapaG - Mapa)./Mapa))./Omega_delta;
RE(2) = sum(sum(mask.*abs(MR_Gaussian_Map - Mapa)./Mapa))./Omega_delta;
RE(3) = sum(sum(mask.*abs(MapaR - Mapa)./Mapa))./Omega_delta;
RE(4) = sum(sum(mask.*abs(MR_Rician_Map - Mapa)./Mapa))./Omega_delta;
RE 

% 5) Wyznaczenie roznicy miedzy estymowanymi mapami (Matlab vs. implementacja)
RE_diff = zeros(1, 2);
RE_diff(1) = sum(sum(mask.*abs(MapaG - MR_Gaussian_Map)))./Omega_delta;
RE_diff(2) = sum(sum(mask.*abs(MapaR - MR_Rician_Map)))./Omega_delta;
RE_diff


% 6) Wyznaczenie roznicy miedzy estymowanymi mapami (Matlab vs. implementacja)
RE_diff_max = zeros(1, 2);
RE_diff_max(1) = max(max(mask.*abs(MapaG - MR_Gaussian_Map)));
RE_diff_max(2) = max(max(mask.*abs(MapaR - MR_Rician_Map)));
RE_diff_max


