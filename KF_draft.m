clear;clc;close all;
%%
load('../data/cartesian_states.mat');
load('../data/unbox_LMPs.mat');
%% use first subject's data
states_s = cartesian_states{2};
obsers_s = unbox_LMPs{2};

states = [states_s.Px states_s.Py states_s.Vx states_s.Vy];
obsers = obsers_s.LMP;
%% split data to train slices and test slice
[N_bin, N_chan] = size(obsers);
K = 5;
kk = 5;
n_trial = K - 1;
N_bin_slice = floor(N_bin/K);

Folds_Idx = zeros(N_bin_slice * K, 1);
for ss = 1:K
    start_slice = N_bin_slice * (ss - 1) + 1;
    end_slice = N_bin_slice * ss;
    Folds_Idx(start_slice : end_slice, 1) = ss;
end

train_slices = cell(K-1, 1);
test_slices = cell(1, 1);
train_count = 0;
for ss = 1:K
    this_inds = (Folds_Idx==ss);
    slice_s = struct;
    slice_s.states = states(this_inds, :);
    slice_s.obsers = obsers(this_inds, :);
    if ss == kk
        test_slices{1, 1} = slice_s;
    else
        train_count = train_count + 1;
        train_slices{train_count, 1} = slice_s;
    end    
end

%% train and test a linear model
X_train = zeros(N_bin_slice * n_trial, N_chan);
y_train = zeros(N_bin_slice * n_trial, 4);
for ff = 1:n_trial
    start_ind = N_bin_slice * (ff - 1) + 1;
    end_ind = N_bin_slice * ff;
    X_train(start_ind:end_ind, :) = train_slices{ff}.obsers;
    y_train(start_ind:end_ind, :) = train_slices{ff}.states;
end
X_val = test_slices{1}.obsers;
y_val = test_slices{1}.states;

% Linear model
mdl_x = fitlm(X_train, y_train(:, 1));
y_pred_x = predict(mdl_x, X_val);

mdl_y = fitlm(X_train, y_train(:, 2));
y_pred_y = predict(mdl_y, X_val);

Px_linear_real = y_val(:, 1);
Px_linear_pred = y_pred_x;
%% train parmaters of Kalman Filter
%% calculate A
term_1 = zeros(4, 4);
term_2 = zeros(4, 4);
for i_trial = 1:n_trial
    states = (train_slices{i_trial}.states)';
    n_bin = size(states, 2);
    % sum from 2 to T
    for i_bin = 2:n_bin
        z_t = states(:, i_bin);
        z_t_1 = states(:, i_bin - 1);
        term_1 = term_1 + z_t * (z_t_1).';
        term_2 = term_2 + z_t_1 * (z_t_1).';
    end
end
% A = term_1 * inv(term_2);
A = term_1 / term_2;

%% calculate Q
% numerator
term_1 = zeros(4, 4);
for i_trial = 1:n_trial
        states = (train_slices{i_trial}.states)';
        n_bin = size(states, 2);
        % sum from 2 to T
        for i_bin = 2:n_bin
            z_t = states(:, i_bin);
            z_t_1 = states(:, i_bin - 1);
            diff = z_t - A * z_t_1;
            term_1 = term_1 + diff * diff.';
        end
end
% denominator
term_2 = 0;
for i_trial = 1:n_trial
        states = (train_slices{i_trial}.states)';
        n_bin = size(states, 2);
        term_2 = term_2 + (n_bin - 1);
end
% get Q
Q = term_1 ./ term_2;

%% Print A and Q
format short
disp('A=');
disp(A);
disp('Q=');
disp(Q);

%% calculate C
term_1 = zeros(N_chan, 4);
term_2 = zeros(4, 4);
for i_trial = 1:n_trial
    states = (train_slices{i_trial}.states)';
    obsers = (train_slices{i_trial}.obsers)';
    n_bin = size(states, 2);
    % sum from 1 to T
    for i_bin = 1:n_bin
        z_t = states(:, i_bin);
        x_t = obsers(:, i_bin);
        term_1 = term_1 + x_t * (z_t).';
        term_2 = term_2 + z_t * (z_t).';
    end
end
% C = term_1 * inv(term_2);
C = term_1 / term_2;

%% calculate R
% numerator
term_1 = zeros(N_chan, N_chan);
for i_trial = 1:n_trial
    states = (train_slices{i_trial}.states)';
    obsers = (train_slices{i_trial}.obsers)';
    n_bin = size(states, 2);
    % sum from 1 to T
    for i_bin = 1:n_bin
        z_t = states(:, i_bin);
        x_t = obsers(:, i_bin);
        diff = x_t - C * z_t;
        term_1 = term_1 + diff * diff.';
    end
end
% denominator
term_2 = 0;
for i_trial = 1:n_trial
    states = (train_slices{i_trial}.states)';
    n_bin = size(states, 2);
    term_2 = term_2 + n_bin;
end
% get R
R = term_1 ./ term_2;
%% calculate Pai
% numerator
term_1 = zeros(4, 1);
for i_trial = 1:n_trial
    states = (train_slices{i_trial}.states)';
    term_1 = term_1 + states(:, 1);
end
% denominator
term_2 = n_trial;
% get Pai
Pai = term_1 ./ term_2;

%% calculate V
% numerator
term_1 = zeros(4, 4);
for i_trial = 1:n_trial
    states = (train_slices{i_trial}.states)';
    z_1 = states(:, 1);
    diff = z_1 - Pai;
    term_1 = term_1 + diff * diff.';
end
% denominator
term_2 = n_trial;
% get V
V = term_1 ./ term_2;
%% Evaluate model on test set
states = (test_slices{1}.states)';
obsers = (test_slices{1}.obsers)';
n_bin = size(obsers, 2);

pred_states = zeros(4, n_bin);
pred_states(:, 1) = Pai;

mu_0 = Pai;
sigma_0 = V;

% iterative updates

for tt = 2:n_bin
    x_t = obsers(:, tt);

    if tt == 2
        mu_1 = mu_0;
        sigma_1 = sigma_0;
    else
        mu_1 = mu_3;
        sigma_1 = sigma_3;
    end

    mu_2 = A * mu_1;
    sigma_2 = A * sigma_1 * A.' + Q;
    K = sigma_2 * C.' / (C * sigma_2 * C.' + R);
    mu_3 = mu_2 + K * (x_t - C * mu_2);
    sigma_3 = sigma_2 - K * C * sigma_2;

    pred_states(:, tt) = mu_3;
end
%%
Px_KF_pred = pred_states(1, :);
Px_KF_real = states(1, :);

%%
plot(Px_KF_real); hold on; plot(Px_linear_real + 10000); hold off;

%% comparison
plot(Px_KF_real, 'k'); 
hold on; 
plot(Px_KF_pred, 'b'); 
plot(Px_linear_pred, 'm');
hold off;