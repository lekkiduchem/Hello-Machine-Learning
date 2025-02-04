function [J, grad] = costFunction(theta, X, y)
%COSTFUNCTION Compute cost and gradient for logistic regression
%   J = COSTFUNCTION(theta, X, y) computes the cost of using theta as the
%   parameter for logistic regression and the gradient of the cost
%   w.r.t. to the parameters.

% Initialize some useful values
m = length(y); % number of training examples

% You need to return the following variables correctly
J = 0;
grad = zeros(size(theta));

% ====================== YOUR CODE HERE ======================
% Instructions: Compute the cost of a particular choice of theta.
%               You should set J to the cost.
%               Compute the partial derivatives and set grad to the partial
%               derivatives of the cost w.r.t. each parameter in theta
%
% Note: grad should have the same dimensions as theta
%

h    = sigmoid( X * theta );
J    = (1/m) *  sum( -y .* log(h) - (1-y) .* log(1-h) );
grad = (1/m) *  ( X' * (h-y) );




% =============================================================

end


% examples of different implementations from github
% Cost function J
% J = (1/m) *  sum(-y .* log(h) - (1-y) .* log(1-h))
% J = (1/m) *     (-y' * log(h) - (1-y)' * log(1-h))
%
% Hypothesis function
% h = sigmoid(X*theta);
% h = sigmoid(theta' * X(i,:)');

% Gradient
% 1: grad = (1/m) * ((h - y)' * X);
% 2:
% for i=1:m,
%   h = sigmoid(theta'*X(i,:)');
%   temp = h - y(i);
%   for j=1:n,
%     grad(j) = grad(j) + temp * X(i,j);
%   end;
% end;
% grad = grad/m;
