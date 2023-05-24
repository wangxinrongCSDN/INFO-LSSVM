%%  ��ջ�������
clear
clc
warning off

%%  ��������
load res.mat

%%  �������ѵ�����Ͳ��Լ�
temp = randperm(200);
% ѵ��������150������
P_train = res(temp(1:150),1:12)';
T_train = res(temp(1:150),13)';
M = size(P_train,2);
% ���Լ�����50������
P_test = res(temp(151:end),1:12)';
T_test = res(temp(151:end),13)';
N = size(P_test,2);
%% ���ݹ�һ��
[p_train, ps_input] = mapminmax(P_train,0,1);
p_test = mapminmax('apply',P_test,ps_input);
t_train = T_train;
t_test  = T_test;

%%  ת������Ӧģ��
p_train = p_train'; p_test = p_test';
t_train = t_train'; t_test = t_test';

%%  ��������
pop = 30;               % ��Ⱥ��Ŀ
Max_iter = 50;         % ��������
dim = 2;               % �Ż���������
lb = [0.1, 0.1];       % ����
ub = [100, 100];       % ����

%% �Ż�����
fobj = @(x)fitnessfunclssvm(x, p_train, t_train);

%% �Ż�
[Best_Cost,Best_pos,curve,avcurve]=INFO(pop,Max_iter,lb,ub,dim,fobj)
%% LSSVM��������
type        = 'c';                % ģ������ ����
kernel_type = 'RBF_kernel';       % RBF�˺���
codefct     = 'code_OneVsOne';    % һ��һ�������

%% ����
[t_train, codebook, old_codebook] = code(t_train, codefct);

%% ����ģ��
gam = Best_pos(1);  
sig = Best_pos(2);
model = initlssvm(p_train,t_train,type,gam,sig,kernel_type,codefct); 

%% ѵ��ģ��
model = trainlssvm(model);

%% ģ��Ԥ��
t_sim1 = simlssvm(model, p_train);
t_sim2 = simlssvm(model, p_test);

%% ����
T_sim1 = code(t_sim1,old_codebook,[],codebook);
T_sim2 = code(t_sim2,old_codebook,[],codebook);

%% ��������
error1 = sum((T_sim1' == T_train))/M * 100 ;
error2 = sum((T_sim2' == T_test))/N * 100 ;

%% �Ż�����
figure
plot(curve, 'linewidth', 1.5);
title('INFO_LSSVM Iterative curve')
xlabel('The number of iterations')
ylabel('Fitness')
grid on;

%%  ��ͼ
figure
plot(1:M,T_train,'r*',1:M,T_sim1,'bo','LineWidth',1)
legend('��ʵֵ','Ԥ��ֵ')
xlabel('Ԥ������')
ylabel('Ԥ����')
string={'ѵ����Ԥ�����Ա�';['׼ȷ��=' num2str(error1) '%']};
title(string)
grid

figure
plot(1:N,T_test,'r*',1:N,T_sim2,'bo','LineWidth',1)
legend('��ʵֵ','Ԥ��ֵ')
xlabel('Ԥ������')
ylabel('Ԥ����')
string={'���Լ�Ԥ�����Ա�';['׼ȷ��=' num2str(error2) '%']};
title(string)
grid