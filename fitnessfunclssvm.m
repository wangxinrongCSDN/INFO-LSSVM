function fitness = fitnessfunclssvm(x, p_train, t_train)
%% ������Ӧ�Ⱥ���

%% �õ��Ż�����
gam = x(1);
sig = x(2);
M = length(t_train);

%% ��������
type        = 'c';                % ģ������ ����
kernel_type = 'RBF_kernel';       % RBF�˺���
codefct     = 'code_OneVsOne';    % һ��һ�������

%% ����
T_train = t_train;
[t_train, codebook, old_codebook] = code(t_train, codefct);

%% ����ģ��
model = initlssvm(p_train,t_train,type,gam,sig,kernel_type,codefct); 

%% ģ��ѵ��
model = trainlssvm(model);

%% Ԥ��
t_sim = simlssvm(model, p_train);

%% ����
t_sim = code(t_sim,old_codebook,[],codebook);

%% �õ���Ӧ��ֵ
fitness = 1 - sum((t_sim == T_train))/M;

end