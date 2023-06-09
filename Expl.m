  clear;
%Дано:
d=0.7;%Диаметр лампы, см
l=8; %Межэлектр расстояние, см
P_0=5.32e4; % начальное давление ксенона, Па
P_0m=400; % начальное давление ксенона, мм рт. ст.
P=[624e3:1e3:1e7];%Мощность, Вт
S= pi*d^2/4;% площадь поперечного сечения лампы, см^2
 lambda=[190:10:1100]; %длин волны, нм
%  lambda=[190,230,270,300,350,430,555,700,850,1000,1100];
k=8.63*10^(-5); % постоянная Больцмана,  Эв/град
U_0=850; %Рабочее напряжение, В
L=9*10^(-6); %Индуктивность контура, Г
mu_0=4*pi*1e-7;%маг пост
mu_cu=1;
mu_pl=1;
M_0=2.2*1e-25;% масса атома ксенона в кг
%R_0=0.025; %паразитное сопротивление,Ом
W_0=3*800; %электрическая энергия импульса, Дж 
h=4.136*10^(-15);
% Конструктивный параметр лампы
K_0=1.27*(l/d)*(P_0m/450)^0.2; 
C=5575*1e-6;
U_0=sqrt(2*W_0/(C));
U_0=850;
% %Расчет электрических параметров

 l_pr=2;% длина проводов, м
 S_pr=4; %мм^2
 r=sqrt((S_pr*1e-6)/pi); %Радиус центральной жилы провода
 L_pr=(mu_0*l_pr)/(2*pi)*(log((2*l_pr)/(r*1e-3))-1+mu_cu/4);%индуктивность проводов вне трансформатора, Г
 L_lamp=(mu_0*l*1e-2)/(2*pi)*(log((4*l*1e-2)/(d*1e-2))-1+mu_pl/4);%индуктивность лампы
% 
% %провода сердечника
% %размеры сердечкника
 D_1=125*1e-3;R_1=64.4*1e-3;
 D_2=80*1e-3;R_2=32.2*1e-3;
 H=26.8*1e-3;
 N=50;
 l_k=pi*0.5*(D_1+D_2);
 S_k=H*(R_1-R_2);
 L_it=mu_0*1*(N^2)/(l_k)*S_k;
% 
 l_prtr=N*2*(H+R_1-R_2);%полная длина провода вторичной обмотки трансформатора,м
 L_sum=L_pr+L_lamp+L_it;
 Z_0=sqrt(L_sum/C); %Волновое сопротивление контура,Om
% 
%
 L_dop=15.8*1e-6;
% 
% %расчет соленоида
 l_iz=0.5*1e-3;%толщина изоляции провода
 r_k=50*1e-3;%радиус трубки сердечника
% 
 N_k1=(L_dop*2*(r+l_iz))/(mu_0*pi*(r_k+r*+l_iz)^2);
 N_k=round(N_k1);
 l_prk=N_k*2*pi*(r_k+r*1e-3+l_iz); %длина провода в катушке
%
%%
R_0=39.24*1e-3;
L_sumopt=30*1e-6;
K_0=1.27*(l/d)*(P_0m/450)^0.2; 

sim('RLC.slx');
t=ans.simout.time;
I=ans.simout.data;
U=ans.simout1.data;
I_max=max(ans.simout.data);
R_lamp=K_0/sqrt(I_max); %сопротивление лампы
R_sum=(R_lamp*3)+R_0;  %4.Суммарное сопротивление контура с лампой
P_el=I_max^2*R_sum; %Максимальная электрическая мощность, развиваемая контуром
P_lamp=I_max^2*R_lamp; %Макс мощность развиваемая в лампе
eta_pl=3*R_lamp/R_sum; %эффективность передачи запасаемой энергии в плазму(КПД)

j_max=I_max/S; %Максимальная плотность тока в лампе

k_i=find(ans.simout.data==I_max); %индекс значения максимума тока
t_max=t(k_i); %Максимум тока достигается в данный момент времени

%1. Волновое сопротивление контура
Z_0=sqrt(L_sumopt/C); %Om



%6. Параметр затухания контура
gamma=R_sum/(2*Z_0);
if gamma<1
   disp('Докритическое затухание')
   omega_0=1/sqrt(L*C);
   omega=omega_0*sqrt(1-gamma^2);
   t_m=(pi/2-atan((R_sum)/(2*L*omega)))/omega;
   I_m=(U_0)/(omega*L)*exp(-(R_sum)/(2*L)*t_m);
elseif gamma==1
    disp('Критическое затухание')
    I_m=2/exp(1)*(U_0)/(R_sum);
    t_m=2*L/R_sum;
else
    disp('Затухание больше критического')
    alpha_1=(R_sum)/(2*L)*(1-sqrt(1-gamma^(-2)));
    alpha_2=(R_sum)/(2*L)*(1+sqrt(1-gamma^(-2)));
    t_m=1/(alpha_2-alpha_1)*log(alpha_2/alpha_1);
    I_m=(U_0)/(R_sum*sqrt(1-gamma^(-2)))*(exp(-alpha_1*t_m)-exp(-alpha_2*t_m));
end



%11. Характерное время энерговклада в лампу
W_0=(C*U_0^2)/2; %запас в конденс энергия, Дж
% t_05=(eta_pl*W_0)/(P_lamp);
t_05=0.006;
%12. Определение времени заполненя лампы плазмой по эмп форм Андреева
t_zap=3*10^3*d*sqrt(P_0m)*(U_0/l)^(-1.5);%время заполнения, мкс
v=(d*10^-2)/(t_zap*10^(-6));%время заполнения, м/с


%13. Температура плазмы в установившемся режиме
T_pl=3.5e3*(S/P_0)^(1/16)*j_max^(1/4);
%14. Расчет термодинам параметров при условии лок равновесия
n_sum=3.3*10^(16)*P_0m;%суммарное число тяж частиц

%%%%расчет степени ионизации
er=100;
koef=4.9*1e15*4*(T_pl^(3/2))/n_sum;
I_0=12.16;%потенциал ионизации,эВ
kT=T_pl/11600;
deltaI_0=0;%в первом приближении
while er>1
    A=koef*exp(-(I_0-deltaI_0)/(kT));
    alpha_ioniz=-A/2+sqrt((A^2)/(4)+A);
    n_e=alpha_ioniz*n_sum;
    delta=deltaI_0;
    deltaI_0=2.1*1e-8*(n_e/T_pl)^(1/2);
    er=((deltaI_0-delta)/deltaI_0)*100;
end

%15. Расчет внутренней энергии плазмы.
epsilon=1.1*3/2*kT*(1+alpha_ioniz)+(I_0-deltaI_0)*alpha_ioniz; %эВ/час. с учетом электронов

E_vnyd=epsilon*(1.6*1e-19)/(M_0); %удельная внутр энергия, Дж/кг
m_pl=n_sum*S*l*M_0; %масса плазмы  в межэлектродном промежутке
E_vn=E_vnyd*m_pl;

%16. Эффективный показатель адиабаты ксен плазмы.
gamma_adiab=1+(1+alpha_ioniz)*(kT)/epsilon;

%17. Скорость звука в плазме.
c_zv=sqrt(gamma_adiab*(gamma_adiab-1)*E_vnyd);
t_gd=d/c_zv; %время выравнивания параметров

%18. Давление в лампе.

p=4.55*1e-7*P_0m*T_pl*(1-alpha_ioniz);

%19. Расчет проводимости плазмы лампы
%%

Lambda=1.24*10^4*(T_pl^(3/2))/sqrt(n_e);%кулоновский логарифм

Z_ef=1+53*(n_e^(1/3))/(T_pl)^2; %эффективный заряд ионов

sigma_sp=1.54*10^-4*T_pl^(3/2)/(Z_ef*log(Lambda));% Спитцеровская проводимость плазмы, (om*sm)^-1


%21. Спектральный поток трубчатой ксеноновой лампы-Норман
gamma_=1.66*10^(-3)*n_e^(1/3)/T_pl;

Gamma_=[0.12,0.125,0.13,0.135,0.140,0.15,0.16,0.17,0.18,0.2,0.25];
E_optim=[0,0.5,1.0,1.25,1.4,1.65,1.8,1.94,2.0,2.12,2.17];

index=0;
i=1;
while index==0
    
    if gamma_>Gamma_(1,i)
         i=i+1;
    else
        index=i;
    end
    
end
if i>1
E_opt=E_optim(1,index-1)+((gamma_-Gamma_(1,index-1))*(E_optim(1,index)-E_optim(1,index-1)))/(Gamma_(1,index)-Gamma_(1,index-1)); %Эв
else
    E_opt=0;
end

hdv=10^(-5)*n_e^(0.267);%энергетический сдвиг порога фотоиониз, эВ
%er-снижение потенциала ионизации;

%%
hv=(h*3*10^8)./(lambda.*10^-9);
for i = 1:size(lambda,2)%коэффициент поглощения
    if hv(1,i)<(2.6-hdv);
    f_g=(exp((hv(1,i)+hdv)/(kT))-exp(E_opt/(kT))+1.2)/(exp((hv(1,i)+hdv)/kT)-1+1.2);
    k_v=2*10^(-37)*(n_e^2)/(sqrt(kT)*(hv(1,i))^2)*(exp((hv(1,i)+hdv-deltaI_0)/(kT))+1.2)*f_g*(1-exp(-hv(1,i)/kT));
    elseif 2.6-hdv<hv(1,i)<6,2;
     f_g=(exp(2.6/(kT))-exp(E_opt/(kT))+1.2)/(exp((2.6)/(kT))-1+1.2);
     k_v=2*10^(-37)*(n_e^2)/(sqrt(kT)*(hv(1,i))^2)*(exp((2.6-deltaI_0)/(kT))+1.2)*f_g*(1-exp(-hv(1,i)/kT));
    else
    k_v=0.2*(6.2)^3/(hv(1,i))^3*(1-exp(-hv(1,i)/kT))/(1-exp(-6.2/kT));
    end
    f_g(1,i)=f_g;
k_V(1,i)=k_v;    
t_L=k_V.*d;


        if t_L(1,i)>=0.5;
         alpha_2(1,i)=0.9;
        else
         alpha_2(1,i)=1;
         end
    
if lambda(1,i)<=190;%коэф пропускания колбы на длинне
    K_Lst(1,i)=0;
elseif lambda(1,i)<=230;
    K_Lst(1,i)=0.65;
    elseif lambda(1,i)<270;
    K_Lst(1,i)=0.7;
    elseif lambda(1,i)==270;
    K_Lst(1,i)=0.9;
else
    K_Lst(1,i)=0.92;
end

    P_L(1,i)=0.9*K_Lst(1,i)*(11.9)/(lambda(1,i)/1000)^5*(pi^2*d*l)/(exp((1.44*10^7)/(T_pl*lambda(1,i)))-1)*(1-exp(-alpha_2(1,i)*t_L(1,i))); %Вт/нм
%     P_L=P_l(1,i);
end
%%
% 
t_037=0.0083;
I_L=(P_L)./(pi^2);%спектральная сила излучения
B_L=I_L./(d*l);
T_lambda1=1.44*1e4./((lambda./1000).*log((11.9./(B_L.*(lambda/1000).^5))+1));%яркостная температура.
P_s=W_0/(pi*d*l*t_05);% пов мощ эл энергии лампы, Вт/см^2 
delta_labd=463;
II=delta_labd*max(I_L);
P_izl=pi^2*II;
E_izl=P_izl*t_037*3;
KPD_izl=E_izl/W_0

%25. Сила света лампы 
d_labda05=100; %полуширина спектр диапазона
I_cv=683*I_L(1,3)*d_labda05;%сила света, кд

P_LL=I.*U;
plot(lambda,k_V)
plot(lambda,P_L)

%%
I_Lmax=max(I_L);
k_Vtransp=k_V.';

lambda_transp=lambda.';
P_L_transp=P_L.';
I_Ltransp=I_L.';
T_lambdatransp=T_lambda1.';


%%%

%%
W_pred=13.5*10^3*d*l*sqrt(t_037);
B=W_0/W_pred;
N_max=B^(-8.5);
f_1=(15*pi*0.9*l)/W_0;
f_2=(30*pi*0.9*l)/W_0;
f_3=(200*pi*0.9*l)/W_0;
6*(5.37*10^(-5)*570*P_s^(0.25)-0.372)*P_s*sqrt(t_037);