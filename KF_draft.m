clear;clc;close all;
%%
load('../data/cartesian_states.mat');
load('../data/unbox_LMPs.mat');
%% use first subject's data
states_s = cartesian_states{1};
obsers_s = unbox_LMPs{1};

states = [states_s.Px states_s.Py states_s.Vx states_s.Vy];
obsers = obsers_s.LMP;
%% split data to train slices and test slice
[N_bin, N_chan] = size(obsers);
K = 5;
kk = 1;
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

%% Evaluate model on test set