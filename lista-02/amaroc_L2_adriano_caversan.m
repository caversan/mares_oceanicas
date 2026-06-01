% LISTA DE EXERCICIOS 2 - ANALISE DE MARES OCEANICAS IOC 5801
% ADRIANO CAVERSAN - 1o SEMESTRE 2026
%
% INSTRUCOES: executar com o diretorio de trabalho do MATLAB apontado
% para a pasta lista-02/ (onde este arquivo esta salvo).
%
% Dados: lista-original/Cananeia_2020.dat   (ano mes dia h min s nivel_m)
%        lista-original/Ubatuba_2020.dat    (ano mes dia h min s nivel_m)
%        lista-original/adp_0m.dat          (ano mes dia h min s nivel_cm temp_C EW_cms NS_cms)
% Toolbox: t_tide (pasta t_tide/)

clear all; close all; clc

addpath('t_tide')

%% =======================================================================
%% CANANEIA 2020 - CARREGAMENTO E PRE-PROCESSAMENTO
%% =======================================================================

fprintf('\n>>> Carregando Cananeia 2020 <<<\n')
load lista-original/Cananeia_2020.dat
x = Cananeia_2020;
nudad_can = size(x, 1);

ano_can  = x(:,1); mes_can = x(:,2); dia_can = x(:,3);
hora_can = x(:,4); min_can = x(:,5); seg_can = x(:,6);
nimar_can_orig = x(:,7);

t_can = datenum(ano_can, mes_can, dia_can, hora_can, min_can, seg_can);

media_can  = mean(nimar_can_orig);
nimar_can  = nimar_can_orig - media_can;
fprintf('Media subtraida (Cananeia): %.4f m\n', media_can)

%% -----------------------------------------------------------------------
%% QUESTAO 1 - Serie temporal + analise harmonica + previsao (Cananeia)
%% -----------------------------------------------------------------------
fprintf('\n--- Q1: Analise harmonica - Cananeia ---\n')

% Plot da serie temporal original
figure
plot(t_can, nimar_can_orig, 'b', 'LineWidth', 1)
datetick('x', 'mmm', 'keeplimits')
axis([t_can(1) t_can(end) -inf inf])
grid on
xlabel('Meses de 2020', 'fontsize', 12)
ylabel('Nivel do mar (m)', 'fontsize', 12)
title('Q1: Cananeia 2020 - Serie temporal de nivel do mar', 'fontsize', 12)
print -dpng plot/q01_cananeia_serie

% Analise harmonica com t_tide (intervalo horario, lat -25.017)
[can_estrut, can_prev] = t_tide(nimar_can, 'interval', 1, ...
    'start',    datenum([2020 1 1 0 0 0]), ...
    'latitude', -25.017, ...
    'error',    'linear', ...
    'synthesis', 2, ...
    'rayleigh',  1, ...
    'output',   'data-tmp/cananeia_ctes.dat');

% Nivel medido vs previsao no mesmo grafico
figure
plot(t_can, nimar_can, 'b', 'LineWidth', 0.8)
hold on
plot(t_can, can_prev, 'r', 'LineWidth', 1.5)
datetick('x', 'mmm', 'keeplimits')
axis([t_can(1) t_can(end) -inf inf])
grid on
legend('Nivel medido', 'Previsao de mare', 'Location', 'best')
xlabel('Meses de 2020', 'fontsize', 12)
ylabel('Nivel do mar (m)', 'fontsize', 12)
title('Q1: Cananeia 2020 - Nivel medido e previsao de mare', 'fontsize', 12)
print -dpng plot/q01_cananeia_medido_prev

% Detalhe de um mes para visualizacao das ondas de mare
idx_jan = (mes_can == 1);
figure
plot(t_can(idx_jan), nimar_can(idx_jan), 'b', 'LineWidth', 1.2)
hold on
plot(t_can(idx_jan), can_prev(idx_jan), 'r', 'LineWidth', 1.5)
datetick('x', 'dd/mm', 'keeplimits')
grid on
legend('Nivel medido', 'Previsao de mare', 'Location', 'best')
xlabel('Dias de janeiro de 2020', 'fontsize', 12)
ylabel('Nivel do mar (m)', 'fontsize', 12)
title('Q1: Cananeia - Detalhe janeiro 2020', 'fontsize', 12)
print -dpng plot/q01_cananeia_detalhe_jan

%% -----------------------------------------------------------------------
%% QUESTAO 2 - Residual (medicao - previsao), estatistica e FFT
%% -----------------------------------------------------------------------
fprintf('\n--- Q2: Residual - Cananeia ---\n')

residual_can = nimar_can - can_prev;

% Plot do residual
figure
plot(t_can, residual_can, 'g', 'LineWidth', 0.8)
datetick('x', 'mmm', 'keeplimits')
axis([t_can(1) t_can(end) -inf inf])
grid on
xlabel('Meses de 2020', 'fontsize', 12)
ylabel('Residual (m)', 'fontsize', 12)
title('Q2: Cananeia 2020 - Serie residual (medido - previsao)', 'fontsize', 12)
print -dpng plot/q02_cananeia_residual

fprintf('\n----- ESTATISTICA DO RESIDUAL (Cananeia) -----\n')
fprintf('Media:        %8.4f m\n', mean(residual_can))
fprintf('Mediana:      %8.4f m\n', median(residual_can))
fprintf('Desv. Padrao: %8.4f m\n', std(residual_can))
fprintf('Minimo:       %8.4f m\n', min(residual_can))
fprintf('Maximo:       %8.4f m\n', max(residual_can))
fprintf('Curtose:      %8.4f\n',   kurtosis(residual_can))
fprintf('Assimetria:   %8.4f\n',   skewness(residual_can))

% FFT do residual
n2_res     = floor(nudad_can/2);
Tn_dias_res = nudad_can ./ (1:n2_res) / 24;
res_ac     = residual_can - mean(residual_can);
a_fft_res  = abs(fft(res_ac));
a_fft_res  = a_fft_res(2:n2_res+1) / n2_res;

figure
bar(Tn_dias_res, a_fft_res)
axis([0 30 0 max(a_fft_res)*1.1])
grid on
xlabel('Periodo (dias)', 'fontsize', 12)
ylabel('Amplitude (m)', 'fontsize', 12)
title('Q2: Cananeia 2020 - FFT do residual', 'fontsize', 12)
print -dpng plot/q02_cananeia_residual_fft

%% -----------------------------------------------------------------------
%% QUESTAO 3 - Filtro S24S25S25 (nivel medio do mar), estatistica e FFT
%% -----------------------------------------------------------------------
fprintf('\n--- Q3: Filtro S24S25S25 - Cananeia ---\n')

xxmed1_can  = nimar_can;
xxmed2_can  = nimar_can;
nimed_can   = nimar_can;

for ndad = 13:nudad_can-12
    xxmed1_can(ndad) = mean(nimar_can(ndad-12:ndad+11));   % S24
end
for ndad = 13:nudad_can-12
    xxmed2_can(ndad) = mean(xxmed1_can(ndad-12:ndad+12));  % S25
end
for ndad = 13:nudad_can-12
    nimed_can(ndad)  = mean(xxmed2_can(ndad-12:ndad+12));  % S25
end

for ndad = 1:12                         % preencher borda inicial
    nimed_can(ndad) = nimed_can(13);
end
for ndad = nudad_can-11:nudad_can       % preencher borda final
    nimed_can(ndad) = nimed_can(nudad_can-12);
end

% Plot nivel do mar e nivel medio
figure
plot(t_can, nimar_can, 'b', 'LineWidth', 0.6)
hold on
plot(t_can, nimed_can, 'r', 'LineWidth', 2.5)
datetick('x', 'mmm', 'keeplimits')
axis([t_can(1) t_can(end) -inf inf])
grid on
legend('Nivel do mar', 'Nivel medio (S24S25S25)', 'Location', 'best')
xlabel('Meses de 2020', 'fontsize', 12)
ylabel('Nivel (m)', 'fontsize', 12)
title('Q3: Cananeia 2020 - Nivel medio do mar (filtro S24S25S25)', 'fontsize', 12)
print -dpng plot/q03_cananeia_nimed

fprintf('\n----- ESTATISTICA DO NIVEL MEDIO (Cananeia) -----\n')
fprintf('Media:        %8.4f m\n', mean(nimed_can))
fprintf('Desv. Padrao: %8.4f m\n', std(nimed_can))
fprintf('Minimo:       %8.4f m\n', min(nimed_can))
fprintf('Maximo:       %8.4f m\n', max(nimed_can))
fprintf('Curtose:      %8.4f\n',   kurtosis(nimed_can))
fprintf('Assimetria:   %8.4f\n',   skewness(nimed_can))

% FFT do nivel medio
n2_nm      = floor(nudad_can/2);
Tn_dias_nm  = nudad_can ./ (1:n2_nm) / 24;
nimed_ac   = nimed_can - mean(nimed_can);
a_fft_nm   = abs(fft(nimed_ac));
a_fft_nm   = a_fft_nm(2:n2_nm+1) / n2_nm;

figure
bar(Tn_dias_nm, a_fft_nm)
axis([0 60 0 max(a_fft_nm)*1.1])
grid on
xlabel('Periodo (dias)', 'fontsize', 12)
ylabel('Amplitude (m)', 'fontsize', 12)
title('Q3: Cananeia 2020 - FFT do nivel medio do mar', 'fontsize', 12)
print -dpng plot/q03_cananeia_nimed_fft

%% -----------------------------------------------------------------------
%% QUESTAO 4 - Probabilidades de excedencia/nao excedencia e periodos de retorno
%% -----------------------------------------------------------------------
fprintf('\n--- Q4: Probabilidades e periodos de retorno - Cananeia ---\n')

% Trabalhar com as series com media restituida
nimar_q4 = nimar_can_orig;
mare_q4  = can_prev + media_can;
nimed_q4 = nimed_can + media_can;

series_q4 = {nimar_q4, mare_q4, nimed_q4};
nomes_q4  = {'Nivel do mar', 'Mare (previsao)', 'Nivel medio'};
cores_q4  = {'b', 'r', 'g'};
dt_q4     = 1;   % dados horarios

% Ajuste de distribuicao normal e calculo analitico das probabilidades
dprob    = 1e-5;
probab_v = (dprob:dprob:1-dprob)';

nivel_mu_cell   = cell(1,3);
prob_exced_cell = cell(1,3);
prob_naoex_cell = cell(1,3);
per_ret_cell    = cell(1,3);

for k = 1:3
    mu_k    = mean(series_q4{k});
    sigma_k = std(series_q4{k});
    pd_k    = makedist('Normal', mu_k, sigma_k);

    nivel_v            = icdf(pd_k, probab_v);
    nivel_mu_cell{k}   = nivel_v - mu_k;
    prob_naoex_cell{k} = probab_v * 100;
    prob_exced_cell{k} = 100 - prob_naoex_cell{k};

    per_ret_v = zeros(size(probab_v));
    mask = nivel_v < mu_k;
    per_ret_v(mask)  = 1 ./ (8766 .* probab_v(mask)      ./ dt_q4);
    per_ret_v(~mask) = 1 ./ (8766 .* (1-probab_v(~mask)) ./ dt_q4);
    per_ret_cell{k} = per_ret_v;
end

% Probabilidade de excedencia
figure
hold on
for k = 1:3
    plot(nivel_mu_cell{k}, prob_exced_cell{k}, cores_q4{k}, 'LineWidth', 1.5)
end
grid on
legend(nomes_q4, 'Location', 'northeast')
xlabel('Nivel relativo a media (m)', 'fontsize', 12)
ylabel('Probabilidade de excedencia (%)', 'fontsize', 12)
title('Q4: Cananeia 2020 - Probabilidades de excedencia', 'fontsize', 12)
print -dpng plot/q04_excedencia

% Probabilidade de nao excedencia
figure
hold on
for k = 1:3
    plot(nivel_mu_cell{k}, prob_naoex_cell{k}, cores_q4{k}, 'LineWidth', 1.5)
end
grid on
legend(nomes_q4, 'Location', 'northwest')
xlabel('Nivel relativo a media (m)', 'fontsize', 12)
ylabel('Probabilidade de nao excedencia (%)', 'fontsize', 12)
title('Q4: Cananeia 2020 - Probabilidades de nao excedencia', 'fontsize', 12)
print -dpng plot/q04_nao_excedencia

% Periodos de retorno
figure
hold on
for k = 1:3
    plot(nivel_mu_cell{k}, per_ret_cell{k}, cores_q4{k}, 'LineWidth', 1.5)
end
grid on
legend(nomes_q4, 'Location', 'best')
xlabel('Nivel relativo a media (m)', 'fontsize', 12)
ylabel('Periodo de retorno (anos)', 'fontsize', 12)
title('Q4: Cananeia 2020 - Periodos de retorno', 'fontsize', 12)
print -dpng plot/q04_retorno

% Tabela resumo de niveis caracteristicos
fprintf('\n--- Niveis (relat. media) para periodos de retorno selecionados (Cananeia) ---\n')
T_ref = [0.5, 1, 2, 5, 10];   % anos
fprintf('%-20s', 'T_retorno(anos)'); fprintf('%8.1f', T_ref); fprintf('\n')
for k = 1:3
    fprintf('%-20s', nomes_q4{k})
    for tr = T_ref
        [~, idx_tr] = min(abs(per_ret_cell{k} - tr));
        fprintf('%8.4f', nivel_mu_cell{k}(idx_tr))
    end
    fprintf('\n')
end

%% =======================================================================
%% UBATUBA 2020 - CARREGAMENTO E ANALISE HARMONICA
%% =======================================================================

fprintf('\n>>> Carregando Ubatuba 2020 <<<\n')
load lista-original/Ubatuba_2020.dat
x = Ubatuba_2020;
nudad_uba = size(x, 1);

ano_uba  = x(:,1); mes_uba = x(:,2); dia_uba = x(:,3);
hora_uba = x(:,4); min_uba = x(:,5); seg_uba = x(:,6);
nimar_uba_orig = x(:,7);

t_uba = datenum(ano_uba, mes_uba, dia_uba, hora_uba, min_uba, seg_uba);

media_uba = mean(nimar_uba_orig);
nimar_uba = nimar_uba_orig - media_uba;
fprintf('Media subtraida (Ubatuba): %.4f m\n', media_uba)

fprintf('\n--- Analise harmonica - Ubatuba ---\n')
[uba_estrut, uba_prev] = t_tide(nimar_uba, 'interval', 1, ...
    'start',    datenum([2020 1 1 0 0 0]), ...
    'latitude', -23.500, ...
    'error',    'linear', ...
    'synthesis', 2, ...
    'rayleigh',  1, ...
    'output',   'data-tmp/ubatuba_ctes.dat');

%% -----------------------------------------------------------------------
%% QUESTAO 5 - Amplificacao/atenuacao e atrasos M2, S2, K1, O1
%% -----------------------------------------------------------------------
fprintf('\n--- Q5: Amplificacao e atrasos - Cananeia vs Ubatuba ---\n')

comps_q5  = {'M2',      'S2',      'K1',      'O1'};
omega_q5  = [28.9841,   30.0000,   15.0411,   13.9430];  % graus/hora

nomes_can_str = cellstr(can_estrut.name);
nomes_uba_str = cellstr(uba_estrut.name);

H_can_q5 = zeros(1,4);  H_uba_q5 = zeros(1,4);
g_can_q5 = zeros(1,4);  g_uba_q5 = zeros(1,4);
amplif_q5 = zeros(1,4); atraso_q5 = zeros(1,4);

fprintf('\n%-5s  %8s  %8s  %8s  %8s  %10s  %10s\n', ...
    'Comp','H_Can(m)','G_Can(g)','H_Uba(m)','G_Uba(g)','H_uba/H_can','Atraso(h)')
fprintf('%s\n', repmat('-',1,72))

for k = 1:4
    idx_c = find(strcmp(strtrim(nomes_can_str), comps_q5{k}), 1);
    idx_u = find(strcmp(strtrim(nomes_uba_str), comps_q5{k}), 1);

    if isempty(idx_c) || isempty(idx_u)
        fprintf('%-5s  componente nao encontrada\n', comps_q5{k})
        continue
    end

    H_can_q5(k) = can_estrut.tidecon(idx_c, 1);
    g_can_q5(k) = can_estrut.tidecon(idx_c, 3);
    H_uba_q5(k) = uba_estrut.tidecon(idx_u, 1);
    g_uba_q5(k) = uba_estrut.tidecon(idx_u, 3);

    amplif_q5(k) = H_uba_q5(k) / H_can_q5(k);
    dg = g_uba_q5(k) - g_can_q5(k);
    dg = mod(dg + 180, 360) - 180;         % normalizar para [-180, 180]
    atraso_q5(k) = dg / omega_q5(k);       % horas (+ = Ubatuba atrasa)

    fprintf('%-5s  %8.4f  %8.2f  %8.4f  %8.2f  %10.4f  %10.2f\n', ...
        comps_q5{k}, H_can_q5(k), g_can_q5(k), ...
        H_uba_q5(k), g_uba_q5(k), amplif_q5(k), atraso_q5(k))
end

% Grafico de amplitudes comparativas
figure
x_q5 = 1:4;
bar(x_q5 - 0.2, H_can_q5, 0.35, 'b')
hold on
bar(x_q5 + 0.2, H_uba_q5, 0.35, 'r')
grid on
set(gca, 'XTick', 1:4, 'XTickLabel', comps_q5, 'fontsize', 11)
legend('Cananeia', 'Ubatuba', 'Location', 'best')
xlabel('Componente de mare', 'fontsize', 12)
ylabel('Amplitude (m)', 'fontsize', 12)
title('Q5: Amplitudes de M2, S2, K1, O1 - Cananeia vs Ubatuba', 'fontsize', 12)
print -dpng plot/q05_amplitudes_comp

% Grafico dos atrasos
figure
bar(1:4, atraso_q5, 0.5, 'FaceColor', [0.4 0.6 0.9])
grid on
set(gca, 'XTick', 1:4, 'XTickLabel', comps_q5, 'fontsize', 11)
xlabel('Componente de mare', 'fontsize', 12)
ylabel('Atraso Ubatuba em relacao a Cananeia (h)', 'fontsize', 12)
title('Q5: Atrasos de fase - Cananeia -> Ubatuba', 'fontsize', 12)
print -dpng plot/q05_atrasos

%% -----------------------------------------------------------------------
%% QUESTAO 6 - Nivel medio Cananeia vs Ubatuba, estatistica e xcorr
%% -----------------------------------------------------------------------
fprintf('\n--- Q6: Nivel medio - Cananeia vs Ubatuba ---\n')

% Filtro S24S25S25 para Ubatuba
xxmed1_uba = nimar_uba;
xxmed2_uba = nimar_uba;
nimed_uba  = nimar_uba;

for ndad = 13:nudad_uba-12
    xxmed1_uba(ndad) = mean(nimar_uba(ndad-12:ndad+11));
end
for ndad = 13:nudad_uba-12
    xxmed2_uba(ndad) = mean(xxmed1_uba(ndad-12:ndad+12));
end
for ndad = 13:nudad_uba-12
    nimed_uba(ndad)  = mean(xxmed2_uba(ndad-12:ndad+12));
end

for ndad = 1:12
    nimed_uba(ndad) = nimed_uba(13);
end
for ndad = nudad_uba-11:nudad_uba
    nimed_uba(ndad) = nimed_uba(nudad_uba-12);
end

% Plot comparativo
figure
plot(t_can, nimed_can, 'b', 'LineWidth', 2)
hold on
plot(t_uba, nimed_uba, 'r', 'LineWidth', 2)
datetick('x', 'mmm', 'keeplimits')
grid on
legend('Cananeia', 'Ubatuba', 'Location', 'best')
xlabel('Meses de 2020', 'fontsize', 12)
ylabel('Nivel medio (m)', 'fontsize', 12)
title('Q6: Nivel medio do mar - Cananeia vs Ubatuba', 'fontsize', 12)
print -dpng plot/q06_nimed_comparacao

% Parametros estatisticos comparativos
N_min = min(nudad_can, nudad_uba);
nm_can_v = nimed_can(1:N_min);
nm_uba_v = nimed_uba(1:N_min);

r_mat = corrcoef(nm_can_v, nm_uba_v);
r_nm  = r_mat(1,2);
bias  = mean(nm_uba_v - nm_can_v);
rmse  = sqrt(mean((nm_uba_v - nm_can_v).^2));

% Indice de concordancia de Willmott
num_w  = sum((nm_uba_v - nm_can_v).^2);
den_w  = sum((abs(nm_uba_v - mean(nm_can_v)) + abs(nm_can_v - mean(nm_can_v))).^2);
willmott = 1 - num_w/den_w;

fprintf('\n----- ESTATISTICA COMPARATIVA DO NIVEL MEDIO -----\n')
fprintf('Correlacao r:    %.4f\n', r_nm)
fprintf('R2:              %.4f\n', r_nm^2)
fprintf('Vies (Uba-Can):  %.4f m\n', bias)
fprintf('RMSE:            %.4f m\n', rmse)
fprintf('Willmott d:      %.4f\n', willmott)

% Correlacao cruzada
[xcorr_nm, lags_nm] = xcorr(nm_can_v, nm_uba_v, 120, 'coeff');
[max_xcnm, idx_xcnm] = max(xcorr_nm);
lag_h_nm = lags_nm(idx_xcnm);

fprintf('Max xcorr nivel medio: %.4f em defasagem = %d h\n', max_xcnm, lag_h_nm)

figure
plot(lags_nm, xcorr_nm, 'b', 'LineWidth', 1.5)
hold on
plot(lag_h_nm, max_xcnm, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r')
plot([lags_nm(1) lags_nm(end)], [0 0], 'k--')
grid on
xlabel('Defasagem (horas)', 'fontsize', 12)
ylabel('Correlacao cruzada normalizada', 'fontsize', 12)
title('Q6: Correlacao cruzada do nivel medio - Cananeia vs Ubatuba', 'fontsize', 12)
text(lag_h_nm+2, max_xcnm-0.03, sprintf('r=%.3f, lag=%dh', max_xcnm, lag_h_nm), 'fontsize', 11)
print -dpng plot/q06_nimed_xcorr

%% =======================================================================
%% SANTOS - CARREGAMENTO E PRE-PROCESSAMENTO (adp_0m.dat)
%% =======================================================================

fprintf('\n>>> Carregando dados de Santos (adp_0m.dat) <<<\n')
load lista-original/adp_0m.dat
x = adp_0m;
nudad_snt = size(x, 1);

ano_snt  = x(:,1); mes_snt = x(:,2); dia_snt = x(:,3);
hora_snt = x(:,4); min_snt = x(:,5); seg_snt = x(:,6);
nivel_snt_cm = x(:,7);
temp_snt     = x(:,8);
ew_snt_cm    = x(:,9);
ns_snt_cm    = x(:,10);

% Converter cm para m (e cm/s para m/s)
nivel_snt_orig = nivel_snt_cm / 100;
ew_snt_orig    = ew_snt_cm    / 100;
ns_snt_orig    = ns_snt_cm    / 100;

t_snt = datenum(ano_snt, mes_snt, dia_snt, hora_snt, min_snt, seg_snt);

% Subtrair medias
media_nivel = mean(nivel_snt_orig);
media_ew    = mean(ew_snt_orig);
media_ns    = mean(ns_snt_orig);

nivel_snt = nivel_snt_orig - media_nivel;
ew_snt    = ew_snt_orig    - media_ew;
ns_snt    = ns_snt_orig    - media_ns;

fprintf('Media subtraida - nivel: %.4f m | EW: %.4f m/s | NS: %.4f m/s\n', ...
    media_nivel, media_ew, media_ns)

dt_snt  = 0.5;      % intervalo de amostragem em horas (30 min)
lat_snt = -24.013;
t_ini_snt = datenum([ano_snt(1) mes_snt(1) dia_snt(1) hora_snt(1) min_snt(1) 0]);

%% -----------------------------------------------------------------------
%% QUESTAO 7 - Correntes EW e NS: serie, analise harmonica e previsao
%% -----------------------------------------------------------------------
fprintf('\n--- Q7: Analise de correntes de mare - Santos ---\n')

% Plot das series originais
figure
subplot(2,1,1)
plot(t_snt, ew_snt_orig, 'b', 'LineWidth', 1)
datetick('x', 'dd/mm', 'keeplimits')
grid on
ylabel('Corrente EW (m/s)', 'fontsize', 11)
title('Q7: Santos - Series de correntes EW e NS', 'fontsize', 12)

subplot(2,1,2)
plot(t_snt, ns_snt_orig, 'r', 'LineWidth', 1)
datetick('x', 'dd/mm', 'keeplimits')
grid on
xlabel('Data (dd/mm)', 'fontsize', 11)
ylabel('Corrente NS (m/s)', 'fontsize', 11)
print -dpng plot/q07_santos_series

% Analise harmonica: EW e NS separados + analise rotacional (complexo)
[ew_estrut, ew_prev] = t_tide(ew_snt, 'interval', dt_snt, ...
    'start',    t_ini_snt, ...
    'latitude', lat_snt, ...
    'error',    'linear', ...
    'synthesis', 2, ...
    'rayleigh',  1, ...
    'output',   'data-tmp/santos_ctes_ew.dat');

[ns_estrut, ns_prev] = t_tide(ns_snt, 'interval', dt_snt, ...
    'start',    t_ini_snt, ...
    'latitude', lat_snt, ...
    'error',    'linear', ...
    'synthesis', 2, ...
    'rayleigh',  1, ...
    'output',   'data-tmp/santos_ctes_ns.dat');

% Analise rotacional (corrente complexa u + iv)
corren_snt = ew_snt + 1i * ns_snt;
[corr_rot_estrut, corr_rot_prev] = t_tide(corren_snt, 'interval', dt_snt, ...
    'start',    t_ini_snt, ...
    'latitude', lat_snt, ...
    'error',    'linear', ...
    'synthesis', 2, ...
    'rayleigh',  1, ...
    'output',   'data-tmp/santos_ctes_rotacional.dat');

ew_prev_rot = real(corr_rot_prev);
ns_prev_rot = imag(corr_rot_prev);

% Plot medido vs previsao
figure
subplot(2,1,1)
plot(t_snt, ew_snt, 'b', 'LineWidth', 0.8)
hold on
plot(t_snt, ew_prev_rot, 'r', 'LineWidth', 1.5)
datetick('x', 'dd/mm', 'keeplimits')
grid on
legend('EW medido', 'EW previsao', 'Location', 'best')
ylabel('Corrente EW (m/s)', 'fontsize', 11)
title('Q7: Santos - Correntes medidas vs previsao de mare', 'fontsize', 12)

subplot(2,1,2)
plot(t_snt, ns_snt, 'b', 'LineWidth', 0.8)
hold on
plot(t_snt, ns_prev_rot, 'r', 'LineWidth', 1.5)
datetick('x', 'dd/mm', 'keeplimits')
grid on
legend('NS medido', 'NS previsao', 'Location', 'best')
xlabel('Data (dd/mm)', 'fontsize', 11)
ylabel('Corrente NS (m/s)', 'fontsize', 11)
print -dpng plot/q07_santos_prev

%% -----------------------------------------------------------------------
%% QUESTAO 8 - Elipses de correntes de mare M2, S2, K1, O1
%% -----------------------------------------------------------------------
fprintf('\n--- Q8: Elipses de correntes - Santos ---\n')

comps_elip = {'M2',    'S2',    'K1',    'O1'};
omega_elip = [28.9841, 30.0000, 15.0411, 13.9430];   % graus/hora
T_elip     = 360 ./ omega_elip;                       % periodo em horas

nomes_ew_str = cellstr(ew_estrut.name);
nomes_ns_str = cellstr(ns_estrut.name);

conv = pi/180;

figure
for k = 1:4
    comp  = comps_elip{k};
    idx_e = find(strcmp(strtrim(nomes_ew_str), comp), 1);
    idx_n = find(strcmp(strtrim(nomes_ns_str), comp), 1);

    if isempty(idx_e) || isempty(idx_n)
        fprintf('Componente %s nao encontrada nos dados de Santos\n', comp)
        continue
    end

    H_ew = ew_estrut.tidecon(idx_e, 1);
    g_ew = ew_estrut.tidecon(idx_e, 3);
    H_ns = ns_estrut.tidecon(idx_n, 1);
    g_ns = ns_estrut.tidecon(idx_n, 3);

    % Gerar um periodo completo da componente
    tempo_el = linspace(0, T_elip(k), 200);
    ew_el    = H_ew * cos((omega_elip(k) * tempo_el - g_ew) * conv);
    ns_el    = H_ns * cos((omega_elip(k) * tempo_el - g_ns) * conv);

    subplot(2,2,k)
    plot(ew_el, ns_el, 'b', 'LineWidth', 2)
    hold on
    mat_zero = zeros(size(ew_el));
    quiver(mat_zero, mat_zero, ew_el, ns_el, 'r', 'LineWidth', 1)
    plot(0, 0, 'k+', 'MarkerSize', 10, 'LineWidth', 2)
    text(ew_el(1), ns_el(1), 't=0', 'fontsize', 9)
    axis equal
    grid on
    xlabel('EW (m/s)', 'fontsize', 10)
    ylabel('NS (m/s)', 'fontsize', 10)
    title(['Q8: Elipse ' comp], 'fontsize', 11)

    fprintf('%s: H_ew=%.4f m/s, g_ew=%.2f g, H_ns=%.4f m/s, g_ns=%.2f g\n', ...
        comp, H_ew, g_ew, H_ns, g_ns)
end
print -dpng plot/q08_elipses

%% -----------------------------------------------------------------------
%% QUESTAO 9 - Series residuais de correntes EW e NS
%% -----------------------------------------------------------------------
fprintf('\n--- Q9: Residuais de correntes - Santos ---\n')

residual_ew = ew_snt - ew_prev_rot;
residual_ns = ns_snt - ns_prev_rot;

figure
subplot(2,1,1)
plot(t_snt, residual_ew, 'b', 'LineWidth', 0.8)
datetick('x', 'dd/mm', 'keeplimits')
grid on
ylabel('Residual EW (m/s)', 'fontsize', 11)
title('Q9: Santos - Residuais de correntes (medido - previsao)', 'fontsize', 12)

subplot(2,1,2)
plot(t_snt, residual_ns, 'r', 'LineWidth', 0.8)
datetick('x', 'dd/mm', 'keeplimits')
grid on
xlabel('Data (dd/mm)', 'fontsize', 11)
ylabel('Residual NS (m/s)', 'fontsize', 11)
print -dpng plot/q09_residuais

fprintf('\n----- ESTATISTICA DOS RESIDUAIS (Santos) -----\n')
fprintf('EW  - Media: %8.4f | DP: %8.4f | Min: %8.4f | Max: %8.4f\n', ...
    mean(residual_ew), std(residual_ew), min(residual_ew), max(residual_ew))
fprintf('NS  - Media: %8.4f | DP: %8.4f | Min: %8.4f | Max: %8.4f\n', ...
    mean(residual_ns), std(residual_ns), min(residual_ns), max(residual_ns))

%% -----------------------------------------------------------------------
%% QUESTAO 10 - Nivel do mar vs temperatura: estatisticas e correlacoes cruzadas
%% -----------------------------------------------------------------------
fprintf('\n--- Q10: Nivel do mar vs temperatura - Santos ---\n')

% Plot das duas series
figure
subplot(2,1,1)
plot(t_snt, nivel_snt_orig, 'b', 'LineWidth', 1)
datetick('x', 'dd/mm', 'keeplimits')
grid on
axis([t_snt(1) t_snt(end) -inf inf])
ylabel('Nivel do mar (m)', 'fontsize', 11)
title('Q10: Santos - Nivel do mar e temperatura no fundo', 'fontsize', 12)

subplot(2,1,2)
plot(t_snt, temp_snt, 'r', 'LineWidth', 1)
datetick('x', 'dd/mm', 'keeplimits')
grid on
axis([t_snt(1) t_snt(end) -inf inf])
xlabel('Data (dd/mm)', 'fontsize', 11)
ylabel('Temperatura (°C)', 'fontsize', 11)
print -dpng plot/q10_series

% Estatisticas basicas
fprintf('\n----- ESTATISTICA (Santos) -----\n')
fprintf('Nivel do mar - Media: %.4f m   | DP: %.4f | Min: %.4f | Max: %.4f\n', ...
    mean(nivel_snt_orig), std(nivel_snt_orig), min(nivel_snt_orig), max(nivel_snt_orig))
fprintf('Temperatura  - Media: %.4f °C  | DP: %.4f | Min: %.4f | Max: %.4f\n', ...
    mean(temp_snt), std(temp_snt), min(temp_snt), max(temp_snt))

r_nit_mat = corrcoef(nivel_snt_orig, temp_snt);
r_nit     = r_nit_mat(1,2);
fprintf('Correlacao nivel vs temperatura: r = %.4f  R2 = %.4f\n', r_nit, r_nit^2)

% Diagrama de espalhamento
figure
scatter(nivel_snt_orig, temp_snt, 20, 'filled', 'MarkerFaceColor', [0.2 0.5 0.8])
hold on
P_nit  = polyfit(nivel_snt_orig, temp_snt, 1);
x_fit  = [min(nivel_snt_orig) max(nivel_snt_orig)];
plot(x_fit, polyval(P_nit, x_fit), 'r-', 'LineWidth', 2)
grid on
xlabel('Nivel do mar (m)', 'fontsize', 12)
ylabel('Temperatura no fundo (°C)', 'fontsize', 12)
title('Q10: Santos - Diagrama de espalhamento nivel vs temperatura', 'fontsize', 12)
text(min(x_fit)+0.01, max(temp_snt)-0.5, sprintf('r = %.3f', r_nit), 'fontsize', 12)
print -dpng plot/q10_scatter

% Correlacao cruzada (lags em unidades de 30 min -> converter para horas)
max_lag_10  = 96;   % +/- 96 amostras = +/- 48 horas
[xcorr_10, lags_10] = xcorr(nivel_snt - mean(nivel_snt), ...
                             temp_snt  - mean(temp_snt), max_lag_10, 'coeff');
lags_10_h = lags_10 * dt_snt;

[max_xc10, idx_xc10] = max(abs(xcorr_10));
lag_max10_h = lags_10_h(idx_xc10);

fprintf('Max xcorr nivel vs temperatura: %.4f em defasagem = %.1f h\n', ...
    xcorr_10(idx_xc10), lag_max10_h)

figure
plot(lags_10_h, xcorr_10, 'b', 'LineWidth', 1.5)
hold on
plot(lag_max10_h, xcorr_10(idx_xc10), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r')
plot([lags_10_h(1) lags_10_h(end)], [0 0], 'k--')
grid on
xlabel('Defasagem (horas)', 'fontsize', 12)
ylabel('Correlacao cruzada normalizada', 'fontsize', 12)
title('Q10: Santos - Correlacao cruzada nivel do mar vs temperatura', 'fontsize', 12)
text(lag_max10_h+1, xcorr_10(idx_xc10)-0.05, ...
    sprintf('r=%.3f, lag=%.1fh', xcorr_10(idx_xc10), lag_max10_h), 'fontsize', 11)
print -dpng plot/q10_xcorr

%% =======================================================================
fprintf('\n\n========== LISTA 2 CONCLUIDA ==========\n')
fprintf('Plots salvos em lista-02/plot/\n')
fprintf('Arquivos intermediarios em lista-02/data-tmp/\n')
