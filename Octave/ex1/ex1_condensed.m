data = load('ex1data1.txt');
X = data(:, 1);
y = data(:, 2);
m = length(y); % number of training examples
figure;
plot(X, y, 'rx', 'MarkerSize', 10);
X = [ones(m, 1), data(:,1)];
iterations = 100;
alpha = 0.01;
theta = zeros(2, 1);
J = sum((X * theta - y) .^ 2) / (2*m);
printf("J = %d", J)
theta = [-3.895781 ; 1.193034];
J = sum((X * theta - y) .^ 2) / (2*m);
printf("J = %d", J)

J_history = -zeros(iterations, 1);
for iter = 1:iterations
    h = (X * theta - y)';
    theta(1) = theta(1) - alpha * (1/m) * h * X(:, 1);
    theta(2) = theta(2) - alpha * (1/m) * h * X(:, 2);
    J_history(iter) = sum((X * theta - y) .^ 2) / (2*m);
    printf("%f \t %15f \n", theta')
end

% figure;
plot(X(:,2), X*theta, '-')
% legend('Training data', 'Linear regression')
%
% predict1 = [1, 3.5] *theta;
% fprintf('For population = 35,000, we predict a profit of %f\n',...
%     predict1*10000);
% predict2 = [1, 7] * theta;
% fprintf('For population = 70,000, we predict a profit of %f\n',...
%     predict2*10000);
%
%     theta0_vals = linspace(-10, 10, 100);
%     theta1_vals = linspace(-1, 4, 100);
%
%     J_vals = zeros(length(theta0_vals), length(theta1_vals));
%
%     for i = 1:length(theta0_vals)
%         for j = 1:length(theta1_vals)
%     	  t = [theta0_vals(i); theta1_vals(j)];
%     	  J_vals(i,j) = sum((X * t - y) .^ 2) / (2*m);
%         end
%     end
%
%
%   J_vals = J_vals';
%   figure;
%   surf(theta0_vals, theta1_vals, J_vals)
%   xlabel('\theta_0'); ylabel('\theta_1');
%   figure;
%   contour(theta0_vals, theta1_vals, J_vals, logspace(-2, 3, 20))
%   xlabel('\theta_0'); ylabel('\theta_1');
%   hold on;
%   plot(theta(1), theta(2), 'rx', 'MarkerSize', 10, 'LineWidth', 2);
