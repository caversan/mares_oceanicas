% LISTA DE EXERCICIOS 1 - ANALISE DE MARES OCEANICAS IOC 5801
% ADRIANO CAVERSAN - 1º SEMESTRE 2026
% Dados horarios de nivel do mar de 2020 em Cananeiae Ubatuba (SP, Brasil)

clear all; close all; clc

fprintf('========================================\n')
fprintf('LISTA 1 - ANALISE DE MARES OCEANICAS\n')  
fprintf('ADRIANO CAVERSAN - 2026\n')
fprintf('========================================\n\n')

%% =======================================================================
%% PARTE 1: ANALISE DOS DADOS DE CANANEIA 2020
%% =======================================================================

fprintf('PROCESSANDO DADOS DE CANANEIA 2020...\n\n')

% Leitura dos dados de Cananeia
load Cananeia_2020.dat
cananeia_data = Cananeia_2020;
nudad_can = size(cananeia_data,1);

% Extraindo dados: ano, mes, dia, hora, minuto, segundo, nivel do mar (m)
ano_can = cananeia_data(:,1);
mes_can = cananeia_data(:,2); 
dia_can = cananeia_data(:,3);
hora_can = cananeia_data(:,4);
minuto_can = cananeia_data(:,5);
segundo_can = cananeia_data(:,6);
elev_can_orig = cananeia_data(:,7);  % nivel original

% IMPORTANTE: subtraindo valor medio conforme requisitos
elev_can_media = mean(elev_can_orig);
elev_can = elev_can_orig - elev_can_media;  % dados com media removida

% Criando vetor temporal em dias decimais  
dias_can = (hora_can + minuto_can/60 + segundo_can/3600)/24;
for i = 1:nudad_can
    if i == 1
        dias_can(i) = 0;
    else
        if dia_can(i) ~= dia_can(i-1)
            dias_can(i) = dias_can(i-1) + 1 + (hora_can(i) + minuto_can(i)/60 + segundo_can(i)/3600)/24;
        else
            dias_can(i) = floor(dias_can(i-1)) + (hora_can(i) + minuto_can(i)/60 + segundo_can(i)/3600)/24;
        end
    end
end

fprintf('Dados carregados: %d pontos de Cananeia 2020\n', nudad_can)
fprintf('Media original removida: %.4f m\n\n', elev_can_media)

%% ITEM 1: Parametros estatisticos basicos de Cananeia
fprintf('========================================\n')
fprintf('ITEM 1: PARAMETROS ESTATISTICOS BASICOS - CANANEIA\n')
fprintf('========================================\n')

% Estatisticas manuais (sem toolboxes)
estat_can = zeros(8,1);
estat_can(1) = mean(elev_can);           % Media
estat_can(2) = median(elev_can);         % Mediana
estat_can(4) = std(elev_can);            % Desvio padrao  
estat_can(5) = min(elev_can);            % Minimo
estat_can(6) = max(elev_can);            % Maximo

% Moda manual
[valores_unicos, ~, indices] = unique(elev_can);
contadores = accumarray(indices, 1);
[~, idx_max] = max(contadores);
estat_can(3) = valores_unicos(idx_max);

% Curtose manual
n_dados = length(elev_can);
media_elev = mean(elev_can);
std_elev = std(elev_can);
estat_can(7) = (1/n_dados) * sum(((elev_can - media_elev) / std_elev).^4) - 3;

% Assimetria manual  
estat_can(8) = (1/n_dados) * sum(((elev_can - media_elev) / std_elev).^3);

% Exibindo resultados
fprintf('Media:        %8.4f m\n', estat_can(1));
fprintf('Mediana:      %8.4f m\n', estat_can(2));
fprintf('Moda:         %8.4f m\n', estat_can(3));
fprintf('Desvio Padrao:%8.4f m\n', estat_can(4));
fprintf('Minimo:       %8.4f m\n', estat_can(5));
fprintf('Maximo:       %8.4f m\n', estat_can(6));
fprintf('Curtose:      %8.4f\n', estat_can(7));
fprintf('Assimetria:   %8.4f\n', estat_can(8));
fprintf('Amplitude:    %8.4f m\n\n', estat_can(6) - estat_can(5));

%% ITEM 2: Plotagem da serie temporal com bandas de confiança e tendencia
fprintf('========================================\n')
fprintf('ITEM 2: SERIE TEMPORAL E TENDENCIA - CANANEIA\n') 
fprintf('========================================\n')

% Plot da serie temporal com bandas
figure
plot(dias_can, elev_can, 'LineWidth', 1)
hold on

% Medias e desvios padrao
elmed_can(1:nudad_can) = mean(elev_can);
el1dp_can(1:nudad_can) = mean(elev_can) + estat_can(4);
el1dn_can(1:nudad_can) = mean(elev_can) - estat_can(4);
el2dp_can(1:nudad_can) = mean(elev_can) + 2*estat_can(4);
el2dn_can(1:nudad_can) = mean(elev_can) - 2*estat_can(4);
el3dp_can(1:nudad_can) = mean(elev_can) + 3*estat_can(4);
el3dn_can(1:nudad_can) = mean(elev_can) - 3*estat_can(4);

plot(dias_can, elmed_can, 'r-', 'LineWidth', 2)
plot(dias_can, el1dp_can, 'g--', 'LineWidth', 1)
plot(dias_can, el1dn_can, 'g--', 'LineWidth', 1)
plot(dias_can, el2dp_can, 'm--', 'LineWidth', 1) 
plot(dias_can, el2dn_can, 'm--', 'LineWidth', 1)
plot(dias_can, el3dp_can, 'c--', 'LineWidth', 1)
plot(dias_can, el3dn_can, 'c--', 'LineWidth', 1)

grid on
title('Cananeia 2020 - Nivel do Mar (bandas de confianca)', 'fontsize', 12)
xlabel('Dias', 'fontsize', 12)
ylabel('Nivel do Mar (m)', 'fontsize', 12)
legend('Dados', 'Media', '±1σ', '±1σ', '±2σ', '±2σ', '±3σ', '±3σ', 'Location', 'best')
print -dpng cananeia_2020_serie_bandas

% Analise de tendencia
polinom_can = polyfit(dias_can, elev_can, 1);
tend_can = polinom_can(1);  % coeficiente angular (m/dia)
elev_tend_can = polyval(polinom_can, dias_can);

figure  
plot(dias_can, elev_can, 'b-', 'LineWidth', 1)
hold on
plot(dias_can, elev_tend_can, 'r-', 'LineWidth', 2)
grid on
title('Cananeia 2020 - Tendencia Linear', 'fontsize', 12)
xlabel('Dias', 'fontsize', 12)
ylabel('Nivel do Mar (m)', 'fontsize', 12)
legend('Dados Originais', sprintf('Tendencia = %.6f m/dia', tend_can), 'Location', 'best')
print -dpng cananeia_2020_tendencia

fprintf('Taxa de variacao (tendencia): %.6f m/dia\n', tend_can)
fprintf('Taxa de variacao anual: %.4f m/ano\n\n', tend_can * 365.25)

%% ITEM 3: Histograma e percentis
fprintf('========================================\n')
fprintf('ITEM 3: HISTOGRAMA E PERCENTIS - CANANEIA\n')
fprintf('========================================\n')

% Histograma
figure
[counts_can, centers_can] = hist(elev_can, 30);
hist(elev_can, 30)
grid on
title('Cananeia 2020 - Histograma do Nivel do Mar', 'fontsize', 12)
xlabel('Nivel do Mar (m)', 'fontsize', 12)
ylabel('Numero de Ocorrencias', 'fontsize', 12)
print -dpng cananeia_2020_histograma

% Maximo numero de observacoes no histograma
[max_obs_can, idx_max_can] = max(counts_can);
fprintf('Maximo numero de observacoes: %d (classe %.4f m)\n', max_obs_can, centers_can(idx_max_can));

% Percentis manuais
percentuais = [10, 25, 75, 90];
elev_sorted_can = sort(elev_can);
n_total_can = length(elev_sorted_can);

fprintf('Percentis:\n');
for i = 1:length(percentuais)
    idx = round((percentuais(i)/100) * (n_total_can-1)) + 1;
    if idx > n_total_can
        idx = n_total_can;
    end
    perc_val = elev_sorted_can(idx);
    fprintf('%2dº percentil: %8.4f m\n', percentuais(i), perc_val);
end

% Plot dos percentis completos
percentuais_completos = [0:1:100];
percentis_can = zeros(size(percentuais_completos));
for i = 1:length(percentuais_completos)
    idx = round((percentuais_completos(i)/100) * (n_total_can-1)) + 1;
    if idx > n_total_can
        idx = n_total_can;
    end
    percentis_can(i) = elev_sorted_can(idx);
end

figure
plot(percentis_can, percentuais_completos, 'LineWidth', 2)
grid on
title('Cananeia 2020 - Percentis', 'fontsize', 12)
xlabel('Nivel do Mar (m)', 'fontsize', 12)
ylabel('Percentual de Ocorrencia Abaixo do Nivel (%)', 'fontsize', 12)
print -dpng cananeia_2020_percentis
fprintf('\n')

%% ITEM 4: Funcoes densidade de probabilidade
fprintf('========================================\n')
fprintf('ITEM 4: FUNCOES DENSIDADE DE PROBABILIDADE - CANANEIA\n')
fprintf('========================================\n')

% Distribuicao Normal
mu_can = mean(elev_can);
sigma_can = std(elev_can);
x_range_can = linspace(mu_can - 4*sigma_can, mu_can + 4*sigma_can, 1000);
fdp_normal_can = exp(-0.5*((x_range_can - mu_can)/sigma_can).^2) / (sigma_can * sqrt(2*pi));

% Distribuicao de Valor Extremo (Gumbel) - implementacao manual
% Para distribuicao Gumbel: f(x) = (1/beta) * exp(-(x-alpha)/beta) * exp(-exp(-(x-alpha)/beta))
% Onde alpha e beta sao estimados pelos momentos
euler_gamma = 0.5772156649;  % constante de Euler
beta_can = sigma_can * sqrt(6) / pi;
alpha_can = mu_can - euler_gamma * beta_can;
fdp_gumbel_can = (1/beta_can) .* exp(-(x_range_can - alpha_can)/beta_can) .* exp(-exp(-(x_range_can - alpha_can)/beta_can));

% Plot das distribuicoes
figure
subplot(2,1,1)
plot(x_range_can, fdp_normal_can, 'b-', 'LineWidth', 2)
hold on
plot([mu_can, mu_can], [0, max(fdp_normal_can)], 'r--', 'LineWidth', 2)
grid on
title('Cananeia 2020 - Distribuicao Normal', 'fontsize', 12)
xlabel('Nivel do Mar (m)', 'fontsize', 12)
ylabel('Densidade de Probabilidade', 'fontsize', 12)

subplot(2,1,2)
plot(x_range_can, fdp_gumbel_can, 'g-', 'LineWidth', 2)
hold on
plot([alpha_can, alpha_can], [0, max(fdp_gumbel_can)], 'r--', 'LineWidth', 2)
grid on
title('Cananeia 2020 - Distribuicao de Valor Extremo (Gumbel)', 'fontsize', 12)
xlabel('Nivel do Mar (m)', 'fontsize', 12)
ylabel('Densidade de Probabilidade', 'fontsize', 12)
print -dpng cananeia_2020_distribuicoes

% Tres probabilidades de interesse para cada distribuicao
fprintf('DISTRIBUICAO NORMAL:\n');
fprintf('Parametros: mu = %.4f m, sigma = %.4f m\n', mu_can, sigma_can);

% Probabilidades normais (usando aproximacao numerica)
intervals_normal = [mu_can-sigma_can, mu_can+sigma_can; 
                   estat_can(5), mu_can; 
                   mu_can, estat_can(6)];
                   
prob_names = {'P(μ-σ ≤ X ≤ μ+σ)', 'P(X ≤ μ)', 'P(X ≥ μ)'};

for i = 1:3
    x1 = intervals_normal(i,1);
    x2 = intervals_normal(i,2);
    prob_empirica = sum(elev_can >= x1 & elev_can <= x2) / length(elev_can);
    fprintf('%s = %.4f (%.2f%%)\n', prob_names{i}, prob_empirica, prob_empirica*100);
end

fprintf('\nDISTRIBUICAO DE VALOR EXTREMO (GUMBEL):\n');
fprintf('Parametros: alpha = %.4f m, beta = %.4f m\n', alpha_can, beta_can);

% Probabilidades Gumbel (empiricas para comparacao)  
for i = 1:3
    x1 = intervals_normal(i,1);
    x2 = intervals_normal(i,2); 
    prob_empirica = sum(elev_can >= x1 & elev_can <= x2) / length(elev_can);
    fprintf('%s = %.4f (%.2f%%) - empirica\n', prob_names{i}, prob_empirica, prob_empirica*100);
end
fprintf('\n')

%% ITEM 5: Analise de Fourier da serie temporal
fprintf('========================================\n')
fprintf('ITEM 5: ANALISE DE FOURIER - CANANEIA\n')
fprintf('========================================\n')

% Preparacao para FFT
n2_can = floor(nudad_can/2);
n_can = 1:n2_can;
dt_can = 1/24;  % intervalo em dias (dados horarios)
freq_can = n_can / (nudad_can * dt_can);  % frequencia em ciclos/dia
periodo_dias_can = 1 ./ freq_can;  % periodo em dias
freq_angular_can = 2 * pi * freq_can;  % frequencia angular em rad/dia

% FFT dos dados (com media removida)
fft_elev_can = fft(elev_can);
fft_elev2_can = fft_elev_can(2:n2_can+1);
amplitude_can = abs(fft_elev2_can) / (nudad_can/2);

% Encontrando as 5 maiores amplitudes
[amp_sorted_can, idx_sorted_can] = sort(amplitude_can, 'descend');
top5_amplitudes_can = amp_sorted_can(1:5);
top5_freq_can = freq_can(idx_sorted_can(1:5));
top5_freq_angular_can = freq_angular_can(idx_sorted_can(1:5));
top5_periodos_can = periodo_dias_can(idx_sorted_can(1:5));

fprintf('AS 5 MAIORES AMPLITUDES:\n');
fprintf('Ordem  Amplitude (m)  Freq.Angular (rad/dia)  Periodo (dias)  Freq (ciclos/dia)\n');
for i = 1:5
    fprintf('%2d     %10.6f     %15.6f     %10.4f     %12.6f\n', ...
        i, top5_amplitudes_can(i), top5_freq_angular_can(i), top5_periodos_can(i), top5_freq_can(i));
end

% Plot do espectro de frequencias
figure
subplot(2,1,1)
plot(periodo_dias_can, amplitude_can, 'b-', 'LineWidth', 1)
grid on
title('Cananeia 2020 - Espectro de Amplitudes vs Periodo', 'fontsize', 12)
xlabel('Periodo (dias)', 'fontsize', 12)
ylabel('Amplitude (m)', 'fontsize', 12)
axis([0 30 0 max(amplitude_can)])

subplot(2,1,2)
semilogx(periodo_dias_can, amplitude_can, 'b-', 'LineWidth', 1)
grid on
title('Cananeia 2020 - Espectro de Amplitudes vs Periodo (escala log)', 'fontsize', 12)
xlabel('Periodo (dias)', 'fontsize', 12)
ylabel('Amplitude (m)', 'fontsize', 12)
print -dpng cananeia_2020_fourier

fprintf('\nSignificado dos resultados:\n');
fprintf('- Os picos principais indicam as componentes harmonicas dominantes\n');
fprintf('- Periodos proximos a 0.5 dias (12h) e 1.0 dia (24h) indicam mares semi-diurnas e diurnas\n');
fprintf('- Outros picos podem indicar mares de longo periodo ou efeitos meteorologicos\n\n');

%% ITEM 6: Medias mensais e variabilidade
fprintf('========================================\n')
fprintf('ITEM 6: MEDIAS MENSAIS - CANANEIA\n')
fprintf('========================================\n')

% Calculando medias mensais
meses_can = unique(mes_can);
n_meses_can = length(meses_can);
media_mensal_can = zeros(n_meses_can, 1);
std_mensal_can = zeros(n_meses_can, 1);
nome_meses = {'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', ...
              'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'};

fprintf('MEDIAS MENSAIS:\n');
fprintf('Mes    Media (m)    Desvio Padrao (m)\n');

for i = 1:n_meses_can
    mes_atual = meses_can(i);
    dados_mes = elev_can(mes_can == mes_atual);
    media_mensal_can(i) = mean(dados_mes);
    std_mensal_can(i) = std(dados_mes);
    fprintf('%s    %8.4f      %12.4f\n', nome_meses{mes_atual}, media_mensal_can(i), std_mensal_can(i));
end

% Encontrando extremos
[max_media_can, idx_max_media_can] = max(media_mensal_can);
[min_media_can, idx_min_media_can] = min(media_mensal_can);
[max_std_can, idx_max_std_can] = max(std_mensal_can);

fprintf('\nMaior media mensal: %s (%.4f m)\n', nome_meses{meses_can(idx_max_media_can)}, max_media_can);
fprintf('Menor media mensal: %s (%.4f m)\n', nome_meses{meses_can(idx_min_media_can)}, min_media_can);
fprintf('Maior variabilidade: %s (%.4f m)\n\n', nome_meses{meses_can(idx_max_std_can)}, max_std_can);

% Plot das medias mensais
figure
errorbar(meses_can, media_mensal_can, std_mensal_can, 'bo-', 'LineWidth', 2, 'MarkerSize', 6)
grid on
title('Cananeia 2020 - Medias Mensais com Desvio Padrao', 'fontsize', 12)
xlabel('Mes', 'fontsize', 12)
ylabel('Nivel do Mar (m)', 'fontsize', 12)
set(gca, 'XTick', 1:12, 'XTickLabel', nome_meses)
print -dpng cananeia_2020_medias_mensais

%% =======================================================================
%% PARTE 2: ANALISE DOS DADOS DE UBATUBA 2020 (ITENS 7-12)
%% =======================================================================

fprintf('========================================\n')
fprintf('PROCESSANDO DADOS DE UBATUBA 2020...\n')
fprintf('========================================\n\n')

% Leitura dos dados de Ubatuba
load Ubatuba_2020.dat
ubatuba_data = Ubatuba_2020;
nudad_uba = size(ubatuba_data,1);

% Extraindo dados
ano_uba = ubatuba_data(:,1);
mes_uba = ubatuba_data(:,2);
dia_uba = ubatuba_data(:,3);
hora_uba = ubatuba_data(:,4);
minuto_uba = ubatuba_data(:,5);
segundo_uba = ubatuba_data(:,6);
elev_uba_orig = ubatuba_data(:,7);

% IMPORTANTE: subtraindo valor medio
elev_uba_media = mean(elev_uba_orig);
elev_uba = elev_uba_orig - elev_uba_media;

% Vetor temporal
dias_uba = (hora_uba + minuto_uba/60 + segundo_uba/3600)/24;
for i = 1:nudad_uba
    if i == 1
        dias_uba(i) = 0;
    else
        if dia_uba(i) ~= dia_uba(i-1)
            dias_uba(i) = dias_uba(i-1) + 1 + (hora_uba(i) + minuto_uba(i)/60 + segundo_uba(i)/3600)/24;
        else
            dias_uba(i) = floor(dias_uba(i-1)) + (hora_uba(i) + minuto_uba(i)/60 + segundo_uba(i)/3600)/24;
        end
    end
end

fprintf('Dados carregados: %d pontos de Ubatuba 2020\n', nudad_uba)
fprintf('Media original removida: %.4f m\n\n', elev_uba_media)

%% ITEM 7: Parametros estatisticos basicos de Ubatuba
fprintf('========================================\n')
fprintf('ITEM 7: PARAMETROS ESTATISTICOS BASICOS - UBATUBA\n')
fprintf('========================================\n')

% Estatisticas manuais
estat_uba = zeros(8,1);
estat_uba(1) = mean(elev_uba);
estat_uba(2) = median(elev_uba);
estat_uba(4) = std(elev_uba);
estat_uba(5) = min(elev_uba);
estat_uba(6) = max(elev_uba);

% Moda manual
[valores_unicos_uba, ~, indices_uba] = unique(elev_uba);
contadores_uba = accumarray(indices_uba, 1);
[~, idx_max_uba] = max(contadores_uba);
estat_uba(3) = valores_unicos_uba(idx_max_uba);

% Curtose e assimetria manuais
n_dados_uba = length(elev_uba);
media_elev_uba = mean(elev_uba);
std_elev_uba = std(elev_uba);
estat_uba(7) = (1/n_dados_uba) * sum(((elev_uba - media_elev_uba) / std_elev_uba).^4) - 3;
estat_uba(8) = (1/n_dados_uba) * sum(((elev_uba - media_elev_uba) / std_elev_uba).^3);

% Exibindo resultados
fprintf('Media:        %8.4f m\n', estat_uba(1));
fprintf('Mediana:      %8.4f m\n', estat_uba(2));
fprintf('Moda:         %8.4f m\n', estat_uba(3));
fprintf('Desvio Padrao:%8.4f m\n', estat_uba(4));
fprintf('Minimo:       %8.4f m\n', estat_uba(5));
fprintf('Maximo:       %8.4f m\n', estat_uba(6));
fprintf('Curtose:      %8.4f\n', estat_uba(7));
fprintf('Assimetria:   %8.4f\n', estat_uba(8));
fprintf('Amplitude:    %8.4f m\n\n', estat_uba(6) - estat_uba(5));

%% ITEM 8: Serie temporal e tendencia - Ubatuba
fprintf('========================================\n')
fprintf('ITEM 8: SERIE TEMPORAL E TENDENCIA - UBATUBA\n')
fprintf('========================================\n')

% Plot da serie temporal com bandas
figure
plot(dias_uba, elev_uba, 'LineWidth', 1)
hold on

elmed_uba(1:nudad_uba) = mean(elev_uba);
el1dp_uba(1:nudad_uba) = mean(elev_uba) + estat_uba(4);
el1dn_uba(1:nudad_uba) = mean(elev_uba) - estat_uba(4);
el2dp_uba(1:nudad_uba) = mean(elev_uba) + 2*estat_uba(4);
el2dn_uba(1:nudad_uba) = mean(elev_uba) - 2*estat_uba(4);
el3dp_uba(1:nudad_uba) = mean(elev_uba) + 3*estat_uba(4);
el3dn_uba(1:nudad_uba) = mean(elev_uba) - 3*estat_uba(4);

plot(dias_uba, elmed_uba, 'r-', 'LineWidth', 2)
plot(dias_uba, el1dp_uba, 'g--', 'LineWidth', 1)
plot(dias_uba, el1dn_uba, 'g--', 'LineWidth', 1)
plot(dias_uba, el2dp_uba, 'm--', 'LineWidth', 1)
plot(dias_uba, el2dn_uba, 'm--', 'LineWidth', 1)
plot(dias_uba, el3dp_uba, 'c--', 'LineWidth', 1)
plot(dias_uba, el3dn_uba, 'c--', 'LineWidth', 1)

grid on
title('Ubatuba 2020 - Nivel do Mar (bandas de confianca)', 'fontsize', 12)
xlabel('Dias', 'fontsize', 12)
ylabel('Nivel do Mar (m)', 'fontsize', 12)
legend('Dados', 'Media', '±1σ', '±1σ', '±2σ', '±2σ', '±3σ', '±3σ', 'Location', 'best')
print -dpng ubatuba_2020_serie_bandas

% Analise de tendencia
polinom_uba = polyfit(dias_uba, elev_uba, 1);
tend_uba = polinom_uba(1);
elev_tend_uba = polyval(polinom_uba, dias_uba);

figure
plot(dias_uba, elev_uba, 'b-', 'LineWidth', 1)
hold on
plot(dias_uba, elev_tend_uba, 'r-', 'LineWidth', 2)
grid on
title('Ubatuba 2020 - Tendencia Linear', 'fontsize', 12)
xlabel('Dias', 'fontsize', 12)
ylabel('Nivel do Mar (m)', 'fontsize', 12)
legend('Dados Originais', sprintf('Tendencia = %.6f m/dia', tend_uba), 'Location', 'best')
print -dpng ubatuba_2020_tendencia

fprintf('Taxa de variacao (tendencia): %.6f m/dia\n', tend_uba)
fprintf('Taxa de variacao anual: %.4f m/ano\n\n', tend_uba * 365.25)

%% ITEM 9: Histograma e percentis - Ubatuba  
fprintf('========================================\n')
fprintf('ITEM 9: HISTOGRAMA E PERCENTIS - UBATUBA\n')
fprintf('========================================\n')

% Histograma
figure
[counts_uba, centers_uba] = hist(elev_uba, 30);
hist(elev_uba, 30)
grid on
title('Ubatuba 2020 - Histograma do Nivel do Mar', 'fontsize', 12)
xlabel('Nivel do Mar (m)', 'fontsize', 12)
ylabel('Numero de Ocorrencias', 'fontsize', 12)
print -dpng ubatuba_2020_histograma

[max_obs_uba, idx_max_uba] = max(counts_uba);
fprintf('Maximo numero de observacoes: %d (classe %.4f m)\n', max_obs_uba, centers_uba(idx_max_uba));

% Percentis
elev_sorted_uba = sort(elev_uba);
n_total_uba = length(elev_sorted_uba);

fprintf('Percentis:\n');
for i = 1:length(percentuais)
    idx = round((percentuais(i)/100) * (n_total_uba-1)) + 1;
    if idx > n_total_uba
        idx = n_total_uba;
    end
    perc_val = elev_sorted_uba(idx);
    fprintf('%2dº percentil: %8.4f m\n', percentuais(i), perc_val);
end

% Plot dos percentis
percentis_uba = zeros(size(percentuais_completos));
for i = 1:length(percentuais_completos)
    idx = round((percentuais_completos(i)/100) * (n_total_uba-1)) + 1;
    if idx > n_total_uba
        idx = n_total_uba;
    end
    percentis_uba(i) = elev_sorted_uba(idx);
end

figure
plot(percentis_uba, percentuais_completos, 'LineWidth', 2)
grid on
title('Ubatuba 2020 - Percentis', 'fontsize', 12)
xlabel('Nivel do Mar (m)', 'fontsize', 12)
ylabel('Percentual de Ocorrencia Abaixo do Nivel (%)', 'fontsize', 12)
print -dpng ubatuba_2020_percentis
fprintf('\n')

%% ITEM 10: Funcoes densidade de probabilidade - Ubatuba
fprintf('========================================\n')
fprintf('ITEM 10: FUNCOES DENSIDADE DE PROBABILIDADE - UBATUBA\n')
fprintf('========================================\n')

mu_uba = mean(elev_uba);
sigma_uba = std(elev_uba);
x_range_uba = linspace(mu_uba - 4*sigma_uba, mu_uba + 4*sigma_uba, 1000);
fdp_normal_uba = exp(-0.5*((x_range_uba - mu_uba)/sigma_uba).^2) / (sigma_uba * sqrt(2*pi));

% Distribuicao Gumbel
beta_uba = sigma_uba * sqrt(6) / pi;
alpha_uba = mu_uba - euler_gamma * beta_uba;
fdp_gumbel_uba = (1/beta_uba) .* exp(-(x_range_uba - alpha_uba)/beta_uba) .* exp(-exp(-(x_range_uba - alpha_uba)/beta_uba));

figure
subplot(2,1,1)
plot(x_range_uba, fdp_normal_uba, 'b-', 'LineWidth', 2)
hold on
plot([mu_uba, mu_uba], [0, max(fdp_normal_uba)], 'r--', 'LineWidth', 2)
grid on
title('Ubatuba 2020 - Distribuicao Normal', 'fontsize', 12)
xlabel('Nivel do Mar (m)', 'fontsize', 12)
ylabel('Densidade de Probabilidade', 'fontsize', 12)

subplot(2,1,2)
plot(x_range_uba, fdp_gumbel_uba, 'g-', 'LineWidth', 2)
hold on
plot([alpha_uba, alpha_uba], [0, max(fdp_gumbel_uba)], 'r--', 'LineWidth', 2)
grid on
title('Ubatuba 2020 - Distribuicao de Valor Extremo (Gumbel)', 'fontsize', 12)
xlabel('Nivel do Mar (m)', 'fontsize', 12)
ylabel('Densidade de Probabilidade', 'fontsize', 12)
print -dpng ubatuba_2020_distribuicoes

fprintf('DISTRIBUICAO NORMAL:\n');
fprintf('Parametros: mu = %.4f m, sigma = %.4f m\n', mu_uba, sigma_uba);

intervals_normal_uba = [mu_uba-sigma_uba, mu_uba+sigma_uba;
                       estat_uba(5), mu_uba;
                       mu_uba, estat_uba(6)];

for i = 1:3
    x1 = intervals_normal_uba(i,1);
    x2 = intervals_normal_uba(i,2);
    prob_empirica = sum(elev_uba >= x1 & elev_uba <= x2) / length(elev_uba);
    fprintf('%s = %.4f (%.2f%%)\n', prob_names{i}, prob_empirica, prob_empirica*100);
end

fprintf('\nDISTRIBUICAO DE VALOR EXTREMO (GUMBEL):\n');
fprintf('Parametros: alpha = %.4f m, beta = %.4f m\n', alpha_uba, beta_uba);

for i = 1:3
    x1 = intervals_normal_uba(i,1);
    x2 = intervals_normal_uba(i,2);
    prob_empirica = sum(elev_uba >= x1 & elev_uba <= x2) / length(elev_uba);
    fprintf('%s = %.4f (%.2f%%) - empirica\n', prob_names{i}, prob_empirica, prob_empirica*100);
end
fprintf('\n')

%% ITEM 11: Analise de Fourier - Ubatuba
fprintf('========================================\n')
fprintf('ITEM 11: ANALISE DE FOURIER - UBATUBA\n')
fprintf('========================================\n')

n2_uba = floor(nudad_uba/2);
n_uba = 1:n2_uba;
freq_uba = n_uba / (nudad_uba * dt_can);
periodo_dias_uba = 1 ./ freq_uba;
freq_angular_uba = 2 * pi * freq_uba;

fft_elev_uba = fft(elev_uba);
fft_elev2_uba = fft_elev_uba(2:n2_uba+1);
amplitude_uba = abs(fft_elev2_uba) / (nudad_uba/2);

[amp_sorted_uba, idx_sorted_uba] = sort(amplitude_uba, 'descend');
top5_amplitudes_uba = amp_sorted_uba(1:5);
top5_freq_uba = freq_uba(idx_sorted_uba(1:5));
top5_freq_angular_uba = freq_angular_uba(idx_sorted_uba(1:5));
top5_periodos_uba = periodo_dias_uba(idx_sorted_uba(1:5));

fprintf('AS 5 MAIORES AMPLITUDES:\n');
fprintf('Ordem  Amplitude (m)  Freq.Angular (rad/dia)  Periodo (dias)  Freq (ciclos/dia)\n');
for i = 1:5
    fprintf('%2d     %10.6f     %15.6f     %10.4f     %12.6f\n', ...
        i, top5_amplitudes_uba(i), top5_freq_angular_uba(i), top5_periodos_uba(i), top5_freq_uba(i));
end

figure
subplot(2,1,1)
plot(periodo_dias_uba, amplitude_uba, 'b-', 'LineWidth', 1)
grid on
title('Ubatuba 2020 - Espectro de Amplitudes vs Periodo', 'fontsize', 12)
xlabel('Periodo (dias)', 'fontsize', 12)
ylabel('Amplitude (m)', 'fontsize', 12)
axis([0 30 0 max(amplitude_uba)])

subplot(2,1,2)
semilogx(periodo_dias_uba, amplitude_uba, 'b-', 'LineWidth', 1)
grid on
title('Ubatuba 2020 - Espectro de Amplitudes vs Periodo (escala log)', 'fontsize', 12)
xlabel('Periodo (dias)', 'fontsize', 12)
ylabel('Amplitude (m)', 'fontsize', 12)
print -dpng ubatuba_2020_fourier
fprintf('\n')

%% ITEM 12: Medias mensais - Ubatuba
fprintf('========================================\n')
fprintf('ITEM 12: MEDIAS MENSAIS - UBATUBA\n')
fprintf('========================================\n')

meses_uba = unique(mes_uba);
n_meses_uba = length(meses_uba);
media_mensal_uba = zeros(n_meses_uba, 1);
std_mensal_uba = zeros(n_meses_uba, 1);

fprintf('MEDIAS MENSAIS:\n');
fprintf('Mes    Media (m)    Desvio Padrao (m)\n');

for i = 1:n_meses_uba
    mes_atual = meses_uba(i);
    dados_mes = elev_uba(mes_uba == mes_atual);
    media_mensal_uba(i) = mean(dados_mes);
    std_mensal_uba(i) = std(dados_mes);
    fprintf('%s    %8.4f      %12.4f\n', nome_meses{mes_atual}, media_mensal_uba(i), std_mensal_uba(i));
end

[max_media_uba, idx_max_media_uba] = max(media_mensal_uba);
[min_media_uba, idx_min_media_uba] = min(media_mensal_uba);
[max_std_uba, idx_max_std_uba] = max(std_mensal_uba);

fprintf('\nMaior media mensal: %s (%.4f m)\n', nome_meses{meses_uba(idx_max_media_uba)}, max_media_uba);
fprintf('Menor media mensal: %s (%.4f m)\n', nome_meses{meses_uba(idx_min_media_uba)}, min_media_uba);
fprintf('Maior variabilidade: %s (%.4f m)\n\n', nome_meses{meses_uba(idx_max_std_uba)}, max_std_uba);

figure
errorbar(meses_uba, media_mensal_uba, std_mensal_uba, 'ro-', 'LineWidth', 2, 'MarkerSize', 6)
grid on
title('Ubatuba 2020 - Medias Mensais com Desvio Padrao', 'fontsize', 12)
xlabel('Mes', 'fontsize', 12)
ylabel('Nivel do Mar (m)', 'fontsize', 12)
set(gca, 'XTick', 1:12, 'XTickLabel', nome_meses)
print -dpng ubatuba_2020_medias_mensais

%% =======================================================================
%% PARTE 3: COMPARACAO ENTRE CANANEIA E UBATUBA (ITENS 13-15)
%% =======================================================================

%% ITEM 13: Analise das diferenças entre as series
fprintf('========================================\n')
fprintf('ITEM 13: ANALISE DAS DIFERENCAS ENTRE SERIES\n')
fprintf('========================================\n')

% Verificando se os tamanhos sao iguais (assumindo dados sincronos)
if nudad_can ~= nudad_uba
    fprintf('ATENCAO: Series com tamanhos diferentes!\n')
    min_size = min(nudad_can, nudad_uba);
    elev_can_comp = elev_can(1:min_size);
    elev_uba_comp = elev_uba(1:min_size);
    dias_comp = dias_can(1:min_size);
else
    elev_can_comp = elev_can;
    elev_uba_comp = elev_uba;
    dias_comp = dias_can;
end

% Calculando as diferenças (Cananeia - Ubatuba)
diferenca = elev_can_comp - elev_uba_comp;

% Estatisticas das diferenças
estat_diff = zeros(8,1);
estat_diff(1) = mean(diferenca);
estat_diff(2) = median(diferenca);
estat_diff(4) = std(diferenca);
estat_diff(5) = min(diferenca);
estat_diff(6) = max(diferenca);

[valores_unicos_diff, ~, indices_diff] = unique(diferenca);
contadores_diff = accumarray(indices_diff, 1);
[~, idx_max_diff] = max(contadores_diff);
estat_diff(3) = valores_unicos_diff(idx_max_diff);

n_dados_diff = length(diferenca);
media_diff = mean(diferenca);
std_diff = std(diferenca);
estat_diff(7) = (1/n_dados_diff) * sum(((diferenca - media_diff) / std_diff).^4) - 3;
estat_diff(8) = (1/n_dados_diff) * sum(((diferenca - media_diff) / std_diff).^3);

fprintf('ESTATISTICAS DA SERIE DE DIFERENCAS (Cananeia - Ubatuba):\n');
fprintf('Media:        %8.4f m\n', estat_diff(1));
fprintf('Mediana:      %8.4f m\n', estat_diff(2));
fprintf('Moda:         %8.4f m\n', estat_diff(3));
fprintf('Desvio Padrao:%8.4f m\n', estat_diff(4));
fprintf('Minimo:       %8.4f m\n', estat_diff(5));
fprintf('Maximo:       %8.4f m\n', estat_diff(6));
fprintf('Curtose:      %8.4f\n', estat_diff(7));
fprintf('Assimetria:   %8.4f\n', estat_diff(8));
fprintf('Amplitude:    %8.4f m\n\n', estat_diff(6) - estat_diff(5));

% Plot da serie de diferenças
figure
plot(dias_comp, diferenca, 'g-', 'LineWidth', 1)
hold on
plot(dias_comp, zeros(size(dias_comp)), 'k--', 'LineWidth', 1)
grid on
title('Serie de Diferencas entre Cananeia e Ubatuba', 'fontsize', 12)
xlabel('Dias', 'fontsize', 12)
ylabel('Diferenca (m)', 'fontsize', 12)
legend('Cananeia - Ubatuba', 'Linha Zero', 'Location', 'best')
print -dpng comparacao_diferencas

% Comentario
fprintf('COMENTARIO SOBRE SIMILARIDADE:\n');
if abs(estat_diff(1)) < 0.1 && estat_diff(4) < 0.5
    fprintf('As series sao relativamente similares (media das diferencas pequena e baixa variabilidade).\n');
else
    fprintf('As series apresentam diferencas significativas.\n');
end
fprintf('\n');

%% ITEM 14: Diagramas de espalhamento e estatisticas comparativas
fprintf('========================================\n')
fprintf('ITEM 14: DIAGRAMAS DE ESPALHAMENTO E ESTATISTICAS COMPARATIVAS\n')
fprintf('========================================\n')

% Coeficiente de correlacao (R)
R = corrcoef(elev_can_comp, elev_uba_comp);
coef_correlacao = R(1,2);

% R-quadrado
R2 = coef_correlacao^2;

% Erro medio absoluto (MAE)
mae = mean(abs(elev_can_comp - elev_uba_comp));

% Erro medio absoluto relativo (MARE)
mare = mean(abs((elev_can_comp - elev_uba_comp) ./ elev_uba_comp)) * 100;

% Indice de concordancia de Willmott (d)
num = sum((elev_can_comp - elev_uba_comp).^2);
den = sum((abs(elev_can_comp - mean(elev_uba_comp)) + abs(elev_uba_comp - mean(elev_uba_comp))).^2);
indice_concordancia = 1 - (num / den);

% Regressao linear
p_reg = polyfit(elev_uba_comp, elev_can_comp, 1);
elev_reg = polyval(p_reg, elev_uba_comp);

fprintf('PARAMETROS ESTATISTICOS COMPARATIVOS:\n');
fprintf('Coeficiente de correlacao (R):    %8.4f\n', coef_correlacao);
fprintf('R-quadrado (R²):                  %8.4f\n', R2);
fprintf('Erro medio absoluto (MAE):        %8.4f m\n', mae);
fprintf('Erro medio absoluto relativo:     %8.2f%%\n', mare);
fprintf('Indice de concordancia (d):       %8.4f\n', indice_concordancia);
fprintf('Equacao de regressao: y = %.4fx + %.4f\n\n', p_reg(1), p_reg(2));

% Diagrama de espalhamento
figure
subplot(2,2,1)
scatter(elev_uba_comp, elev_can_comp, 10, 'b', 'filled')
hold on
plot(elev_uba_comp, elev_reg, 'r-', 'LineWidth', 2)
plot([min(elev_uba_comp), max(elev_uba_comp)], [min(elev_uba_comp), max(elev_uba_comp)], 'k--', 'LineWidth', 1)
grid on
xlabel('Ubatuba (m)', 'fontsize', 10)
ylabel('Cananeia (m)', 'fontsize', 10)
title('Diagrama de Espalhamento', 'fontsize', 10)
legend('Dados', 'Regressao', '1:1', 'Location', 'best')

% Residuos vs valores preditos
residuos = elev_can_comp - elev_reg;
subplot(2,2,2)
scatter(elev_reg, residuos, 10, 'r', 'filled')
hold on
plot([min(elev_reg), max(elev_reg)], [0, 0], 'k--', 'LineWidth', 1)
grid on
xlabel('Valores Preditos (m)', 'fontsize', 10)
ylabel('Residuos (m)', 'fontsize', 10)
title('Residuos vs Preditos', 'fontsize', 10)

% Serie temporal das duas estacoes
subplot(2,2,3)
plot(dias_comp(1:min(1000, length(dias_comp))), elev_can_comp(1:min(1000, length(elev_can_comp))), 'b-', 'LineWidth', 1)
hold on
plot(dias_comp(1:min(1000, length(dias_comp))), elev_uba_comp(1:min(1000, length(elev_uba_comp))), 'r-', 'LineWidth', 1)
grid on
xlabel('Dias', 'fontsize', 10)
ylabel('Nivel do Mar (m)', 'fontsize', 10)
title('Series Temporais (primeiros 1000 pontos)', 'fontsize', 10)
legend('Cananeia', 'Ubatuba', 'Location', 'best')

% QQ-plot (aproximacao manual)
subplot(2,2,4)
elev_can_sorted = sort(elev_can_comp);
elev_uba_sorted = sort(elev_uba_comp);
n_qq = min(length(elev_can_sorted), length(elev_uba_sorted));
scatter(elev_uba_sorted(1:n_qq), elev_can_sorted(1:n_qq), 10, 'g', 'filled')
hold on
plot([min(elev_uba_sorted), max(elev_uba_sorted)], [min(elev_can_sorted), max(elev_can_sorted)], 'k--', 'LineWidth', 1)
grid on
xlabel('Quantis Ubatuba (m)', 'fontsize', 10)
ylabel('Quantis Cananeia (m)', 'fontsize', 10)
title('Q-Q Plot', 'fontsize', 10)

print -dpng comparacao_espalhamento

% Comentario sobre relacao
fprintf('COMENTARIO SOBRE A RELACAO ENTRE AS SERIES:\n');
if R2 > 0.8
    fprintf('Existe uma forte correlacao linear entre as series (R² > 0.8).\n');
elseif R2 > 0.6
    fprintf('Existe uma correlacao moderada entre as series (0.6 < R² < 0.8).\n');
else
    fprintf('A correlacao entre as series e fraca (R² < 0.6).\n');
end

if indice_concordancia > 0.8
    fprintf('As series apresentam boa concordancia (d > 0.8).\n');
else
    fprintf('As series apresentam concordancia limitada (d < 0.8).\n');
end
fprintf('\n')

%% ITEM 15: Correlacoes cruzadas
fprintf('========================================\n')
fprintf('ITEM 15: CORRELACOES CRUZADAS COM DEFASAGENS\n')
fprintf('========================================\n')

% Funcao de correlacao cruzada manual
max_lag = min(48, floor(length(elev_can_comp)/10));  % maximo 48 horas ou 10% dos dados
lags = -max_lag:max_lag;
n_lags = length(lags);
correlacoes_cruzadas = zeros(n_lags, 1);

% Normalizando as series para correlacao
elev_can_norm = (elev_can_comp - mean(elev_can_comp)) / std(elev_can_comp);
elev_uba_norm = (elev_uba_comp - mean(elev_uba_comp)) / std(elev_uba_comp);

for i = 1:n_lags
    lag_atual = lags(i);
    
    if lag_atual >= 0
        % Ubatuba atrasada em relacao a Cananeia
        if lag_atual == 0
            x1 = elev_can_norm;
            x2 = elev_uba_norm;
        else
            x1 = elev_can_norm(1:end-lag_atual);
            x2 = elev_uba_norm(1+lag_atual:end);
        end
    else
        % Cananeia atrasada em relacao a Ubatuba
        lag_atual_abs = abs(lag_atual);
        x1 = elev_can_norm(1+lag_atual_abs:end);
        x2 = elev_uba_norm(1:end-lag_atual_abs);
    end
    
    % Correlacao
    if length(x1) > 0 && length(x2) > 0
        correlacoes_cruzadas(i) = sum(x1 .* x2) / length(x1);
    else
        correlacoes_cruzadas(i) = 0;
    end
end

% Encontrando maxima correlacao
[max_corr, idx_max_corr] = max(abs(correlacoes_cruzadas));
lag_max_corr = lags(idx_max_corr);
corr_max_value = correlacoes_cruzadas(idx_max_corr);

fprintf('ANALISE DE CORRELACAO CRUZADA:\n');
fprintf('Maxima correlacao: %.4f\n', corr_max_value);
fprintf('Defasagem da maxima correlacao: %d horas\n', lag_max_corr);

% Plot das correlacoes cruzadas
figure
plot(lags, correlacoes_cruzadas, 'b-', 'LineWidth', 2)
hold on
plot(lag_max_corr, corr_max_value, 'ro', 'MarkerSize', 8, 'LineWidth', 2)
plot([0, 0], [min(correlacoes_cruzadas), max(correlacoes_cruzadas)], 'k--', 'LineWidth', 1)
grid on
title('Funcao de Correlacao Cruzada', 'fontsize', 12)
xlabel('Defasagem (horas)', 'fontsize', 12)
ylabel('Correlacao', 'fontsize', 12)
legend('Correlacao Cruzada', sprintf('Max = %.3f (lag = %d h)', corr_max_value, lag_max_corr), 'Lag Zero', 'Location', 'best')
print -dpng correlacao_cruzada

% Significado do resultado
fprintf('\nSIGNIFICADO DO RESULTADO:\n');
if abs(lag_max_corr) <= 2
    fprintf('As series estao praticamente sincronas (defasagem <= 2 horas).\n');
elseif lag_max_corr > 0
    fprintf('Ubatuba esta atrasada %d horas em relacao a Cananeia.\n', lag_max_corr);
else
    fprintf('Cananeia esta atrasada %d horas em relacao a Ubatuba.\n', abs(lag_max_corr));
end

if abs(corr_max_value) > 0.8
    fprintf('Existe uma forte correlacao temporal entre as series.\n');
elseif abs(corr_max_value) > 0.6
    fprintf('Existe uma correlacao moderada entre as series.\n');
else
    fprintf('A correlacao temporal entre as series e fraca.\n');
end

fprintf('\n========================================\n')
fprintf('ANALISE COMPLETA FINALIZADA!\n')
fprintf('========================================\n')
fprintf('\nTodos os graficos foram salvos como arquivos PNG.\n')
fprintf('Consulte os resultados numericos acima para as respostas da lista.\n\n')
