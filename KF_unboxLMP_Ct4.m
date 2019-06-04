clear;clc;close all;
%%
load('../data/cartesian_states.mat');
load('../data/unbox_LMPs.mat');
%%
states_s = cartesian_states{3};
obsers_s = unbox_LMPs{3};

states = [states_s.Px states_s.Py states_s.Vx states_s.Vy];
obsers = obsers_s.LMP;

%%
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

% plot(Px_KF_real); hold on; plot(Px_linear_real + 10000); hold off;
%% comparison perfomance
plot(Px_KF_real, 'k'); 
hold on; 
plot(Px_KF_pred, 'b'); 
plot(Px_linear_pred, 'm');
hold off;
%%
plot(Py_KF_real, 'k'); 
hold on; 
plot(Py_KF_pred, 'b'); 
plot(Py_linear_pred, 'm');
hold off;