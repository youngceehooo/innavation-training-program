clear all;
% ��������µĺ���ȼ�ʹ洢�����Ϊָ�����м����ȡ��µ���
%��10��Ϊʱ��߶Ƚ��е��ȣ�һ������80�죨10*8����������ʱ��ڵ�Ϊ8��
%������A�س�����B��������������B�ص���������ƽ�⣬��A��B����ʻʱ��Ϊ20�죬��Ҫ����ʱ��ڵ����һ������
%����1��ʱ����,
T_outer = 18 - 5 ;      %ѭ������ = 18 - 5 + 1 = 14 ��
T = 100/10;
%�����Ż�������
path_11_0_save = [];
path_12_0_save = [];
path_22_0_save  = [];
path_21_0_save  = [];
pc_path_11_0_save  = [];
pd_path_22_0_save  = [];
pv_path_xx_0_save  = [];
u_path_xx_0_save  = [];
shipweight_path_xx_0_save  = [];
islandweight_path_xx_0_save  = [];  

%���������ȴ�����   ??????????
% ָ����
% shipweight_path_xx_year = xlsread('data','result','B10:S10'); %�����������µĻ�����Դ�洢
islandweight_path_xx_year = xlsread('data','result','B11:S11'); %�����������µĺ�����Դ�洢
% ������
lambda_path_11_year = xlsread('data','cost_80','A1:A36');       %�����������µ�ȼ�Ϲ������?????
lambda_path_11_year = lambda_path_11_year';
pload_path_22_year = xlsread('data','load_80','A1:A36');        %�����������µĺ���ȼ��������????
pload_path_22_year = 0.5 * pload_path_22_year';
% ��֪��
shipweight_max = 1600 * ones(1,T);  %�������������
shipweight_min = 0 * ones(1,T);  %������С������
islandweight_max = 2000 * ones(1,T);  %�������ȼ�ϴ洢��
islandweight_min = 0 * ones(1,T); %������Сȼ�ϴ洢��
pcmax_path_11 = 2000  * ones(1,1);  %ĳʱ�̵����ȼ�Ϲ�������????????
pdmax_path_22 = 2000  * ones(1,1);  %ĳʱ�̵����ȼ��ж����?????????????
shipweight_path_xx0 = 0.5 * shipweight_max(1); %��ʼʱ�̵Ĵ���������
islandweight_path_xx0 = 0.5 * islandweight_max(1); %��ʼʱ�̵Ĵ���������

path_11_0 = 1;
path_12_0 = 0;
path_22_0 = 0;
path_21_0 = 0;

for t_outer = 0:T_outer
%% ��֪��
% ����ȴ��ݵ���֪��   
lambda_path_11 = lambda_path_11_year(1, 2 * t_outer + 1:  2 * t_outer + T);%ȼ�Ϲ������
pload_path_22 = pload_path_22_year(1,2 * t_outer + 1: 2 * t_outer + T); %����ȼ��������
%% ���߱���
% path = binvar(8,84);
path_11 = binvar(1,T);
path_12 = binvar(1,T);
path_22 = binvar(1,T);
path_21 = binvar(1,T);
pc_path_11 = sdpvar(1,T);
pd_path_22 = sdpvar(1,T);
pv_path_xx = sdpvar(1,T);
u_path_xx = binvar(1,T);
shipweight_path_xx = sdpvar(1,T);
islandweight_path_xx = sdpvar(1,T);      

%% Լ������
st = [];
st = st + [0 <= pc_path_11 <= pcmax_path_11 * path_11 ];
st = st + [0 <= pd_path_22 <= pdmax_path_22 * path_22 ];
st = st + [u_path_xx == path_12 + path_21 ];
st = st + [1 == path_12 + path_22 + path_21 + path_11 ];
% st = st + [ pv_path_xx == min( u_path_xx * 500000 , 0.1 / 2 * shipweight_path_xx + 30/2) ]; %��������
st = st + [ pv_path_xx == 0 ]; %��������

%��·������Լ��
t = 1;
% ��ʼ״̬path_11_0
st = st + [ path_11_0 <= path_12(1) + path_11(1) ];
st = st + [ path_12_0 <= path_22(1) ];
st = st + [ path_22_0 <= path_22(1) + path_21(1) ];
st = st + [ path_21_0 <= path_11(1) ];

% ����״̬ ��Ҫ�����ʱ�̵Ľ���״̬����Ҫ��Ϳ���
if  t_outer == T_outer
st = st + [ path_11(T) == 1 ];
%������ĩʱ��������ȵĽ����ͬ����
st = st + ( islandweight_path_xx(T) == 0.5 * islandweight_max(T) );   
st = st + ( shipweight_path_xx(T) == 0.5 * shipweight_max(T) );   
end

for t = 1:T-1
st = st + [ path_11(t) <= path_12(t+1) + path_11(t+1) ];
st = st + [ path_12(t) <= path_22(t+1) ];
st = st + [ path_22(t) <= path_22(t+1) + path_21(t+1) ];
st = st + [ path_21(t) <= path_11(t+1) ];
end

%����ȼ�͹���ƽ��
t = 1;
st = st + ( shipweight_path_xx(t) == shipweight_path_xx0 + pc_path_11(t)  - pd_path_22(t) - pv_path_xx(t) );
for t = 2:T
st = st + ( shipweight_path_xx(t) == shipweight_path_xx(t-1) + pc_path_11(t)  - pd_path_22(t) - pv_path_xx(t) );
end
st = st + ( shipweight_min <= shipweight_path_xx <= shipweight_max );  


%����ȼ�͹���ƽ��
t = 1;
st = st + ( islandweight_path_xx(t) == islandweight_path_xx0 + pd_path_22(t)  - pload_path_22(t) );
for t = 2:T
st = st + ( islandweight_path_xx(t) == islandweight_path_xx(t-1) + pd_path_22(t)  - pload_path_22(t) );
end
st = st + ( islandweight_min <= islandweight_path_xx <= islandweight_max );  


%%%���������ȼƻ�ָ�������
%%%%%%%%%% ����������Ȼ�������⣿��������������������������
%   st = st + ( islandweight_min(1,1) <= islandweight_path_xx(T) <= islandweight_max(1,1) );   %������Լ�� 
%   st = st + ( shipweight_path_xx_year(T / 2 + t_outer) == shipweight_path_xx(T) );  
   st = st + ( islandweight_path_xx_year(T / 2 + t_outer) == islandweight_path_xx(T) );  

obj = lambda_path_11 * pc_path_11' + 6 / 2 * sum ( islandweight_path_xx ) + 1500 + 90 / 2 * sum ( shipweight_path_xx ) + 900 * sum(path_22); 
ops = sdpsettings('solver', 'cplex','verbose', 2);
solvesdp(st,obj,ops);

% �����Ż������д��ݵı���
path_11_0 = value(path_11(2));
path_12_0 = value(path_12(2));
path_22_0 = value(path_22(2));
path_21_0 = value(path_21(2));

shipweight_path_xx0 = value(shipweight_path_xx(2));
islandweight_path_xx0 = value(islandweight_path_xx(2));      

%�����Ż������д洢�ı���
path_11_0_save( 1 , 2 * t_outer + 1) = value(path_11(1));
path_12_0_save( 1 , 2 * t_outer + 1) = value(path_12(1));
path_22_0_save( 1 , 2 * t_outer + 1) = value(path_22(1));
path_21_0_save( 1 , 2 * t_outer + 1) = value(path_21(1));
pc_path_11_0_save( 1 , 2 * t_outer + 1) = value(pc_path_11(1));
pd_path_22_0_save( 1 , 2 * t_outer + 1) = value(pd_path_22(1));
pv_path_xx_0_save( 1 , 2 * t_outer + 1) = value(pv_path_xx(1));
u_path_xx_0_save( 1 , 2 * t_outer + 1) = value(u_path_xx(1));
shipweight_path_xx_0_save( 1 , 2 * t_outer + 1) = value(shipweight_path_xx(1));
islandweight_path_xx_0_save( 1 , 2 * t_outer + 1) = value(islandweight_path_xx(1));  

path_11_0_save( 1 , 2 * t_outer + 2) = value(path_11(2));
path_12_0_save( 1 , 2 * t_outer + 2) = value(path_12(2));
path_22_0_save( 1 , 2 * t_outer + 2) = value(path_22(2));
path_21_0_save( 1 , 2 * t_outer + 2) = value(path_21(2));
pc_path_11_0_save( 1 , 2 * t_outer + 2) = value(pc_path_11(2));
pd_path_22_0_save( 1 , 2 * t_outer + 2) = value(pd_path_22(2));
pv_path_xx_0_save( 1 , 2 * t_outer + 2) = value(pv_path_xx(2));
u_path_xx_0_save( 1 , 2 * t_outer + 2) = value(u_path_xx(2));
shipweight_path_xx_0_save( 1 , 2 * t_outer + 2) = value(shipweight_path_xx(2));
islandweight_path_xx_0_save( 1 , 2 * t_outer + 2) = value(islandweight_path_xx(2));  

t_outer

end

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

path_scroll = [];
path_scroll(1,:) = path_11_0_save;
path_scroll(2,:) = path_12_0_save;
path_scroll(3,:) = path_22_0_save;
path_scroll(4,:) = path_21_0_save;
path_scroll(5,:) = pc_path_11_0_save;
path_scroll(6,:) = pd_path_22_0_save;
path_scroll(7,:) = pv_path_xx_0_save;
path_scroll(8,:) = shipweight_path_xx_0_save;
path_scroll(9,:) = islandweight_path_xx_0_save;






