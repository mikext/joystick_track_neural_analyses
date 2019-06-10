clear;clc;close all;
%%
load('../data/cartesian_states.mat');
load('../data/LMPandPSD.mat');
%% parameters
i_sub = 4;
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

%% 5-fold CV
K = 5;

ccx_arr_li = zeros(K, 1);
ccx_arr_kf = zeros(K, 1);

ccy_arr_li = zeros(K, 1);
ccy_arr_kf = zeros(K, 1);

for kk = 1:K
    %% generate slices

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
        validation_states = (val_slices{1}.states)';
        Pai = validation_states(:, 1);
        V = zeros(4, 4);
    else
        [Pai, V] = KF_Pai_V(n_trial, train_slices);
    end
    %% functions below
    pred_states = ...
                KF_predicting(val_slices, A, Q, C, R, Pai, V);
    %% verify two ground true
    validation_states = (val_slices{1}.states)';

    Px_linear_real = result_Px.real;
    Px_linear_pred = result_Px.pred;
    Px_KF_pred = pred_states(1, :);
    Px_KF_real = validation_states(1, :);

    Py_linear_real = result_Py.real;
    Py_linear_pred = result_Py.pred;
    Py_KF_pred = pred_states(2, :);
    Py_KF_real = validation_states(2, :);

    %%
    Rx_linear = corrcoef(Px_linear_real, Px_linear_pred);
    ccx_linear = Rx_linear(1, 2);
    Rx_KF = corrcoef(Px_KF_real, Px_KF_pred);
    ccx_KF = Rx_KF(1, 2);

    Ry_linear = corrcoef(Py_linear_real, Py_linear_pred);
    ccy_linear = Ry_linear(1, 2);
    Ry_KF = corrcoef(Py_KF_real, Py_KF_pred);
    ccy_KF = Ry_KF(1, 2);
    
    %%
    ccx_arr_li(kk, 1) = ccx_linear;
    ccx_arr_kf(kk, 1) = ccx_KF;

    ccy_arr_li(kk, 1) = ccy_linear;
    ccy_arr_kf(kk, 1) = ccy_KF;
end

mean_ccx_li = mean(ccx_arr_li);
mean_ccx_kf = mean(ccx_arr_kf);

mean_ccy_li = mean(ccy_arr_li);
mean_ccy_kf = mean(ccy_arr_kf);