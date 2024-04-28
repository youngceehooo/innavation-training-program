%��20��Ϊʱ��߶Ƚ��е��ȣ�һ�꣨18*20����������ʱ��ڵ�Ϊ18��
%������A�س�����B��������������B�ص���������ƽ�⣬��A��B����ʻʱ��Ϊ10��
%��������ȹ����е�Ԥ��߶ȴﲻ��10�죬�������20��Ϊʱ�������Դ����ĳ��н��й滮
%����1��ʱ����
clear all;
ts = 1;
T = 18 * 1 /ts;
%% ��֪��
% lambda_path_11 = ones(1,T);%ȼ�Ϲ������
lambda_path_11 = xlsread('data','cost','A1:A18');%ȼ�Ϲ������
lambda_path_11 = lambda_path_11';
% pload_path_22 = 1 * ones(1,T); %����ȼ��������
pload_path_22 = xlsread('data','load','A1:A18'); %����ȼ��������
pload_path_22 =  pload_path_22';
% lambda_path_22 = 0.1 * ones(1,1); %ȼ�ϴ洢����
pcmax_path_11 = 2000 * ones(1,1);  %ĳʱ�̵����ȼ�Ϲ�����
pdmax_path_22 = 2000 * ones(1,1);  %ĳʱ�̵����ȼ��ж����
shipweight_max = 1600 * ones(1,T);  %�������������
shipweight_min = 0 * ones(1,T);  %������С������
islandweight_max = 2000 * ones(1,T);  %�������ȼ�ϴ洢��
islandweight_min = 0 * ones(1,T); %������Сȼ�ϴ洢��
shipweight_path_xx0 = 0.5 * shipweight_max(1); %��ʼʱ�̵Ĵ���������
islandweight_path_xx0 = 0.5 * islandweight_max(1); %��ʼʱ�̵ĵ��촢����

path_11_0 = 1;
path_12_0 = 0;
path_22_0 = 0;
path_21_0 = 0;
%% ���߱���
% path = binvar(8,84);
path_11 = binvar(1,T);%����ͣ�ڵ�1
path_12 = binvar(1,T);%�����ӵ�1��ʻ����2
path_22 = binvar(1,T);%����ͣ�ڵ�2
path_21 = binvar(1,T);%�����ӵ�2��ʻ����1

pc_path_11 = sdpvar(1,T);%�����ڵ�1����
pd_path_22 = sdpvar(1,T);%�����ڵ�2ж��
pv_path_xx = sdpvar(1,T);    % ĳһʱ��㺽�й����е�ȼ��������
u_path_xx = binvar(1,T);
shipweight_path_xx = sdpvar(1,T);%����������
islandweight_path_xx = sdpvar(1,T);      %���Ĵ�����
%% Լ������
st = [];
st = st + [0 <= pc_path_11 <= pcmax_path_11 * path_11 ];
st = st + [0 <= pd_path_22 <= pdmax_path_22 * path_22 ];
st = st + [u_path_xx == path_12 + path_21];
st = st + [1 == path_12 + path_21 + path_11 + path_22];
% st = st + [ pv_path_xx == min( u_path_xx * 1000000 , 0.1 * shipweight_path_xx + 30 ) ];
st = st + [ pv_path_xx == 0 ];

%��·������Լ��
t = 1;
% ��ʼ״̬path_11_0
st = st + [ path_11_0 <= path_12(1) + path_11(1)];
st = st + [ path_12_0 <= path_22(1) ];
st = st + [ path_22_0 <= path_22(1) + path_21(1) ];
st = st + [ path_21_0 <= path_11(1) ];
%��·������Լ��
for t = 1:T-1
st = st + [ path_11(t) <= path_12(t+1) + path_11(t+1) ];
st = st + [ path_12(t) <= path_22(t+1) ];
st = st + [ path_22(t) <= path_22(t+1) + path_21(t+1) ];
st = st + [ path_21(t) <= path_11(t+1) ];
end
%����״̬
st = st + [ path_11(T) == 1 ];
st = st + [ path_12(T) == 0 ];
st = st + [ path_22(T) == 0 ];
st = st + [ path_21(T) == 0 ];

%����ȼ�͹���ƽ��
t = 1;
st = st + ( shipweight_path_xx(t) == shipweight_path_xx0 + pc_path_11(t)  - pd_path_22(t) - pv_path_xx(t) );
for t = 2:T
st = st + ( shipweight_path_xx(t) == shipweight_path_xx(t-1) + pc_path_11(t)  - pd_path_22(t) - pv_path_xx(t) );
end
st = st + ( shipweight_path_xx(1,T) == shipweight_path_xx0 );%��1��T)�����һ�е�T�е�Ԫ��
st = st + ( shipweight_min <= shipweight_path_xx <= shipweight_max );

%����ȼ�͹���ƽ��
t = 1;
st = st + ( islandweight_path_xx(t) == islandweight_path_xx0 + pd_path_22(t)  - pload_path_22(t) );
for t = 2:T
st = st + ( islandweight_path_xx(t) == islandweight_path_xx(t-1) + pd_path_22(t)  - pload_path_22(t) );
end
st = st + ( islandweight_path_xx(:,T) == islandweight_path_xx0 );   %(:,T)���������е�T�е�������
st = st + ( islandweight_min <= islandweight_path_xx <= islandweight_max );  


obj = lambda_path_11 * pc_path_11' +  6 * sum (islandweight_path_xx) + 1500 + 90 * sum (shipweight_path_xx) + 900 * sum(path_22); 
ops = sdpsettings('solver', 'cplex','verbose', 2);
sum_1=sum(path_22);
solvesdp(st,obj,ops);
f=value(obj);
path = [];
path(1,:) = path_11;
path(2,:) = path_12;
path(3,:) = path_22;
path(4,:) = path_21;
path(5,:) = pc_path_11;
path(6,:) = pd_path_22;
path(7,:) = pv_path_xx;
path(8,:) = shipweight_path_xx;
path(9,:) = islandweight_path_xx;


