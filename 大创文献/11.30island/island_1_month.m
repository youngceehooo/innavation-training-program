clear all;
% 以年调度下的海岛燃油存储量结果为指导进行月调度
%以5天为时间尺度进行调度，一个季度50天（10*5）所包含的时间节点为10个
%货船从A地出发向B地运输货物，以满足B地的物流供给平衡，从A至B的行驶时间为10天，需要两个时间节点进行一次运输
%包含1个时间间隔,
T_outer = 36 - 5  ;      %循环次数 = 18 - 4 + 1 = 15 次
T =  50 / 5;
%滚动优化传递量
path_11_0_save = [];
path_12_0_save = [];
path_23_0_save = [];
path_33_0_save  = [];
path_32_0_save  = [];
path_21_0_save  = [];
pc_path_11_0_save  = [];
pd_path_33_0_save  = [];
pv_path_xx_0_save  = [];
u_path_xx_0_save  = [];
shipweight_path_xx_0_save  = [];
islandweight_path_xx_0_save  = [];  

%年物流调度传递量   ??????????
% 指导量 
% shipweight_path_xx_year = xlsread('data','result','B10:S10'); %年物流调度下的货船资源存储
islandweight_path_xx_year = xlsread('data','result','B25:AK25'); %季物流调度下的海岛资源存储
% 传递量
lambda_path_11_year = xlsread('data','cost_50','A1:A72');       %年物流调度下的燃料购买费用
lambda_path_11_year = lambda_path_11_year';
pload_path_33_year = xlsread('data','load_50','A1:A72');        %年物流调度下的海岛燃油消耗量
pload_path_33_year = pload_path_33_year'* 0.25;
% 已知量
shipweight_max = 1600 * ones(1,T);  %货船最大载重量
shipweight_min = 0 * ones(1,T);  %货船最小载重量
islandweight_max = 2000 * ones(1,T);  %海岛最大燃料存储量
islandweight_min = 0 * ones(1,T); %海岛最小燃料存储量
pcmax_path_11 = 2000   * ones(1,1);  %某时刻的最大燃料购买量？????????
pdmax_path_33 = 2000  * ones(1,1);  %某时刻的最大燃料卸载量?????????????
shipweight_path_xx0 = 0.5 * shipweight_max(1); %初始时刻的船舶储油量
islandweight_path_xx0 = 0.5 * islandweight_max(1); %初始时刻的船舶储油量

path_11_0 = 1;
path_12_0 = 0;
path_23_0 = 0;
path_33_0 = 0;
path_32_0 = 0;
path_21_0 = 0;

for t_outer = 0:T_outer
%% 已知量
% 年调度传递的已知量   
lambda_path_11 = lambda_path_11_year(1,2 * t_outer + 1: 2 * t_outer + T);%燃料购买费用
pload_path_33 = pload_path_33_year(1,2 * t_outer + 1: 2 * t_outer + T); %海岛燃料消耗量
%% 决策变量
% path = binvar(8,84);
path_11 = binvar(1,T);
path_12 = binvar(1,T);
path_23 = binvar(1,T);
path_33 = binvar(1,T);
path_32 = binvar(1,T);
path_21 = binvar(1,T);

pc_path_11 = sdpvar(1,T);
pd_path_33 = sdpvar(1,T);
pv_path_xx = sdpvar(1,T);
u_path_xx = binvar(1,T);
shipweight_path_xx = sdpvar(1,T);
islandweight_path_xx = sdpvar(1,T);      

%% 约束条件
st = [];
st = st + [0 <= pc_path_11 <= pcmax_path_11 * path_11 ];
st = st + [0 <= pd_path_33 <= pdmax_path_33 * path_33 ];
st = st + [u_path_xx == path_12 + path_23 + path_32 + path_21 ];
st = st + [1 == path_12 + path_23 + path_33 + path_32 + path_21 + path_11 ];
% st = st + [ pv_path_xx == min( u_path_xx * 500000 , 0.1 / 4 * shipweight_path_xx + 30/4) ]; %参数问题
st = st + [ pv_path_xx == 0 ]; %参数问题

%航路连续性约束
t = 1;
% 初始状态path_11_0
st = st + [ path_11_0 <= path_12(1) + path_11(1) ];
st = st + [ path_12_0 <= path_23(1) ];
st = st + [ path_23_0 <= path_33(1) ];
st = st + [ path_33_0 <= path_32(1) + path_33(1) ];
st = st + [ path_32_0 <= path_21(1) ];
st = st + [ path_21_0 <= path_11(1) ];

% 结束状态 仅要求最后时刻的结束状态满足要求就可以
if  t_outer == T_outer
st = st + [ path_11(T) == 1 ];
%仅需在末时刻与年调度的结果相同即可
st = st + ( islandweight_path_xx(T) == 0.5 * islandweight_max(T) );   
st = st + ( shipweight_path_xx(T) == 0.5 * shipweight_max(T) );   
end

for t = 1:T-1
st = st + [ path_11(t) <= path_12(t+1) + path_11(t+1) ];
st = st + [ path_12(t) <= path_23(t+1) ];
st = st + [ path_23(t) <= path_33(t+1) ];
st = st + [ path_33(t) <= path_32(t+1) + path_33(t+1) ];
st = st + [ path_32(t) <= path_21(t+1) ];
st = st + [ path_21(t) <= path_11(t+1) ];
end

%货船燃油供给平衡
t = 1;
st = st + ( shipweight_path_xx(t) == shipweight_path_xx0 + pc_path_11(t)  - pd_path_33(t) - pv_path_xx(t) );
for t = 2:T
st = st + ( shipweight_path_xx(t) == shipweight_path_xx(t-1) + pc_path_11(t)  - pd_path_33(t) - pv_path_xx(t) );
end
st = st + ( shipweight_min <= shipweight_path_xx <= shipweight_max );  


%海岛燃油供给平衡
t = 1;
st = st + ( islandweight_path_xx(t) == islandweight_path_xx0 + pd_path_33(t)  - pload_path_33(t) );
for t = 2:T
st = st + ( islandweight_path_xx(t) == islandweight_path_xx(t-1) + pd_path_33(t)  - pload_path_33(t) );
end
st = st + ( islandweight_min <= islandweight_path_xx <= islandweight_max );  


%%%年物流调度计划指导性意见
%%%%%%%%%% 滚动条件仍然存在问题？？？？？？？？？？？？？？
%   st = st + ( islandweight_min(1,1) <= islandweight_path_xx(T) <= islandweight_max(1,1) );   %测试性约束 
%   st = st + ( shipweight_path_xx_year(T / 2 + t_outer) == shipweight_path_xx(T) );  
%    st = st + ( islandweight_path_xx_year(T / 2 + t_outer) == islandweight_path_xx(T) );
K = 0;
for j = 1 : T/2
%     K = K + ( islandweight_path_xx_year(j + t_outer) - islandweight_path_xx(2*j) ).^2  
    K = K + abs( islandweight_path_xx_year(j + t_outer) - islandweight_path_xx(2*j) )  

end
obj = K + 900 * sum(path_33) ;  


%  obj = lambda_path_11 * pc_path_11' + 6 / 4 * sum ( islandweight_path_xx ) + 1500 ; 
ops = sdpsettings('solver', 'cplex','verbose', 2);
solvesdp(st,obj,ops);

% 滚动优化过程中传递的变量
path_11_0 = value(path_11(2));
path_12_0 = value(path_12(2));
path_23_0 = value(path_23(2));
path_33_0 = value(path_33(2));
path_32_0 = value(path_32(2));
path_21_0 = value(path_21(2));

shipweight_path_xx0 = value(shipweight_path_xx(2));
islandweight_path_xx0 = value(islandweight_path_xx(2));      

%滚动优化过程中存储的变量
path_11_0_save( 1 , 2 * t_outer + 1) = value(path_11(1));
path_12_0_save( 1 , 2 * t_outer + 1) = value(path_12(1));
path_23_0_save( 1 , 2 * t_outer + 1) = value(path_23(1));
path_33_0_save( 1 , 2 * t_outer + 1) = value(path_33(1));
path_32_0_save( 1 , 2 * t_outer + 1) = value(path_32(1));
path_21_0_save( 1 , 2 * t_outer + 1) = value(path_21(1));
pc_path_11_0_save( 1 , 2 * t_outer + 1) = value(pc_path_11(1));
pd_path_33_0_save( 1 , 2 * t_outer + 1) = value(pd_path_33(1));
pv_path_xx_0_save( 1 , 2 * t_outer + 1) = value(pv_path_xx(1));
u_path_xx_0_save( 1 , 2 * t_outer + 1) = value(u_path_xx(1));
shipweight_path_xx_0_save( 1 , 2 * t_outer + 1) = value(shipweight_path_xx(1));
islandweight_path_xx_0_save( 1 , 2 * t_outer + 1) = value(islandweight_path_xx(1));  

path_11_0_save( 1 , 2 * t_outer + 2) = value(path_11(2));
path_12_0_save( 1 , 2 * t_outer + 2) = value(path_12(2));
path_23_0_save( 1 , 2 * t_outer + 2) = value(path_23(2));
path_33_0_save( 1 , 2 * t_outer + 2) = value(path_33(2));
path_32_0_save( 1 , 2 * t_outer + 2) = value(path_32(2));
path_21_0_save( 1 , 2 * t_outer + 2) = value(path_21(2));
pc_path_11_0_save( 1 , 2 * t_outer + 2) = value(pc_path_11(2));
pd_path_33_0_save( 1 , 2 * t_outer + 2) = value(pd_path_33(2));
pv_path_xx_0_save( 1 , 2 * t_outer + 2) = value(pv_path_xx(2));
u_path_xx_0_save( 1 , 2 * t_outer + 2) = value(u_path_xx(2));
shipweight_path_xx_0_save( 1 , 2 * t_outer + 2) = value(shipweight_path_xx(2));
islandweight_path_xx_0_save( 1 , 2 * t_outer + 2) = value(islandweight_path_xx(2));  

t_outer

end

path = [];
path(1,:) = path_11;
path(2,:) = path_12;
path(3,:) = path_23;
path(4,:) = path_33;
path(5,:) = path_32;
path(6,:) = path_21;
path(7,:) = pc_path_11;
path(8,:) = pd_path_33;
path(9,:) = pv_path_xx;
path(10,:) = shipweight_path_xx;
path(11,:) = islandweight_path_xx;

path_scroll = [];
path_scroll(1,:) = path_11_0_save;
path_scroll(2,:) = path_12_0_save;
path_scroll(3,:) = path_23_0_save;
path_scroll(4,:) = path_33_0_save;
path_scroll(5,:) = path_32_0_save;
path_scroll(6,:) = path_21_0_save;
path_scroll(7,:) = pc_path_11_0_save;
path_scroll(8,:) = pd_path_33_0_save;
path_scroll(9,:) = pv_path_xx_0_save;
path_scroll(10,:) = shipweight_path_xx_0_save;
path_scroll(11,:) = islandweight_path_xx_0_save;




