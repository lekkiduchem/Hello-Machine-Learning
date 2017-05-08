clear ; close all; clc
data = load('ex2data1.txt');
X = data(:, [1, 2]); y = data(:, 3);

% Plotting input
% figure; hold on;
% pos = find(y==1);
% neg = find(y==0);
% plot(X(pos, 1), X(pos, 2), 'k+', 'LineWidth', 2, 'MarkerSize', 7);
% plot(X(neg, 1), X(neg, 2), 'ko', 'MarkerFaceColor', 'y', 'MarkerSize', 7);
% xlabel('Exam 1 score')
% ylabel('Exam 2 score')
% legend('Admitted', 'Not admitted')
% hold off;

% Learning
[m, n] = size(X);
X = [ones(m, 1) X];
initial_theta = zeros(n + 1, 1);
options = optimset('GradObj', 'on', 'MaxIter', 400); %  Set options for fminunc
[theta, cost] = fminunc(@(t)(costFunction(t, X, y)), initial_theta, options); %  Run fminunc to obtain the optimal theta
% costFunction:
% sigmoid = 1 ./ ( 1 + e.^( INPUT ) );
% h       =       sigmoid( X*theta )
% cost    = (1/m) *  sum( -y .* log(h) - (1-y) .* log(1-h) );   % FUNCTION OUTPUT : linear regression cost function
% grad    = (1/m) *  ( X' * (h-y) );  % FUNCTION OUTPUT : gradient descent

% Results
p = predict(theta, X);
fprintf('Train Accuracy: %f\n', mean(double(p == y)) * 100);
prob = 1    ./  ( 1 + e.^( -([1 45 85] * theta) ) );
fprintf(['For a student with scores 45 and 85, we predict an admission probability of %f\n'], prob);

%  Plotting results
plotData(X(:,2:3), y);
degree = 6;
hold on
if size(X, 2) <= 3
    plot_x = [min(X(:,2))-2,  max(X(:,2))+2]; % Only need 2 points to define a line, so choose two endpoints
    plot_y = (-1./theta(3)).*(theta(2).*plot_x + theta(1)); % Calculate the decision boundary line
    plot(plot_x, plot_y) % Plot, and adjust axes for better viewing
    legend('Admitted', 'Not admitted', 'Decision Boundary') % Legend, specific for the exercise
    axis([30, 100, 30, 100])
else
    u = linspace(-1, 1.5, 50); % Here is the grid range
    v = linspace(-1, 1.5, 50);
    z = zeros(length(u), length(v));
    for i = 1:length(u)
        for j = 1:length(v)
            z(i,j) = mapFeature(u(i), v(j))*theta; % Evaluate z = theta*x over the grid
        end
    end
    z = z'; % important to transpose z before calling contour % Plot z = 0
    % contour(u, v, z, [0, 0], 'LineWidth', 2) % Notice you need to specify the range [0, 0]
end
xlabel('Exam 1 score')
ylabel('Exam 2 score')
legend('Admitted', 'Not admitted')
hold off;
