clear;clc;close all;
%%
load('../data/cartesian_states.mat');
load('../data/box_LMPandPSD.mat');
%%
states_s = cartesian_states{1};
obsers_s = box_LMPandPSD{1};

states = [states_s.Px states_s.Py states_s.Vx states_s.Vy];
features = obsers_s.features;
%% flatten the features
[n_ftr, n_node, n_bin] = size(features);
obsers_raw = zeros(n_bin, (n_ftr-1) * n_node);
% obsers = zeros(n_bin, n_node);
for i_bin = 1:n_bin
    feature_mat = features(:, :, i_bin);
    feature_vec = reshape(feature_mat(1:7, :), 1, []);
    % feature_vec = feature_mat(1, :);
    obsers_raw(i_bin, :) = feature_vec;
end
obsers = obsers_raw;
% obsers = z_score(obsers_raw);
%% generate slices
K = 5;
kk = 4;
[train_slices, val_slices, n_chan, n_trial, n_bin_slice] = ...
                    generate_slices(states, obsers, K, kk);

%% linear model
[result_Px, result_Py] = ...
    linear_model_with_slices(train_slices, val_slices, n_chan, n_trial, n_bin_slice);

%% Kalman filter training
[A, Q, C, R] = ...
                KF_training(train_slices, n_trial, n_chan);
%% Kalman filter predicting
states = (val_slices{1}.states)';
Pai = states(:, 1);
V = zeros(4, 4);
%% functions below
pred_states = ...
            KF_predicting(val_slices, A, Q, C, R, Pai, V);
%% verify two ground true
Px_linear_real = result_Px.real;
Px_linear_pred = result_Px.pred;
Px_KF_pred = pred_states(1, :);
Px_KF_real = states(1, :);

Py_linear_real = result_Py.real;
Py_linear_pred = result_Py.pred;
Py_KF_pred = pred_states(2, :);
Py_KF_real = states(2, :);
%% comparison perfomance
plot(Px_KF_real, '--b'); 
hold on; 
plot(Px_KF_pred, 'r'); 
plot(Px_linear_pred, 'g');
hold off;
%%
plot(Py_KF_real, '--b'); 
hold on; 
plot(Py_KF_pred, 'r'); 
plot(Py_linear_pred, 'g');
hold off;
%%
Rx_linear = corrcoef(Px_linear_real, Px_linear_pred);
ccx_linear = Rx_linear(1, 2);
Rx_KF = corrcoef(Px_KF_real, Px_KF_pred);
ccx_KF = Rx_KF(1, 2);
