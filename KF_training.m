function [A, Q, C, R] = ...
                KF_training(train_slices, n_trial, n_chan)
%KF_TRAINING train parmaters of Kalman Filter
%   :params: 
%       train_slices: cell array (K-1, 1), every cell is a struct including 
%                       states and observations in this training slice.
%       n_trial: number of slices in train_slices
%       n_chan: number of channels in observations
%   :return: 
%       A(n_states, n_states), 
%       Q(n_states, n_states), 
%       C(n_chan, n_states), 
%       R(n_chan, n_chan) 
%       are parameters of Kalman Filter.
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
    term_1 = zeros(n_chan, 4);
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
    term_1 = zeros(n_chan, n_chan);
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

end

