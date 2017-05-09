
clear ; close all; clc

%% Setup the parameters you will use for this part of the exercise
input_layer_size  = 400;  % 20x20 Input Images of Digits
num_labels = 10;          % 10 labels, from 1 to 10
                          % (note that we have mapped "0" to label 10)

load('ex3data1.mat'); % training data stored in arrays X, y
m = size(X, 1);

sel = X(randperm(m)(1:100), :); % Randomly select 100 data points to display
displayData(sel);

lambda = 0.1;
[all_theta] = oneVsAll(X, y, num_labels, lambda);

pred = predictOneVsAll(all_theta, X);
