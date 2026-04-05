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

