% Sizing optimization using MATLAB's inbuilt toolboxes

%% Using fminsearch - https://uk.mathworks.com/help/matlab/ref/fminsearch.html
% % But need to constrain variables to be non-negative
% x0 = [1, 1, 10]; % Initial guess for n_s, n_w, Eb_init
% x = fminsearch(@Objective_LI_DE_no_DR,x0)

%% Using https://uk.mathworks.com/help/optim/ug/example-nonlinear-constrained-minimization.html 
% Solve a Constrained Nonlinear Problem, Solver-Based 
% Solver 1: fmincon(https://uk.mathworks.com/help/optim/ug/fmincon.html)
% options = optimoptions(@fmincon,...
%     'Display','iter','Algorithm','interior-point','StepTolerance',1e-12,'ConstraintTolerance',1e-12,...
%     'FunctionTolerance',1e-12,'MaxIterations',10000, 'MaxFunctionEvaluations',10000);
options = optimoptions(@fmincon,...
    'Display','iter','Algorithm','interior-point');
[x,fval,exitflag,output] = fmincon(@Objective_LI_DE_v2_1h,[0 0 0],...
    [],[],[],[],[],[],@positive,options)

% Works well to give a reasonable result at least when using 5 equal weights
% But takes a large no. of iterations to converge, might be a local minimum rather than a global one!

%% GlobalSearch (https://uk.mathworks.com/help/gads/globalsearch.html)
% No longer need to specify constraints on inputs explicitly since it's now
% a bounded constrained optimization (positive constraint is enforced by lower bound)
rng default % For reproducibility
ms = MultiStart('UseParallel',true);
gs = GlobalSearch(ms);
options = optimoptions(@fmincon,...
    'Display','iter','Algorithm','active-set','MaxIterations',10000,'MaxFunctionEvaluations',10000);
problem = createOptimProblem('fmincon','objective',@Objective_LI_DE_v2_1h,'x0',[50 3.5 50],...
    'lb',[0,0,0],'ub',[100,20,200],'options',options);
x = run(gs,problem)

%% Multiple starting point search (https://uk.mathworks.com/help/gads/multistart.html)
rng default % For reproducibility
options = optimoptions(@fmincon,...
    'Algorithm','sqp','MaxIterations',10000,'MaxFunctionEvaluations',10000);
problem = createOptimProblem('fmincon','objective',...
    @Objective_LI_DE_v2_1h,'x0',[50 3.5 50],...
    'lb',[0,0,0],'ub',[100,20,200],'options',options);
ms = MultiStart('UseParallel',true);
[x,f] = run(ms,problem,78)

%% Direct pattern search (https://uk.mathworks.com/help/gads/patternsearch.html)
% Pattern search using several different initial/start points 
lb = [0,0,0];
ub = [100,20,200];
A = [];
b = [];
Aeq = [];
beq = [];

x = zeros(80,3);
fval = zeros(80,1);
options = optimoptions('patternsearch', 'UseParallel', true);

for i = 1:1:80
    x0 = lb + rand(size(lb)).*(ub - lb);
    [x(i,:), fval(i,:)] = patternsearch(@Objective_LI_DE_v2_1h,x0,A,b,Aeq,beq,lb,ub,options);
end

[min_obj, index] = min(fval)
x_opt = x(index,:)
%% Genetic algorithm (GA) 


%% PSO

%% Pareto sets using GA or Pattern search (multiobjective)