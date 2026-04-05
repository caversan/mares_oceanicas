% LISTA DE EXERCICIOS 1 - ANALISE DE MARES OCEANICAS IOC 5801
% ADRIANO CAVERSAN - 1º SEMESTRE 2026
% Dados horarios de nivel do mar de 2020 em Cananeia (SP, Brasil)

clear all; close all; clc

%% ====================================================================
%% QUESTÕES 1-6: CANANÉIA 2020
%% ====================================================================

% Leitura dos dados de Cananeia
fprintf('\n>>> Leitura dos dados de Cananeia <<<\n')
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

% QUESTÃO 1: Estatistica basica da serie de elevacao
estat(1,1) = mean(elev);
estat(2,1) = median(elev);
estat(3,1) = mode(elev);
estat(4,1) = std(elev);
estat(5,1) = min(elev);
estat(6,1) = max(elev);
estat(7,1) = kurtosis(elev);
estat(8,1) = skewness(elev);

fid=fopen('cananeia_2020_estat.dat','w');
fprintf(fid,'%10.4f\n',estat);
fclose(fid);

% Criando variavel temporal
dias = datenum(ano, mes, dia, hora, minuto, segundo);

% QUESTÃO 2: plotagem da serie temporal de elev
figure
plot(dias,elev,'LineWidth',2)
axis([min(dias) max(dias) -inf inf])
grid on
hold on
elmed(1:nudad)=mean(elev);
elinf(1:nudad)=mean(elev)-std(elev);
elsup(1:nudad)=mean(elev)+std(elev);
elinf2(1:nudad)=mean(elev)-2*std(elev);
elsup2(1:nudad)=mean(elev)+2*std(elev);
elinf3(1:nudad)=mean(elev)-3*std(elev);
elsup3(1:nudad)=mean(elev)+3*std(elev);
plot(dias,elmed,'r','LineWidth',2)
plot(dias,elinf,'r','LineWidth',2)
plot(dias,elsup,'r','LineWidth',2)
plot(dias,elinf2,'g','LineWidth',2)
plot(dias,elsup2,'g','LineWidth',2)
plot(dias,elinf3,'k','LineWidth',2)
plot(dias,elsup3,'k','LineWidth',2)

% ajuste linear e tendencia
polinom=polyfit(dias,elev,1);
tend=polinom(1);
elev_pol=polyval(polinom,dias);
plot(dias,elev_pol,'c','LineWidth',2)

title('Cananeia 2020 elev (media + - 1,2,3 dp + tendencia)','fontsize',12)
xlabel('Meses de 2020','fontsize',12)
ylabel('m','fontsize',12)
datetick('x','mmm','keepticks')
fprintf('Taxa de variacao: %.6f m/dia = %.4f m/ano\n', tend, tend*365.25)
print -dpng cananeia_2020_elev_dp

% QUESTÃO 3: histograma dos dados de elev
figure
[n_hist, x_hist] = hist(elev);
hist(elev)
grid on
title('Cananeia 2020 elev (histograma)','fontsize',12)
xlabel('CLASSES (m)','fontsize',12)
ylabel('NUMERO DE OCORRENCIAS','fontsize',12)
max_observacoes = max(n_hist);
fprintf('Maximo numero de observacoes nas classes: %d\n', max_observacoes)
print -dpng cananeia_2020_elev_hist

% QUESTÃO 4: Percentis dos dados de elev
percentuais=[0:1:100];
percentis=prctile(elev,percentuais);
figure
plot(percentis,percentuais,'LineWidth',2)
grid on
title('Cananeia 2020 elev (percentis)','fontsize',12)
xlabel('NIVEL DO MAR (m)','fontsize',12)
ylabel('PERCENT. OCORRENCIA ABAIXO DO NIVEL','fontsize',12)

% Valores numericos dos percentis especificos
p10 = prctile(elev,10);
p25 = prctile(elev,25);
p75 = prctile(elev,75);
p90 = prctile(elev,90);
fprintf('Percentil 10%%: %.4f m\n', p10)
fprintf('Percentil 25%%: %.4f m\n', p25)
fprintf('Percentil 75%%: %.4f m\n', p75)
fprintf('Percentil 90%%: %.4f m\n', p90)
print -dpng cananeia_2020_elev_perc

% ajuste linear dos dados de elev
polinom=polyfit(dias,elev,1);
tend=polinom(1);
elev_pol=polyval(polinom,dias);
figure
plot(dias,elev,'LineWidth',2)
hold
plot(dias,elev_pol,'r','LineWidth',2)
axis([min(dias) max(dias) -inf inf])
grid on
title('Cananeia 2020 elev (tendencia)','fontsize',12)
xlabel('Meses de 2020','fontsize',12)
ylabel('m','fontsize',12)
datetick('x','mmm','keepticks')
print -dpng cananeia_2020_elev_tend

% QUESTÃO 5: Transformada de Fourier da serie temporal de elev
n2=nudad/2;
n=1:n2;
Tn_horas=nudad./n;
Tn_dias=nudad./n/24;
Fn=1./Tn_dias;
altura_media=mean(elev);
elev=elev-altura_media;
fft_elev=fft(elev);
fft_elev2=fft_elev(2:n2+1);
a_fft_elev=abs(fft_elev2)/n2;

figure
plot(Tn_dias,a_fft_elev,'b-','LineWidth',2)
axis([0 2 0 max(a_fft_elev)*1.1])
grid on
title('Cananeia 2020 elev (Transf. Fourier)','fontsize',12)
xlabel('Periodos (em dias)','fontsize',12)
ylabel('Amplitude (em m)','fontsize',12)
print -dpng cananeia_2020_elev_fourier

% 5 maiores amplitudes
[a_sorted, indices] = sort(a_fft_elev, 'descend');
fprintf('5 MAIORES AMPLITUDES:\n')
for i=1:5
    idx = indices(i);
    fprintf('Amplitude: %.6f m - Periodo: %.2f dias - Freq.Angular: %.6f rad/dia\n', ...
            a_sorted(i), Tn_dias(idx), 2*pi*Fn(idx))
end

elev=elev+altura_media;

% QUESTÃO 6: Medias mensais e desvios padrao
nomes_meses = {'Jan','Feb','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'};
medias_mensais = zeros(1,12);
desvios_mensais = zeros(1,12);

% Calculo das medias e desvios mensais
for i=1:12
    dados_mes = elev(mes==i);
    medias_mensais(i) = mean(dados_mes);
    desvios_mensais(i) = std(dados_mes);
end

% Tabela de medias mensais
fprintf('\n===== MEDIAS MENSAIS E DESVIOS PADRAO =====\n')
fprintf('Mes      Media (m)   Desvio Padrao (m)\n')
fprintf('---------------------------------------\n')
for i=1:12
    fprintf('%s      %8.4f    %8.4f\n', nomes_meses{i}, medias_mensais(i), desvios_mensais(i))
end

% Plotagem das medias mensais
figure
errorbar(1:12, medias_mensais, desvios_mensais, 'o-', 'LineWidth', 2, 'MarkerSize', 8)
grid on
title('Cananeia 2020 - Medias Mensais com Desvio Padrao','fontsize',12)
xlabel('Meses','fontsize',12)
ylabel('Nivel do Mar (m)','fontsize',12)
set(gca,'XTick',1:12,'XTickLabel',nomes_meses)
axis([0.5 12.5 min(medias_mensais)-0.4 max(medias_mensais)+0.4])

% Identificacao dos extremos
[max_media, mes_max_media] = max(medias_mensais);
[min_media, mes_min_media] = min(medias_mensais);
[max_desvio, mes_max_desvio] = max(desvios_mensais);

fprintf('\nRESULTADOS:\n')
fprintf('Maior media mensal: %.4f m em %s\n', max_media, nomes_meses{mes_max_media})
fprintf('Menor media mensal: %.4f m em %s\n', min_media, nomes_meses{mes_min_media})
fprintf('Maior variabilidade: %.4f m em %s\n', max_desvio, nomes_meses{mes_max_desvio})
print -dpng cananeia_2020_medias_mensais

%% ====================================================================
%% QUESTÕES 7-12: UBATUBA 2020
%% ====================================================================

% Leitura dos dados de Ubatuba
load Ubatuba_2020.dat
x_ub = Ubatuba_2020;
nudad_ub = size(x_ub,1);

% Extraindo dados: ano, mes, dia, hora, minuto, segundo, nivel do mar (m)
ano_ub = x_ub(:,1);
mes_ub = x_ub(:,2);
dia_ub = x_ub(:,3);
hora_ub = x_ub(:,4);
minuto_ub = x_ub(:,5);
segundo_ub = x_ub(:,6);
elev_ub = x_ub(:,7);

% QUESTÃO 7: Estatistica basica da serie de elevacao
estat_ub(1,1) = mean(elev_ub);
estat_ub(2,1) = median(elev_ub);
estat_ub(3,1) = mode(elev_ub);
estat_ub(4,1) = std(elev_ub);
estat_ub(5,1) = min(elev_ub);
estat_ub(6,1) = max(elev_ub);
estat_ub(7,1) = kurtosis(elev_ub);
estat_ub(8,1) = skewness(elev_ub);

fid=fopen('ubatuba_2020_estat.dat','w');
fprintf(fid,'%10.4f\n',estat_ub);
fclose(fid);

% Criando variavel temporal
dias_ub = datenum(ano_ub, mes_ub, dia_ub, hora_ub, minuto_ub, segundo_ub);

% QUESTÃO 8: plotagem da serie temporal de elev
figure
plot(dias_ub,elev_ub,'LineWidth',2)
axis([min(dias_ub) max(dias_ub) -inf inf])
grid on
hold on
elmed_ub(1:nudad_ub)=mean(elev_ub);
elinf_ub(1:nudad_ub)=mean(elev_ub)-std(elev_ub);
elsup_ub(1:nudad_ub)=mean(elev_ub)+std(elev_ub);
elinf2_ub(1:nudad_ub)=mean(elev_ub)-2*std(elev_ub);
elsup2_ub(1:nudad_ub)=mean(elev_ub)+2*std(elev_ub);
elinf3_ub(1:nudad_ub)=mean(elev_ub)-3*std(elev_ub);
elsup3_ub(1:nudad_ub)=mean(elev_ub)+3*std(elev_ub);
plot(dias_ub,elmed_ub,'r','LineWidth',2)
plot(dias_ub,elinf_ub,'r','LineWidth',2)
plot(dias_ub,elsup_ub,'r','LineWidth',2)
plot(dias_ub,elinf2_ub,'g','LineWidth',2)
plot(dias_ub,elsup2_ub,'g','LineWidth',2)
plot(dias_ub,elinf3_ub,'k','LineWidth',2)
plot(dias_ub,elsup3_ub,'k','LineWidth',2)

% ajuste linear e tendencia
polinom_ub=polyfit(dias_ub,elev_ub,1);
tend_ub=polinom_ub(1);
elev_pol_ub=polyval(polinom_ub,dias_ub);
plot(dias_ub,elev_pol_ub,'c','LineWidth',2)

title('Ubatuba 2020 elev (media + - 1,2,3 dp + tendencia)','fontsize',12)
xlabel('Meses de 2020','fontsize',12)
ylabel('m','fontsize',12)
datetick('x','mmm','keepticks')
fprintf('Taxa de variacao: %.6f m/dia = %.4f m/ano\n', tend_ub, tend_ub*365.25)
print -dpng ubatuba_2020_elev_dp

% QUESTÃO 9: histograma dos dados de elev
figure
[n_hist_ub, x_hist_ub] = hist(elev_ub);
hist(elev_ub)
grid on
title('Ubatuba 2020 elev (histograma)','fontsize',12)
xlabel('CLASSES (m)','fontsize',12)
ylabel('NUMERO DE OCORRENCIAS','fontsize',12)
max_observacoes_ub = max(n_hist_ub);
fprintf('Maximo numero de observacoes nas classes: %d\n', max_observacoes_ub)
print -dpng ubatuba_2020_elev_hist

% QUESTÃO 10: Percentis dos dados de elev  
percentuais_ub=[0:1:100];
percentis_ub=prctile(elev_ub,percentuais_ub);
figure
plot(percentis_ub,percentuais_ub,'LineWidth',2)
grid on
title('Ubatuba 2020 elev (percentis)','fontsize',12)
xlabel('NIVEL DO MAR (m)','fontsize',12)
ylabel('PERCENT. OCORRENCIA ABAIXO DO NIVEL','fontsize',12)

% Valores numericos dos percentis especificos
p10_ub = prctile(elev_ub,10);
p25_ub = prctile(elev_ub,25);
p75_ub = prctile(elev_ub,75);
p90_ub = prctile(elev_ub,90);
fprintf('Percentil 10%%: %.4f m\n', p10_ub)
fprintf('Percentil 25%%: %.4f m\n', p25_ub)
fprintf('Percentil 75%%: %.4f m\n', p75_ub)
fprintf('Percentil 90%%: %.4f m\n', p90_ub)
print -dpng ubatuba_2020_elev_perc

% ajuste linear dos dados de elev
polinom_ub=polyfit(dias_ub,elev_ub,1);
tend_ub=polinom_ub(1);
elev_pol_ub=polyval(polinom_ub,dias_ub);
figure
plot(dias_ub,elev_ub,'LineWidth',2)
hold
plot(dias_ub,elev_pol_ub,'r','LineWidth',2)
axis([min(dias_ub) max(dias_ub) -inf inf])
grid on
title('Ubatuba 2020 elev (tendencia)','fontsize',12)
xlabel('Meses de 2020','fontsize',12)
ylabel('m','fontsize',12)
datetick('x','mmm','keepticks')
print -dpng ubatuba_2020_elev_tend

% QUESTÃO 11: Transformada de Fourier da serie temporal de elev
n2_ub=nudad_ub/2;
n_ub=1:n2_ub;
Tn_horas_ub=nudad_ub./n_ub;
Tn_dias_ub=nudad_ub./n_ub/24;
Fn_ub=1./Tn_dias_ub;
altura_media_ub=mean(elev_ub);
elev_ub=elev_ub-altura_media_ub;
fft_elev_ub=fft(elev_ub);
fft_elev2_ub=fft_elev_ub(2:n2_ub+1);
a_fft_elev_ub=abs(fft_elev2_ub)/n2_ub;

figure
plot(Tn_dias_ub,a_fft_elev_ub,'b-','LineWidth',2)
axis([0 2 0 max(a_fft_elev_ub)*1.1])
grid on
title('Ubatuba 2020 elev (Transf. Fourier)','fontsize',12)
xlabel('Periodos (em dias)','fontsize',12)
ylabel('Amplitude (em m)','fontsize',12)
print -dpng ubatuba_2020_elev_fourier

% 5 maiores amplitudes
[a_sorted_ub, indices_ub] = sort(a_fft_elev_ub, 'descend');
fprintf('5 MAIORES AMPLITUDES:\n')
for i=1:5
    idx_ub = indices_ub(i);
    fprintf('Amplitude: %.6f m - Periodo: %.2f dias - Freq.Angular: %.6f rad/dia\n', ...
            a_sorted_ub(i), Tn_dias_ub(idx_ub), 2*pi*Fn_ub(idx_ub))
end

elev_ub=elev_ub+altura_media_ub;

% QUESTÃO 12: Medias mensais e desvios padrao
medias_mensais_ub = zeros(1,12);
desvios_mensais_ub = zeros(1,12);

% Calculo das medias e desvios mensais
for i=1:12
    dados_mes_ub = elev_ub(mes_ub==i);
    medias_mensais_ub(i) = mean(dados_mes_ub);
    desvios_mensais_ub(i) = std(dados_mes_ub);
end

% Tabela de medias mensais
fprintf('\n===== MEDIAS MENSAIS E DESVIOS PADRAO - UBATUBA =====\n')
fprintf('Mes      Media (m)   Desvio Padrao (m)\n')
fprintf('---------------------------------------\n')
for i=1:12
    fprintf('%s      %8.4f    %8.4f\n', nomes_meses{i}, medias_mensais_ub(i), desvios_mensais_ub(i))
end

% Plotagem das medias mensais
figure
errorbar(1:12, medias_mensais_ub, desvios_mensais_ub, 'o-', 'LineWidth', 2, 'MarkerSize', 8)
grid on
title('Ubatuba 2020 - Medias Mensais com Desvio Padrao','fontsize',12)
xlabel('Meses','fontsize',12)
ylabel('Nivel do Mar (m)','fontsize',12)
set(gca,'XTick',1:12,'XTickLabel',nomes_meses)
axis([0.5 12.5 min(medias_mensais_ub)-0.4 max(medias_mensais_ub)+0.4])

% Identificacao dos extremos
[max_media_ub, mes_max_media_ub] = max(medias_mensais_ub);
[min_media_ub, mes_min_media_ub] = min(medias_mensais_ub);
[max_desvio_ub, mes_max_desvio_ub] = max(desvios_mensais_ub);

fprintf('\nRESULTADOS - UBATUBA:\n')
fprintf('Maior media mensal: %.4f m em %s\n', max_media_ub, nomes_meses{mes_max_media_ub})
fprintf('Menor media mensal: %.4f m em %s\n', min_media_ub, nomes_meses{mes_min_media_ub})
fprintf('Maior variabilidade: %.4f m em %s\n', max_desvio_ub, nomes_meses{mes_max_desvio_ub})
print -dpng ubatuba_2020_medias_mensais

%% ====================================================================
%% QUESTÕES 13-15: ANÁLISE COMPARATIVA ENTRE CANANÉIA E UBATUBA
%% ====================================================================

% QUESTÃO 13: Graficos comparativos mensais de todas as estatisticas

% Calcular estatisticas mensais adicionais para Cananeia
medianas_mensais = zeros(1,12);
modas_mensais = zeros(1,12);
minimos_mensais = zeros(1,12);
maximos_mensais = zeros(1,12);
curtoses_mensais = zeros(1,12);
assimetrias_mensais = zeros(1,12);

% Calcular estatisticas mensais adicionais para Ubatuba
medianas_mensais_ub = zeros(1,12);
modas_mensais_ub = zeros(1,12);
minimos_mensais_ub = zeros(1,12);
maximos_mensais_ub = zeros(1,12);
curtoses_mensais_ub = zeros(1,12);
assimetrias_mensais_ub = zeros(1,12);

% Loop pelos meses para calcular todas as estatisticas
for i = 1:12
    % Dados de Cananeia
    dados_mes = elev(mes == i);
    medianas_mensais(i) = median(dados_mes);
    modas_mensais(i) = mode(dados_mes);
    minimos_mensais(i) = min(dados_mes);
    maximos_mensais(i) = max(dados_mes);
    curtoses_mensais(i) = kurtosis(dados_mes);
    assimetrias_mensais(i) = skewness(dados_mes);
    
    % Dados de Ubatuba
    dados_mes_ub = elev_ub(mes_ub == i);
    medianas_mensais_ub(i) = median(dados_mes_ub);
    modas_mensais_ub(i) = mode(dados_mes_ub);
    minimos_mensais_ub(i) = min(dados_mes_ub);
    maximos_mensais_ub(i) = max(dados_mes_ub);
    curtoses_mensais_ub(i) = kurtosis(dados_mes_ub);
    assimetrias_mensais_ub(i) = skewness(dados_mes_ub);
end

% Grafico 1: MEDIAS mensais
figure
x = 1:12;
plot(x, medias_mensais, 'o-', x, medias_mensais_ub, 's-', 'LineWidth', 2, 'MarkerSize', 8)
grid on
legend('Cananeia', 'Ubatuba', 'Location', 'best')
title('Q13-1: Medias Mensais - Cananeia vs Ubatuba','fontsize',12)
xlabel('Meses','fontsize',12)
ylabel('Media (m)','fontsize',12)
set(gca,'XTick',1:12,'XTickLabel',{'Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'})
print -dpng q13_1_medias_mensais

% Grafico 2: DESVIOS PADRAO mensais
figure
plot(x, desvios_mensais, 'o-', x, desvios_mensais_ub, 's-', 'LineWidth', 2, 'MarkerSize', 8)
grid on
legend('Cananeia', 'Ubatuba', 'Location', 'best')
title('Q13-2: Desvios Padrao Mensais - Cananeia vs Ubatuba','fontsize',12)
xlabel('Meses','fontsize',12)
ylabel('Desvio Padrao (m)','fontsize',12)
set(gca,'XTick',1:12,'XTickLabel',{'Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'})
print -dpng q13_2_desvios_mensais

% Grafico 3: MEDIANAS mensais
figure
plot(x, medianas_mensais, 'o-', x, medianas_mensais_ub, 's-', 'LineWidth', 2, 'MarkerSize', 8)
grid on
legend('Cananeia', 'Ubatuba', 'Location', 'best')
title('Q13-3: Medianas Mensais - Cananeia vs Ubatuba','fontsize',12)
xlabel('Meses','fontsize',12)
ylabel('Mediana (m)','fontsize',12)
set(gca,'XTick',1:12,'XTickLabel',{'Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'})
print -dpng q13_3_medianas_mensais

% Grafico 4: MODAS mensais
figure
plot(x, modas_mensais, 'o-', x, modas_mensais_ub, 's-', 'LineWidth', 2, 'MarkerSize', 8)
grid on
legend('Cananeia', 'Ubatuba', 'Location', 'best')
title('Q13-4: Modas Mensais - Cananeia vs Ubatuba','fontsize',12)
xlabel('Meses','fontsize',12)
ylabel('Moda (m)','fontsize',12)
set(gca,'XTick',1:12,'XTickLabel',{'Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'})
print -dpng q13_4_modas_mensais

% Grafico 5: MINIMOS mensais
figure
plot(x, minimos_mensais, 'o-', x, minimos_mensais_ub, 's-', 'LineWidth', 2, 'MarkerSize', 8)
grid on
legend('Cananeia', 'Ubatuba', 'Location', 'best')
title('Q13-5: Minimos Mensais - Cananeia vs Ubatuba','fontsize',12)
xlabel('Meses','fontsize',12)
ylabel('Minimo (m)','fontsize',12)
set(gca,'XTick',1:12,'XTickLabel',{'Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'})
print -dpng q13_5_minimos_mensais

% Grafico 6: MAXIMOS mensais
figure
plot(x, maximos_mensais, 'o-', x, maximos_mensais_ub, 's-', 'LineWidth', 2, 'MarkerSize', 8)
grid on
legend('Cananeia', 'Ubatuba', 'Location', 'best')
title('Q13-6: Maximos Mensais - Cananeia vs Ubatuba','fontsize',12)
xlabel('Meses','fontsize',12)
ylabel('Maximo (m)','fontsize',12)
set(gca,'XTick',1:12,'XTickLabel',{'Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'})
print -dpng q13_6_maximos_mensais

% Grafico 7: CURTOSES mensais
figure
plot(x, curtoses_mensais, 'o-', x, curtoses_mensais_ub, 's-', 'LineWidth', 2, 'MarkerSize', 8)
grid on
legend('Cananeia', 'Ubatuba', 'Location', 'best')
title('Q13-7: Curtoses Mensais - Cananeia vs Ubatuba','fontsize',12)
xlabel('Meses','fontsize',12)
ylabel('Curtose','fontsize',12)
set(gca,'XTick',1:12,'XTickLabel',{'Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'})
print -dpng q13_7_curtoses_mensais

% Grafico 8: ASSIMETRIAS mensais
figure
plot(x, assimetrias_mensais, 'o-', x, assimetrias_mensais_ub, 's-', 'LineWidth', 2, 'MarkerSize', 8)
grid on
legend('Cananeia', 'Ubatuba', 'Location', 'best')
title('Q13-8: Assimetrias Mensais - Cananeia vs Ubatuba','fontsize',12)
xlabel('Meses','fontsize',12)
ylabel('Assimetria','fontsize',12)
set(gca,'XTick',1:12,'XTickLabel',{'Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'})
print -dpng q13_8_assimetrias_mensais


% QUESTÃO 14: Diagramas de espalhamento e parametros estatisticos comparativos

% Diagrama de espalhamento
figure
% Usando dados mensais para melhor visualizacao (12 pontos)
scatter(medias_mensais, medias_mensais_ub, 100, 'filled', 'MarkerFaceColor', [0.2 0.6 0.8])
hold on

% Linha de regressao
P = polyfit(medias_mensais, medias_mensais_ub, 1);
x_fit = [min(medias_mensais) max(medias_mensais)];
y_fit = polyval(P, x_fit);
plot(x_fit, y_fit, 'r-', 'LineWidth', 3)

% Linha 1:1 (correlacao perfeita)
plot(x_fit, x_fit, 'b--', 'LineWidth', 2)
grid on

% Calculos dos parametros estatisticos com dados mensais
r_mensal = corrcoef(medias_mensais, medias_mensais_ub);
coef_correlacao = r_mensal(1,2);
R2 = coef_correlacao^2;
MAE = mean(abs(medias_mensais_ub - medias_mensais));
MARE = (MAE / mean(medias_mensais)) * 100;

% Indice de concordancia (Willmott) para dados mensais
numerador = sum((medias_mensais_ub - medias_mensais).^2);
denominador = sum((abs(medias_mensais_ub - mean(medias_mensais)) + abs(medias_mensais - mean(medias_mensais))).^2);
indice_concordancia = 1 - (numerador / denominador);

% Adicionando parametros estatisticos no grafico
xlabel('Cananeia - Medias Mensais (m)', 'fontsize', 12)
ylabel('Ubatuba - Medias Mensais (m)', 'fontsize', 12)
title('Q14: Correlacao Mensal - Cananeia vs Ubatuba', 'fontsize', 14)
legend('Medias Mensais', 'Regressao Linear', 'Linha 1:1', 'Location', 'northwest')

% Texto com parametros estatisticos no grafico
x_pos = min(medias_mensais) + 0.1*(max(medias_mensais) - min(medias_mensais));
y_pos = max(medias_mensais_ub) - 0.05*(max(medias_mensais_ub) - min(medias_mensais_ub));
text(x_pos, y_pos, sprintf('R² = %.4f', R2), 'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', 'white')
text(x_pos, y_pos-0.08, sprintf('r = %.4f', coef_correlacao), 'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', 'white')
text(x_pos, y_pos-0.16, sprintf('MAE = %.4f m', MAE), 'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', 'white')
text(x_pos, y_pos-0.24, sprintf('MARE = %.2f%%', MARE), 'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', 'white')
text(x_pos, y_pos-0.32, sprintf('d = %.4f', indice_concordancia), 'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', 'white')

print -dpng q14_correlacao_mensal


% Grafico adicional: Parametros estatisticos em barras
figure
parametros = [R2, abs(coef_correlacao), MAE*10, MARE/10, indice_concordancia];
nomes_param = {'R²', '|r|', 'MAE×10', 'MARE÷10', 'd'};
bar(parametros, 'FaceColor', [0.3 0.7 0.4])
grid on
title('Q14: Parametros Estatisticos Comparativos', 'fontsize', 14)
xlabel('Parametros', 'fontsize', 12)
ylabel('Valores Normalizados', 'fontsize', 12)
set(gca, 'XTickLabel', nomes_param)

% Valores reais sobre as barras
for i = 1:length(parametros)
    if i == 3
        text(i, parametros(i)+0.02, sprintf('%.4f', MAE), 'HorizontalAlignment', 'center', 'FontWeight', 'bold')
    elseif i == 4
        text(i, parametros(i)+0.02, sprintf('%.1f%%', MARE), 'HorizontalAlignment', 'center', 'FontWeight', 'bold')
    else
        text(i, parametros(i)+0.02, sprintf('%.4f', parametros(i)), 'HorizontalAlignment', 'center', 'FontWeight', 'bold')
    end
end

print -dpng q14_parametros_estatisticos


% QUESTÃO 15: Correlacoes cruzadas com defasagens

% Limitando a defasagem maxima para melhor visualizacao (±48 horas = ±2 dias)
max_lag = 48;

% Calculando correlacao cruzada
[correlacao_cruzada, defasagens] = xcorr(elev, elev_ub, max_lag, 'coeff');

% Encontrando a maxima correlacao e sua defasagem
[max_correlacao, idx_max] = max(abs(correlacao_cruzada));
defasagem_max = defasagens(idx_max);
correlacao_maxima = correlacao_cruzada(idx_max);

% Plotando o grafico de correlacao cruzada
figure
plot(defasagens, correlacao_cruzada, 'b-', 'LineWidth', 2)
hold on
% Destacando o ponto de maxima correlacao
plot(defasagem_max, correlacao_maxima, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r')
grid on
xlabel('Defasagem (horas)', 'fontsize', 12)
ylabel('Coeficiente de Correlacao', 'fontsize', 12)
title('Q15: Correlacao Cruzada - Cananeia vs Ubatuba', 'fontsize', 14)

% Adicionando linha de referencia zero
plot([min(defasagens) max(defasagens)], [0 0], 'k--', 'LineWidth', 1)

% Texto com informacoes da maxima correlacao
y_pos = max(correlacao_cruzada) - 0.1*(max(correlacao_cruzada) - min(correlacao_cruzada));
text(0.6*max(defasagens), y_pos, sprintf('Máxima Correlação: %.4f', correlacao_maxima), ...
     'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', 'yellow')
text(0.6*max(defasagens), y_pos-0.08, sprintf('Defasagem: %d horas', defasagem_max), ...
     'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', 'yellow')

% Interpretacao da defasagem
if defasagem_max > 0
    interpretacao = 'Ubatuba atrasa em relacao a Cananeia';
elseif defasagem_max < 0
    interpretacao = 'Cananeia atrasa em relacao a Ubatuba';
else
    interpretacao = 'Series em fase (sem defasagem)';
end
text(0.6*max(defasagens), y_pos-0.16, interpretacao, ...
     'FontSize', 10, 'FontWeight', 'bold', 'BackgroundColor', 'cyan')

print -dpng q15_correlacao_cruzada


fprintf('\n===== QUESTAO 15 CONCLUIDA =====\n')
fprintf('Maxima correlacao: %.4f\n', correlacao_maxima)
fprintf('Defasagem: %d horas\n', defasagem_max)
fprintf('Interpretacao: %s\n', interpretacao)




