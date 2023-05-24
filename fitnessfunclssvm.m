function fitness = fitnessfunclssvm(x, p_train, t_train)
%% 定义适应度函数

%% 得到优化参数
gam = x(1);
sig = x(2);
M = length(t_train);

%% 参数设置
type        = 'c';                % 模型类型 分类
kernel_type = 'RBF_kernel';       % RBF核函数
codefct     = 'code_OneVsOne';    % 一对一编码分类

%% 编码
T_train = t_train;
[t_train, codebook, old_codebook] = code(t_train, codefct);

%% 建立模型
model = initlssvm(p_train,t_train,type,gam,sig,kernel_type,codefct); 

%% 模型训练
model = trainlssvm(model);

%% 预测
t_sim = simlssvm(model, p_train);

%% 解码
t_sim = code(t_sim,old_codebook,[],codebook);

%% 得到适应度值
fitness = 1 - sum((t_sim == T_train))/M;

end