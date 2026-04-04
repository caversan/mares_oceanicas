% LISTA DE EXERCICIOS 1 - ANALISE DE MARES OCEANICAS IOC 5801
% ADRIANO CAVERSAN - 1º SEMESTRE 2026
% Dados horarios de nivel do mar de 2020 em Cananeia (SP, Brasil)
% Analise estatistica mensal

clear all; close all; clc

fprintf('========================================\n')
fprintf('LISTA 1 - ANALISE DE MARES OCEANICAS\n')  
fprintf('ADRIANO CAVERSAN - 2026\n')
fprintf('========================================\n\n')

% Leitura dos dados de Cananeia
load Cananeia_2020.dat
x = Cananeia_2020;
nudad = size(x,1);

% Extraindo dados: ano, mes, dia, hora, minuto, segundo, nivel do mar (m)
ano = x(:,1);
mes = x(:,2);
dia = x(:,3);
hora = x(:,4);
minuto = x(:,5);
segundo = x(:,6);
elev = x(:,7);

% Criando vetor temporal em dias
dias = (hora + minuto/60 + segundo/3600)/24;
for i = 1:nudad
    if i == 1
        dias(i) = 0;
    else
        if dia(i) ~= dia(i-1)
            dias(i) = dias(i-1) + 1 + (hora(i) + minuto(i)/60 + segundo(i)/3600)/24;
        else
            dias(i) = floor(dias(i-1)) + (hora(i) + minuto(i)/60 + segundo(i)/3600)/24;
        end
    end
end

fprintf('Dados carregados: %d pontos de Cananeia 2020\n\n', nudad)

% Estatisticas basicas mensais das series temporais
fprintf('========================================\n')
fprintf('PARAMETROS ESTATISTICOS BASICOS MENSAIS - CANANEIA\n')
fprintf('========================================\n')

meses_unicos = unique(mes);
n_meses = length(meses_unicos);
nome_meses = {'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', ...
              'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'};

% Matriz para armazenar estatisticas mensais (8 parametros x n_meses)
estat_mensal = zeros(8, n_meses);

fprintf('Mes    Media    Mediana   Moda     DesvPad   Minimo   Maximo   Curtose  Assimetria\n');
fprintf('---------------------------------------------------------------------------------\n');

for i = 1:n_meses
    mes_atual = meses_unicos(i);
    idx_mes = (mes == mes_atual);
    elev_mes = elev(idx_mes);
    
    % Calculando estatisticas do mes
    estat_mensal(1,i) = mean(elev_mes);      % Media
    estat_mensal(2,i) = median(elev_mes);    % Mediana
    
    % Moda manual (valor mais frequente)
    [valores_unicos, ~, indices] = unique(elev_mes);
    contadores = accumarray(indices, 1);
    [~, idx_max] = max(contadores);
    estat_mensal(3,i) = valores_unicos(idx_max);  % Moda
    
    estat_mensal(4,i) = std(elev_mes);       % Desvio padrao
    estat_mensal(5,i) = min(elev_mes);       % Minimo
    estat_mensal(6,i) = max(elev_mes);       % Maximo
    
    % Curtose manual
    n_dados = length(elev_mes);
    media_elev = mean(elev_mes);
    std_elev = std(elev_mes);
    if std_elev > 0
        estat_mensal(7,i) = (1/n_dados) * sum(((elev_mes - media_elev) / std_elev).^4) - 3;  % Curtose
        estat_mensal(8,i) = (1/n_dados) * sum(((elev_mes - media_elev) / std_elev).^3);      % Assimetria
    else
        estat_mensal(7,i) = 0;  % Curtose
        estat_mensal(8,i) = 0;  % Assimetria
    end
    
    fprintf('%s   %7.3f   %7.3f   %7.3f   %7.3f   %7.3f   %7.3f   %7.3f    %7.3f\n', ...
            nome_meses{mes_atual}, estat_mensal(1,i), estat_mensal(2,i), estat_mensal(3,i), ...
            estat_mensal(4,i), estat_mensal(5,i), estat_mensal(6,i), ...
            estat_mensal(7,i), estat_mensal(8,i));
end

% Salvando estatisticas em arquivo
fid = fopen('cananeia_2020_estat_mensal.dat','w');
fprintf(fid,'%10.4f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f \n', estat_mensal);
fclose(fid);

fprintf('\nEstatisticas mensais salvas em: cananeia_2020_estat_mensal.dat\n\n');

% Plotagem das estatisticas mensais agrupadas por tipo
fprintf('========================================\n')
fprintf('GRAFICOS ESTATISTICOS MENSAIS AGRUPADOS\n')
fprintf('========================================\n')

% Grafico 1: Media, Mediana e Desvio Padrao mensais
figure
bar(meses_unicos, [estat_mensal(1,:)' estat_mensal(2,:)' estat_mensal(4,:)'], 'grouped')
title('Cananeia 2020 - Media, Mediana e Desvio Padrao Mensais', 'fontsize', 12)
xlabel('Mes', 'fontsize', 12)
ylabel('Nivel do Mar (m)', 'fontsize', 12)
legend('Media', 'Mediana', 'Desvio Padrao', 'Location', 'best')
set(gca, 'XTickLabel', nome_meses(meses_unicos))
grid on
print('-dpng', 'cananeia_2020_media_mediana_desvio_mensais')
fprintf('Grafico salvo: cananeia_2020_media_mediana_desvio_mensais.png\n')

% Grafico 2: Minimo e Maximo mensais  
figure
bar(meses_unicos, [estat_mensal(5,:)' estat_mensal(6,:)'], 'grouped')
title('Cananeia 2020 - Valores Minimos e Maximos Mensais', 'fontsize', 12)
xlabel('Mes', 'fontsize', 12)
ylabel('Nivel do Mar (m)', 'fontsize', 12)
legend('Minimo', 'Maximo', 'Location', 'best')
set(gca, 'XTickLabel', nome_meses(meses_unicos))
grid on
print('-dpng', 'cananeia_2020_minimo_maximo_mensais')
fprintf('Grafico salvo: cananeia_2020_minimo_maximo_mensais.png\n')

% Grafico 3: Curtose e Assimetria mensais
figure
bar(meses_unicos, [estat_mensal(7,:)' estat_mensal(8,:)'], 'grouped')
title('Cananeia 2020 - Curtose e Assimetria Mensais', 'fontsize', 12)
xlabel('Mes', 'fontsize', 12)
ylabel('Valor', 'fontsize', 12)
legend('Curtose', 'Assimetria', 'Location', 'best')
set(gca, 'XTickLabel', nome_meses(meses_unicos))
grid on
hold on
% Linhas de referencia para distribuicao normal
plot([0.5 n_meses+0.5], [0 0], 'r--', 'LineWidth', 1)
print('-dpng', 'cananeia_2020_curtose_assimetria_mensais')
fprintf('Grafico salvo: cananeia_2020_curtose_assimetria_mensais.png\n')

% Grafico 4: Amplitude mensal (Max - Min)
amplitude_mensal = estat_mensal(6,:) - estat_mensal(5,:);
figure
bar(meses_unicos, amplitude_mensal, 'FaceColor', [0.2 0.6 0.8])
title('Cananeia 2020 - Amplitude Mensal (Max - Min)', 'fontsize', 12)
xlabel('Mes', 'fontsize', 12)
ylabel('Amplitude (m)', 'fontsize', 12)
set(gca, 'XTickLabel', nome_meses(meses_unicos))
grid on
% Adicionando valores sobre as barras
for i = 1:length(meses_unicos)
    text(i, amplitude_mensal(i) + 0.01*max(amplitude_mensal), ...
         sprintf('%.3f', amplitude_mensal(i)), 'HorizontalAlignment', 'center', 'FontSize', 10)
end
print('-dpng', 'cananeia_2020_amplitude_mensais')
fprintf('Grafico salvo: cananeia_2020_amplitude_mensais.png\n')

fprintf('\n');

% Analise comparativa de distribuicoes mensais
fprintf('========================================\n')
fprintf('ANALISE DE DISTRIBUICOES MENSAIS\n')
fprintf('========================================\n')

% Grafico 5: Percentis especificos por mes (10%, 25%, 75%, 90%)
percentis_especificos = [10 25 75 90];
valores_percentis = zeros(length(percentis_especificos), n_meses);

for i = 1:n_meses
    mes_atual = meses_unicos(i);
    idx_mes = (mes == mes_atual);
    elev_mes = elev(idx_mes);
    
    % Calculando percentis especificos manualmente
    elev_sorted = sort(elev_mes);
    n_total = length(elev_sorted);
    
    for j = 1:length(percentis_especificos)
        idx = round((percentis_especificos(j)/100) * (n_total-1)) + 1;
        if idx > n_total
            idx = n_total;
        end
        valores_percentis(j,i) = elev_sorted(idx);
    end
end

figure
bar(meses_unicos, valores_percentis', 'grouped')
title('Cananeia 2020 - Percentis Mensais (10%, 25%, 75%, 90%)', 'fontsize', 12)
xlabel('Mes', 'fontsize', 12)
ylabel('Nivel do Mar (m)', 'fontsize', 12)
legend('10%', '25%', '75%', '90%', 'Location', 'best')
set(gca, 'XTickLabel', nome_meses(meses_unicos))
grid on
print('-dpng', 'cananeia_2020_percentis_mensais')
fprintf('Grafico salvo: cananeia_2020_percentis_mensais.png\n')

fprintf('\n');

% Analise de tendencia mensal agrupada
fprintf('========================================\n')
fprintf('ANALISE DE TENDENCIA MENSAL\n')
fprintf('========================================\n')

tendencias_mensais = zeros(n_meses, 1);

for i = 1:n_meses
    mes_atual = meses_unicos(i);
    idx_mes = (mes == mes_atual);
    dias_mes = dias(idx_mes);
    elev_mes = elev(idx_mes);
    
    polinom_mes = polyfit(dias_mes, elev_mes, 1);
    tendencias_mensais(i) = polinom_mes(1);
    
    fprintf('Mes %s: Tendencia = %.6f m/dia\n', nome_meses{mes_atual}, tendencias_mensais(i));
end

% Grafico 6: Tendencias mensais
figure
bar(meses_unicos, tendencias_mensais, 'FaceColor', [0.8 0.2 0.2])
title('Cananeia 2020 - Tendencias Mensais', 'fontsize', 12)
xlabel('Mes', 'fontsize', 12)
ylabel('Tendencia (m/dia)', 'fontsize', 12)
set(gca, 'XTickLabel', nome_meses(meses_unicos))
grid on
% Linha de referencia zero
hold on
plot([0.5 n_meses+0.5], [0 0], 'k--', 'LineWidth', 1)
% Adicionando valores sobre as barras
for i = 1:length(meses_unicos)
    text(i, tendencias_mensais(i) + 0.1*max(abs(tendencias_mensais)) * sign(tendencias_mensais(i)), ...
         sprintf('%.3e', tendencias_mensais(i)), 'HorizontalAlignment', 'center', 'FontSize', 9)
end
print('-dpng', 'cananeia_2020_tendencias_mensais')
fprintf('Grafico salvo: cananeia_2020_tendencias_mensais.png\n')

fprintf('\n');

% Analise de Fourier comparativa mensal
fprintf('========================================\n')
fprintf('ANALISE DE FOURIER - AMPLITUDES DOMINANTES MENSAIS\n')
fprintf('========================================\n')

% Encontrando as 3 maiores amplitudes de cada mes para periodos de mare (0.5-2 dias)
periodos_mare = [0.5 1.0 2.0];  % periodos de interesse em dias
amplitudes_mare = zeros(3, n_meses);  % 3 periodos x n_meses

for i = 1:n_meses
    mes_atual = meses_unicos(i);
    idx_mes = (mes == mes_atual);
    elev_mes = elev(idx_mes);
    nudad_mes = length(elev_mes);
    
    if nudad_mes > 48  % Garantindo dados suficientes para FFT
        n2_mes = floor(nudad_mes/2);
        n_mes = 1:n2_mes;
        Tn_dias_mes = nudad_mes./n_mes/24;
        
        % Removendo media antes da FFT
        altura_media_mes = mean(elev_mes);
        elev_mes_fft = elev_mes - altura_media_mes;
        
        fft_elev_mes = fft(elev_mes_fft);
        fft_elev2_mes = fft_elev_mes(2:n2_mes+1);
        a_fft_elev_mes = abs(fft_elev2_mes)/n2_mes;
        
        % Encontrando amplitudes para periodos de mare especificos
        for j = 1:length(periodos_mare)
            [~, idx_periodo] = min(abs(Tn_dias_mes - periodos_mare(j)));
            if idx_periodo <= length(a_fft_elev_mes)
                amplitudes_mare(j,i) = a_fft_elev_mes(idx_periodo);
            end
        end
        
        fprintf('Mes %s: FFT calculada (%d pontos)\n', nome_meses{mes_atual}, nudad_mes);
    else
        fprintf('Mes %s: Dados insuficientes para FFT (%d pontos)\n', nome_meses{mes_atual}, nudad_mes);
        amplitudes_mare(:,i) = 0;
    end
end

% Grafico 7: Amplitudes dos periodos de mare por mes
figure
bar(meses_unicos, amplitudes_mare', 'grouped')
title('Cananeia 2020 - Amplitudes de Periodos de Mare por Mes', 'fontsize', 12)
xlabel('Mes', 'fontsize', 12)
ylabel('Amplitude (m)', 'fontsize', 12)
legend('0.5 dias (12h)', '1.0 dia (24h)', '2.0 dias', 'Location', 'best')
set(gca, 'XTickLabel', nome_meses(meses_unicos))
grid on
print('-dpng', 'cananeia_2020_amplitudes_mare_mensais')
fprintf('Grafico salvo: cananeia_2020_amplitudes_mare_mensais.png\n')

fprintf('\n========================================\n')
fprintf('ANALISE COMPLETA FINALIZADA!\n')
fprintf('Foram gerados 7 graficos agrupados:\n')
fprintf('1. Media, Mediana e Desvio Padrao Mensais\n')
fprintf('2. Valores Minimos e Maximos Mensais\n')
fprintf('3. Curtose e Assimetria Mensais\n')
fprintf('4. Amplitude Mensal\n')
fprintf('5. Percentis Mensais\n')
fprintf('6. Tendencias Mensais\n')
fprintf('7. Amplitudes de Mare Mensais\n')
fprintf('========================================\n\n')

