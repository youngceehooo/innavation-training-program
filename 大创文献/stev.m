%% 清空环境

clc;clear all;close all;
random_num=zeros(1,40);
t=[0,17,16,26,33,43,51,38;17,0,14,10,25,33,36,30;16,14,0,21,18,29,38,23;26,10,21,0,26,30,29,28;33,25,18,26,0,11,25,6;43,33,29,30,11,0,18,6;51,36,38,29,25,18,0,22;38,30,23,28,6,6,22,0];       % 各岛屿间转移时间矩阵
random_num(1)=1;
random_num(10)=1;
random_num(21)=8;
random_num(30)=8;%岛屿编号
visittime=zeros(1,40);%探岛时间和在岛时间数组
visittime(1)=0;
visittime(10)=0;
visittime(21)=0;
visittime(30)=0;

for i=2:9
    r=randperm(8,1);
    random_num(i)=r;
    random_num(i+10)=randperm(180,1);
    visittime(i+10)=random_num(i+10);
    frois=random_num(i-1);%前岛编号
    visittime(i)=t(frois,r);%岛间航行时间
end
for j=22:29
    r=randperm(8,1);
    random_num(j)=r;
    random_num(j+10)=randperm(180,1);
    visittime(j+10)=random_num(j+10);
    frois=random_num(j-1);%前岛编号
    visittime(j)=t(frois,r);%岛间航行时间
end
disp(random_num);
disp(visittime);
a=1/60*[-60,-60,-60,-60,-60,-60,...%功率矩阵
    -60,-60,-60,-60,500,500,500,500,500,...
    500,500,500,500,500,-60,-60,-60,-60,...
    -60,-60,-60,-60,-60,-60,500,500,500,...
    500,500,500,500,500,500,500];%风光出力原本是个函数图咋导进矩阵里
a1=a(1,11:20);%系数矩阵
a2=a(1,1:10);
a3=a(1,21:30);
a4=a(1,31:40);
b=ones(40,1);
fun= @(X)(dot(a,X));
cons1= @(X)(300<=dot(a,X)<=2700);%SOC约束，要分前20个维度（第一艘船）和后20个维度（第二艘船）
cons2= @(X)(0<dot(b,X)<540);%时间约束，同上
%cons3=@(X)()%整型变量约束？
%cons4=@(X)()%不能同时在同岛约束？
%cons5=@(X)()%充电功率约束？
%% 设置种群参数

sizepop = 100;                         % 初始种群个数
dim = 40;                           % 空间维数
ger = 500;                       % 最大迭代次数
xlimit_max = 60*ones(1,dim);     % 设置位置参数限制(矩阵的形式可以多维)

xlimit_min = 0*ones(1,dim);
vlimit_max = 1*ones(1,dim);      % 设置速度限制
vlimit_min = -1*ones(1,dim);
c_1 = 0.8;                       % 惯性权重（可采用递减惯性权重改良）
c_2 = 1.5;                       % 自我学习因子
c_3 = 1.5;                       % 群体学习因子
%% 生成初始种群
%%
% 
%  首先随机生成初始种群位置
%  然后随机生成初始种群速度
%  然后初始化个体历史最佳位置，以及个体历史最佳适应度
%  然后初始化群体历史最佳位置，以及群体历史最佳适应度
%

for j=1:dim
    for i=1:sizepop
        pop_x(i,j) = xlimit_min(j)+(xlimit_max(j) - xlimit_min(j))*rand;  % 初始种群的位置
        pop_v(i,j) = vlimit_min(j)+(vlimit_max(j) - vlimit_min(j))*rand;  % 初始种群的速度
    end
end
gbest = pop_x;% 每个个体的历史最佳位置
fitness_gbest=zeros(sizepop,1);
for i=1:sizepop
    if cons1(pop_x(i,:))
        if cons2(pop_x(i,:))
            
            fitness_gbest(i,1) = fun(pop_x(i,:))  ;                   % 每个个体的历史最佳适应度
        else
            fitness_gbest(i,1) = 10^(-10);
        end
    else
        fitness_gbest(i,1) = 10^(-10);
    end
end
zbest=zeros(1,40);
zbest = pop_x(1,:);                           % 种群的历史最佳位置
fitness_zbest = fitness_gbest(1,1);             % 种群的历史最佳适应度
for i=1:sizepop
    if fitness_gbest(i,1) > fitness_zbest       % 如果求最小值，则为<; 如果求最大值，则为>;
        zbest = pop_x(i,:);
        fitness_zbest=fitness_gbest(i,1);
    end
end
%% 粒子群迭代
%%
% 
%    更新速度并对速度进行边界处理
%    更新位置并对位置进行边界处理
%    进行自适应变异
%    进行约束条件判断并计算新种群各个个体位置的适应度
%    新适应度与个体历史最佳适应度做比较
%    个体历史最佳适应度与种群历史最佳适应度做比较
%    再次循环或结束
%

iter = 1;                        %迭代次数
record = zeros(ger, 1);          % 记录器
while iter <= ger
    for i=1:sizepop
        %    更新速度并对速度进行边界处理
        pop_v(i,:)= c_1 * pop_v(i,:) + c_2*rand*(gbest(i,:)-pop_x(i,:))+c_3*rand*(zbest-pop_x(i,:));% 速度更新
        for j=1:dim
            if  pop_v(i,j) > vlimit_max(j)
                pop_v(i,j) = vlimit_max(j);
            end
            if  pop_v(i,j) < vlimit_min(j)
                pop_v(i,j) = vlimit_min(j);
            end
        end
        
        %    更新位置并对位置进行边界处理
        pop_x(i,:) = pop_x(i,:) + pop_v(i,:);% 位置更新
        for j=1:dim
            if  pop_x(i,j) > xlimit_max(j)
                pop_x(i,j) = xlimit_max(j);
            end
            if  pop_x(i,j) < xlimit_min(j)
                pop_x(i,j) = xlimit_min(j);
            end
        end
        
        %    进行自适应变异
        if rand > 0.85
            j=ceil(dim*rand);
            pop_x(i,j)=xlimit_min(j) + (xlimit_max(j) - xlimit_min(j)) * rand;
        end
        %    进行约束条件判断并计算新种群各个个体位置的适应度
        for i=1:sizepop
        if cons1(pop_x(i,:))
            if cons2(pop_x(i,:))%约束条件有几个算几个
                fitness_pop(i,1) = fun(pop_x(i,:));                      % 当前个体的适应度
            else
                fitness_pop(i,1) = 10^-(10);
            end
        else
            fitness_pop(i,1) = 10^(-10);%对不符合约束条件的进行惩罚
        end
        end
        
        %    新适应度与个体历史最佳适应度做比较
        for i=1:sizepop
        if fitness_pop(i) > fitness_gbest(i)       % 如果求最小值，则为<; 如果求最大值，则为>;
            gbest(i,:) = pop_x(i,:);               % 更新个体历史最佳位置
            fitness_gbest(i) = fitness_pop(i);     % 更新个体历史最佳适应度
        end
        end 
        %    个体历史最佳适应度与种群历史最佳适应度做比较
        for i=1:sizepop
        if fitness_gbest(i) > fitness_zbest        % 如果求最小值，则为<; 如果求最大值，则为>;
            zbest = gbest(i,:);                    % 更新群体历史最佳位置
            fitness_zbest=fitness_gbest(i);        % 更新群体历史最佳适应度
        end
    end
    end
    record(iter) = fitness_zbest;%最大值记录
    
    iter = iter+1;
    
end
%% 迭代结果输出

plot(record);title('收敛过程')
disp(['最优值：',num2str(fitness_zbest)]);
disp('变量取值：');
disp(zbest);