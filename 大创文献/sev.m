%SEV参数
C=1500;%电池容量
Pcm=300;
Pdm=300;%最大充放电功率
Pdo=800;%太平岛柴油出力
Pwl=375;%安达礁风光出力
quantity=60;%额定载客人数
Vn=22;%额定船速
Pn=43.97;%额定航行功率
P0=32.4;%空载航行功率
compensate=4;%迟到赔偿系数
SOC1=[0.5,0.5,0.5];%起始状态各岛固定储能
SOC2=[0.2];%SEV初始储能
timesteps=
%定义变量
Z1=binvar(3,3,timesteps);%表示SEV在弧状态，这些弧没有方向
Z2=binvar(3,3);%表示从i出发的弧的集合，所以对角线

%目标函数
obj=2*Z1(1)+3*Z1(2);
%约束条件
constraint=[];
constraint=[constraint,sum(Z1, 'all')==1];
constraint=[constraint,];
constraint=[constraint,2*Z1(1)+Z1(2)<=600];
constraint=[constraint,Z1(2)>=0];
%求解
ops = sdpsettings('solver','cplex','verbose',1);
ops.cplex.display='on';
ops.cplex.timelimit=600;
ops.cplex.mip.tolerances.mipgap=0.001;
% 诊断求解可行性
disp('开始求解')
diagnostics=optimize(constraint,obj,ops);
if diagnostics.problem==0
    disp('Solver thinks it is feasible')
elseif diagnostics.problem == 1
    disp('Solver thinks it is infeasible')
    pause();
else
    disp('Timeout, Display the current optimal solution')
end