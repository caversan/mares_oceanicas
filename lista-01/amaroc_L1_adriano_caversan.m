% LISTA DE EXERCICIOS 1 - ANALISE DE MARES OCEANICAS IOC 5801
% ADRIANO CAVERSAN - 1º SEMESTRE 2026
% Dados horarios de nivel do mar de 2020 em Cananeia (SP, Brasil)

clear all; close all; clc

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

% Estatistica basica da serie de elevacao
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

% plotagem da serie temporal de elev
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
pause

% histograma dos dados de elev
figure
hist(elev)
grid on
title('pto p05 201604 cmems elev (histograma)','fontsize',12)
xlabel('CLASSES (m)','fontsize',12)
ylabel('NUMERO DE OCORRENCIAS','fontsize',12)
print -dpng pto_p05_201604_cmems_elev_hist

% Percentis dos dados de elev
percentuais=[0:1:100];
percentis=prctile(elev,percentuais);
figure
plot(percentis,percentuais,'LineWidth',2)
grid on
title('pto p05 201604 cmems elev (percentis)','fontsize',12)
xlabel('NIVEL DO MAR (m)','fontsize',12)
ylabel('PERCENT. OCORRENCIA ABAIXO DO NIVEL','fontsize',12)
print -dpng pto_p05_201604_cmems_elev_perc

% ajuste linear dos dados de elev
polinom=polyfit(dias,elev,1);
% Ajuste linear dos dados de elev
p = polyfit(dias, elev, 1);        % coeficientes [slope intercept]
tend = p(1);                       % inclinação (unidade por dia)
elev_pol = polyval(p, dias);

figure
plot(dias, elev, 'LineWidth', 2)
hold on
plot(dias, elev_pol, 'r', 'LineWidth', 2)
hold off
xlim([min(dias) max(dias)])
ylim([min(elev) max(elev)])        % ou ajustar manualmente se preferir
grid on
title(sprintf('pto p05 201604 cmems elev (tendência = %.4g/unid/dia)', tend), 'FontSize', 12)
xlabel('Dias', 'FontSize', 12)
ylabel('m', 'FontSize', 12)
legend('Dados', 'Ajuste linear', 'Location', 'best')

% Salvar figura como PNG
print('-dpng', 'pto_p05_201604_cmems_elev_tend.png')
tend=polinom(1);
elev_pol=polyval(polinom,dias);
figure
plot(dias,elev,'LineWidth',2)
hold
plot(dias,elev_pol,'r','LineWidth',2)
axis([1 inf -inf inf])
grid on
title('pto p05 201604 cmems elev (tendencia)','fontsize',12)
xlabel('Dias','fontsize',12)
ylabel('m','fontsize',12)
print -dpng pto_p05_201604_cmems_elev_tend

% Transformada de Fourier da serie temporal de elev
n2=nudad/2;
n=1:n2;
Tn_horas=nudad./n;
Tn_dias=nudad./n/24;
% Fn=1./Tn;
altura_media=mean(elev);
elev=elev-altura_media;
fft_elev=fft(elev);
fft_elev2=fft_elev(2:n2+1);
a_fft_elev=abs(fft_elev2)/n2;
figure
bar(Tn_dias,a_fft_elev,'LineWidth',2)
grid on
title('pto p05 201604 cmems elev (Transf. Fourier)','fontsize',12)
xlabel('Periodos (em dias)','fontsize',12)
ylabel('Amplitude (em m)','fontsize',12)
print -dpng pto_p05_201604_cmems_elev_fourier

elev=elev+altura_media;

