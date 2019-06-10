function [Pai, V] = KF_Pai_V(n_trial, train_slices)
%KF_PAI_V calculate parameters Pai and V in Kalman Filter
%   :params: 
%       train_slices: cell array (K-1, 1), every cell is a struct including 
%                       states and observations in this training slice.
%       n_trial: number of slices in train_slices
%   :return:
%       Pai(n_states, 1),
%       V(n_states, n_states)
%           are parameters of Kalman Filter.
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
end

