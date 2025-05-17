function [y, n] = jacobi(A, b, x0, ep)
    % 参数检查
    if nargin == 3
        ep = 1.0e-6;
    elseif nargin < 3
        error('至少需要3个输入参数');
    end
    
    % 分解矩阵A为D, L, U
    D = diag(diag(A));
    L = -tril(A, -1);
    U = -triu(A, 1);
    
    % 计算迭代矩阵和常数项
    B = D \ (L + U); % 迭代矩阵
    f = D \ b;       % 常数项
    
    % 初始迭代
    y = B * x0 + f;  % 修正：使用B而不是b
    n = 1;            % 迭代次数计数
    
    % 迭代循环
    while norm(y - x0) >= ep
        x0 = y;
        y = B * x0 + f;
        n = n + 1;
    end
end