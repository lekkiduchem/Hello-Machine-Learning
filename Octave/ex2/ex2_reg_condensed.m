clear ; close all; clc

data = load('ex2data2.txt');
X = data(:, [1, 2]); y = data(:, 3);

% Plotting input data
plotData(X, y);
hold on;
xlabel('Microchip Test 1')
ylabel('Microchip Test 2')
legend('y = 1', 'y = 0')
hold off;

% Learning
X = mapFeature(X(:,1), X(:,2)); % Add Polynomial Features - Note that mapFeature also adds a column of ones for us, so the intercept term is handled
initial_theta = zeros(size(X, 2), 1); % Initialize fitting parameters
lambda = 0; % Set regularization parameter lambda to 1 (you should vary this)
options = optimset('GradObj', 'on', 'MaxIter', 400); % Set Options
[theta, J, exit_flag] = fminunc(@(t)(costFunctionReg(t, X, y, lambda)), initial_theta, options); % Optimize
%%%       .----------------------------------^
%%% costFunctionReg (WARNING:peudocode!):
%% m    = length(y); % number of training examples
%% h    = sigmoid( X * theta );
%% J    = (1/m) *  sum( -y .* log(h) - (1-y) .* log(1-h) );
%% grad = (1/m) *  ( X' * (h-y) );
%% J = J + (lambda/(2*m)) * sum( theta(2:end) .^ 2 );      % FUNCTION OUTPUT
%% grad(1) = 0                                             % FUNCTION OUTPUT ; why it always have to be zero???
%% grad(2:end) = grad(2:end) + (lambda/m)*theta(2:end);    % FUNCTION OUTPUT

% Results
TELL_ME_THE_FUTURE = [-0.6972, 0.2849]
p = predict(theta, X); % Compute accuracy on our training set
fprintf('Train Accuracy: %f\n', mean(double(p == y)) * 100);

prob = sigmoid(mapFeature(TELL_ME_THE_FUTURE(1), TELL_ME_THE_FUTURE(2)) * theta);
if prob > 0.5
  fprintf(['for x1=%f, x2=%f, we predict: Chip is OK! (with probability of being good %d%%)\n'], ...
            TELL_ME_THE_FUTURE(1), TELL_ME_THE_FUTURE(2),prob*100);
else
  fprintf(['for x1=%f, x2=%f, we predict: CHIP FAILURE! (with probability of being good %d%%)\n'], ...
            TELL_ME_THE_FUTURE(1), TELL_ME_THE_FUTURE(2),prob*100);
end

% Plot Results
plotData(X(:,2:3), y);
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
    contour(u, v, z, [0, 0], 'LineWidth', 2) % Notice you need to specify the range [0, 0]
end
title(sprintf('lambda = %g', lambda))
xlabel('Microchip Test 1')
ylabel('Microchip Test 2')
legend('y = 1', 'y = 0', 'Decision boundary')
hold off;
