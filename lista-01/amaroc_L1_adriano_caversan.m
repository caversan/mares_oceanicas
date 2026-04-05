% LISTA DE EXERCICIOS 1 - ANALISE DE MARES OCEANICAS IOC 5801
% ADRIANO CAVERSAN - 1º SEMESTRE 2026
% Dados horarios de nivel do mar de 2020 em Cananeia (SP, Brasil)

clear all; close all; clc

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


% Leitura dos dados de Ubatuba
fprintf('\n>>> Leitura dos dados de Ubatuba <<<\n')
load Ubatuba_2020.dat
