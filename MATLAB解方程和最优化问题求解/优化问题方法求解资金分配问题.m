% 优化问题方法求解资金分配问题
clear; clc;

%% 定义优化问题参数
initialCapital = 400;   % 初始资金（万元）
interestRate = 0.10;    % 年利率
years = 4;              % 总年数

%% 建立优化模型
% 设计变量：x = [x1; x2; x3; x4]（各年使用的资金）
x0 = ones(years,1)*100; % 初始猜测值（均匀分配）

% 目标函数：最大化总效益 = sum(sqrt(x))
objective = @(x) -sum(sqrt(x)); % 转化为最小化问题

% 线性约束矩阵（现值约束：x1 + x2/1.1 + x3/1.1^2 + x4/1.1^3 = 400）
Aeq = [1, 1/(1+interestRate), 1/(1+interestRate)^2, 1/(1+interestRate)^3];
beq = initialCapital;

% 变量边界约束（非负）
lb = zeros(years,1);
ub = [];

%% 求解优化问题
options = optimoptions('fmincon',...
    'Display','iter-detailed',...
    'Algorithm','sqp',...
    'MaxIterations',1000,...
    'StepTolerance',1e-12);

[x_opt, fval, exitflag] = fmincon(objective, x0, [], [], Aeq, beq, lb, ub, [], options);

%% 后处理与验证
totalBenefit = -fval;

% 计算资金流动过程
capitalFlow = zeros(years+1,1);
capitalFlow(1) = initialCapital;
for k = 1:years
    capitalFlow(k+1) = (capitalFlow(k) - x_opt(k)) * (1 + interestRate);
end

% 现值验证
presentValue = x_opt(1) +...
               x_opt(2)/(1+interestRate) +...
               x_opt(3)/(1+interestRate)^2 +...
               x_opt(4)/(1+interestRate)^3;

%% 结果展示
fprintf('\n===== 优化求解结果 =====\n');
fprintf('第一年使用: %.2f 万元\n', x_opt(1))
fprintf('第二年使用: %.2f 万元\n', x_opt(2))
fprintf('第三年使用: %.2f 万元\n', x_opt(3))
fprintf('第四年使用: %.2f 万元\n', x_opt(4))
fprintf('\n总效益: %.4f 万元\n', totalBenefit)
fprintf('现值验证: %.4f 万元 (理论值400.0000)\n', presentValue)
fprintf('最终资金余额: %.4f 万元\n', capitalFlow(end))

%% 资金流动可视化
figure('Color','white','Position',[100 100 800 600])
subplot(2,1,1)
bar(x_opt, 'FaceColor',[0.2 0.6 0.8])
title('最优资金分配方案')
xlabel('年份'), ylabel('使用金额（万元）')
grid on

subplot(2,1,2)
plot(0:years, capitalFlow, '-o','LineWidth',2,'MarkerSize',8)
title('资金状态变化过程')
xlabel('年份'), ylabel('可用资金（万元）')
xticks(0:years)
grid on

%% 约束验证
fprintf('\n===== 年度资金约束验证 =====\n');
for k = 1:years
    available = capitalFlow(k);
    used = x_opt(k);
    if used > available + 1e-6 % 考虑数值误差
        fprintf('第%d年违规：使用%.2f > 可用%.2f\n',k,used,available)
    else
        fprintf('第%d年验证通过：使用%.2f ≤ 可用%.2f\n',k,used,available)
    end
end