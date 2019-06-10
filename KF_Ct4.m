clear;clc;close all;
%%
load('../data/cartesian_states.mat');
load('../data/LMPandPSD.mat');
%% parameters
i_sub = 1;
kk = 3;
LMP_flag = 0;
PSD_flag = 1;
smo_flag = 0;

trainPaiV_flag = 1;
zscore_flag = 0;
%%
states_s = cartesian_states{i_sub};
obsers_s = LMPandPSD{i_sub};

states = [states_s.Px states_s.Py states_s.Vx states_s.Vy];

if smo_flag == 0
    features = obsers_s.feature;
else
    features = obsers_s.feature_smo;
end
%% flatten the features
[n_ftr, n_node, n_bin] = size(features);

if LMP_flag == 0 && PSD_flag == 1
    obsers_raw = zeros(n_bin, (n_ftr-1) * n_node);
    ftr_selected = 1 : (n_ftr-1);
elseif LMP_flag == 1 && PSD_flag == 0
    obsers_raw = zeros(n_bin, 1 * n_node);
    ftr_selected = n_ftr;
elseif LMP_flag == 1 && PSD_flag == 1
    obsers_raw = zeros(n_bin, n_ftr * n_node);
    ftr_selected = 1 : n_ftr;
end

for i_bin = 1:n_bin
    feature_mat = features(:, :, i_bin);
    feature_vec = reshape(feature_mat(ftr_selected, :), 1, []);
    obsers_raw(i_bin, :) = feature_vec;
end

if zscore_flag == 0
    obsers = obsers_raw;
else 
    obsers = z_score(obsers_raw);
end
%% generate slices
K = 5;
[train_slices, val_slices, n_chan, n_trial, n_bin_slice] = ...
                    generate_slices(states, obsers, K, kk);

%% linear model
[result_Px, result_Py] = ...
    linear_model_with_slices(train_slices, val_slices, n_chan, n_trial, n_bin_slice);

%% Kalman filter training
[A, Q, C, R] = ...
                KF_training(train_slices, n_trial, n_chan);
%% Kalman filter predicting
if trainPaiV_flag == 0
    states = (val_slices{1}.states)';
    Pai = states(:, 1);
    V = zeros(4, 4);
else
    [Pai, V] = KF_Pai_V(n_trial, train_slices);
end
%% functions below
pred_states = ...
            KF_predicting(val_slices, A, Q, C, R, Pai, V);
%% verify two ground true
states = (val_slices{1}.states)';

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
h1 = figure;
set(h1, 'Position', [200 100 600 300]);

plot(Py_KF_real, '--b'); 
hold on; 
plot(Py_KF_pred, 'r'); 
plot(Py_linear_pred, 'g');
hold off;

set(gca, 'fontsize', 16, 'fontweight', 'bold')
xlabel('Time bin', 'FontSize', 16)
%%
Rx_linear = corrcoef(Px_linear_real, Px_linear_pred);
ccx_linear = Rx_linear(1, 2);
Rx_KF = corrcoef(Px_KF_real, Px_KF_pred);
ccx_KF = Rx_KF(1, 2);

Ry_linear = corrcoef(Py_linear_real, Py_linear_pred);
ccy_linear = Ry_linear(1, 2);
Ry_KF = corrcoef(Py_KF_real, Py_KF_pred);
ccy_KF = Ry_KF(1, 2);