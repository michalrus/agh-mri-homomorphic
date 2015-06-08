%% A) wczytywanie danych MR
close all;
clear all;
load Mapa_grappa.mat;
load mri.mat;

% maska binarna
se = strel('disk', 5);
mask = imclose(imfill(I > 5, 'holes'), se);
Omega_delta = sum(mask(:));


%% B) generowanie danych + zapis do pliku obrazu zaszumionego (.csv)
In = abs(I+Mapa.*randn(256) + Mapa.*j.*randn(256));
SNR = I./Mapa;

b = -3;
MR_noisy = floor(In.*10.^(-b))./(10.^(-b));
MR_SNR = floor(SNR.*10.^(-b))./(10.^(-b));


figure(1), 
subplot(1, 3, 1); imshow(Mapa, []); colorbar;
subplot(1, 3, 2); imshow(SNR, []); colorbar;
subplot(1, 3, 3); imshow(In, []); colorbar;


% zapis SNR do pliku .csv
csvwrite('MR_SNR.csv', SNR);

% zapis obrazu zaszumionego do pliku .csv
csvwrite('MR_noisy.csv', In);

% !!! UWAGA !!!
% Ponizej nalezy odkomentowac odpowiedni wariant algorytmu 

% estymacja EM przy znanym SNR
[MapaR, MapaG] = rice_homomorf_est(MR_noisy, MR_SNR, 3.4, 2);

% estymacja EM przy nieznanym SNR
%[MapaR, MapaG] = rice_homomorf_est(MR_noisy, 0, 3.4, 2);

% estymacja local mean przy znanym SNR
%[MapaR, MapaG] = rice_homomorf_est(MR_noisy, MR_SNR, 3.4, 1);

% estymacja local mean przy nieznanym SNR
%[MapaR, MapaG] = rice_homomorf_est(MR_noisy, 0, 3.4, 1);

csvwrite('MR_Rician_Map.csv', MapaR);
csvwrite('MR_Gaussian_Map.csv', MapaG);

