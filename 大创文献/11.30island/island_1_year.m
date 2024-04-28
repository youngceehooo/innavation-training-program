%以20天为时间尺度进行调度，一年（18*20）所包含的时间节点为18个
%货船从A地出发向B地运输货物，以满足B地的物流供给平衡，从A至B的行驶时间为10天
%由于年调度过程中的预测尺度达不到10天，因此仍以20天为时间间隔来对船舶的出行进行规划
%包含1个时间间隔
clear all;
ts = 1;
T = 18 * 1 /ts;
%% 已知量
% lambda_path_11 = ones(1,T);%燃料购买费用
lambda_path_11 = xlsread('data','cost','A1:A18');%燃料购买费用
lambda_path_11 = lambda_path_11';
% pload_path_22 = 1 * ones(1,T); %海岛燃料消耗量
pload_path_22 = xlsread('data','load','A1:A18'); %海岛燃料消耗量
pload_path_22 =  pload_path_22';
% lambda_path_22 = 0.1 * ones(1,1); %燃料存储费用
pcmax_path_11 = 2000 * ones(1,1);  %某时刻的最大燃料购买量
pdmax_path_22 = 2000 * ones(1,1);  %某时刻的最大燃料卸载量
shipweight_max = 1600 * ones(1,T);  %货船最大载重量
shipweight_min = 0 * ones(1,T);  %货船最小载重量
islandweight_max = 2000 * ones(1,T);  %海岛最大燃料存储量
islandweight_min = 0 * ones(1,T); %海岛最小燃料存储量
shipweight_path_xx0 = 0.5 * shipweight_max(1); %初始时刻的船舶储油量
islandweight_path_xx0 = 0.5 * islandweight_max(1); %初始时刻的岛屿储油量

path_11_0 = 1;
path_12_0 = 0;
path_22_0 = 0;
path_21_0 = 0;
%% 决策变量
% path = binvar(8,84);
path_11 = binvar(1,T);%货船停在岛1
path_12 = binvar(1,T);%货船从岛1行驶到岛2
path_22 = binvar(1,T);%货船停在岛2
path_21 = binvar(1,T);%货船从岛2行驶到岛1

pc_path_11 = sdpvar(1,T);%货船在岛1充油
pd_path_22 = sdpvar(1,T);%货船在岛2卸油
pv_path_xx = sdpvar(1,T);    % 某一时间点航行过程中的燃料消耗量
u_path_xx = binvar(1,T);
shipweight_path_xx = sdpvar(1,T);%船的载油量
islandweight_path_xx = sdpvar(1,T);      %岛的储油量
%% 约束条件
st = [];
st = st + [0 <= pc_path_11 <= pcmax_path_11 * path_11 ];
st = st + [0 <= pd_path_22 <= pdmax_path_22 * path_22 ];
st = st + [u_path_xx == path_12 + path_21];
st = st + [1 == path_12 + path_21 + path_11 + path_22];
% st = st + [ pv_path_xx == min( u_path_xx * 1000000 , 0.1 * shipweight_path_xx + 30 ) ];
st = st + [ pv_path_xx == 0 ];

%航路连续性约束
t = 1;
% 初始状态path_11_0
st = st + [ path_11_0 <= path_12(1) + path_11(1)];
st = st + [ path_12_0 <= path_22(1) ];
st = st + [ path_22_0 <= path_22(1) + path_21(1) ];
st = st + [ path_21_0 <= path_11(1) ];
%航路连续性约束
for t = 1:T-1
st = st + [ path_11(t) <= path_12(t+1) + path_11(t+1) ];
st = st + [ path_12(t) <= path_22(t+1) ];
st = st + [ path_22(t) <= path_22(t+1) + path_21(t+1) ];
st = st + [ path_21(t) <= path_11(t+1) ];
end
%结束状态
st = st + [ path_11(T) == 1 ];
st = st + [ path_12(T) == 0 ];
st = st + [ path_22(T) == 0 ];
st = st + [ path_21(T) == 0 ];

%货船燃油供给平衡
t = 1;
st = st + ( shipweight_path_xx(t) == shipweight_path_xx0 + pc_path_11(t)  - pd_path_22(t) - pv_path_xx(t) );
for t = 2:T
st = st + ( shipweight_path_xx(t) == shipweight_path_xx(t-1) + pc_path_11(t)  - pd_path_22(t) - pv_path_xx(t) );
end
st = st + ( shipweight_path_xx(1,T) == shipweight_path_xx0 );%（1，T)代表第一行第T列的元素
st = st + ( shipweight_min <= shipweight_path_xx <= shipweight_max );

%海岛燃油供给平衡
t = 1;
st = st + ( islandweight_path_xx(t) == islandweight_path_xx0 + pd_path_22(t)  - pload_path_22(t) );
for t = 2:T
st = st + ( islandweight_path_xx(t) == islandweight_path_xx(t-1) + pd_path_22(t)  - pload_path_22(t) );
end
st = st + ( islandweight_path_xx(:,T) == islandweight_path_xx0 );   %(:,T)代表所有行第T列的列向量
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


