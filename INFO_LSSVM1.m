%%  清空环境变量
clear
clc
warning off

%%  导入数据
load res.mat

%%  随机划分训练集和测试集
temp = randperm(200);
% 训练集——150个样本
P_train = res(temp(1:150),1:12)';
T_train = res(temp(1:150),13)';
M = size(P_train,2);
% 测试集——50个样本
P_test = res(temp(151:end),1:12)';
T_test = res(temp(151:end),13)';
N = size(P_test,2);
%% 数据归一化
[p_train, ps_input] = mapminmax(P_train,0,1);
p_test = mapminmax('apply',P_test,ps_input);
t_train = T_train;
t_test  = T_test;

%%  转置以适应模型
p_train = p_train'; p_test = p_test';
t_train = t_train'; t_test = t_test';

%%  参数设置
pop = 30;               % 种群数目
Max_iter = 50;         % 迭代次数
dim = 2;               % 优化参数个数
lb = [0.1, 0.1];       % 下限
ub = [100, 100];       % 上限

%% 优化函数
fobj = @(x)fitnessfunclssvm(x, p_train, t_train);

%% 优化
[Best_Cost,Best_pos,curve,avcurve]=INFO(pop,Max_iter,lb,ub,dim,fobj)
%% LSSVM参数设置
type        = 'c';                % 模型类型 分类
kernel_type = 'RBF_kernel';       % RBF核函数
codefct     = 'code_OneVsOne';    % 一对一编码分类

%% 编码
[t_train, codebook, old_codebook] = code(t_train, codefct);

%% 建立模型
gam = Best_pos(1);  
sig = Best_pos(2);
model = initlssvm(p_train,t_train,type,gam,sig,kernel_type,codefct); 

%% 训练模型
model = trainlssvm(model);

%% 模型预测
t_sim1 = simlssvm(model, p_train);
t_sim2 = simlssvm(model, p_test);

%% 解码
T_sim1 = code(t_sim1,old_codebook,[],codebook);
T_sim2 = code(t_sim2,old_codebook,[],codebook);

%% 性能评价
error1 = sum((T_sim1' == T_train))/M * 100 ;
error2 = sum((T_sim2' == T_test))/N * 100 ;

%% 优化曲线
figure
plot(curve, 'linewidth', 1.5);
title('INFO_LSSVM Iterative curve')
xlabel('The number of iterations')
ylabel('Fitness')
grid on;

%%  绘图
figure
plot(1:M,T_train,'r*',1:M,T_sim1,'bo','LineWidth',1)
legend('真实值','预测值')
xlabel('预测样本')
ylabel('预测结果')
string={'训练集预测结果对比';['准确率=' num2str(error1) '%']};
title(string)
grid

figure
plot(1:N,T_test,'r*',1:N,T_sim2,'bo','LineWidth',1)
legend('真实值','预测值')
xlabel('预测样本')
ylabel('预测结果')
string={'测试集预测结果对比';['准确率=' num2str(error2) '%']};
title(string)
grid