function [train_slices, val_slices, n_chan, n_trial, n_bin_slice] = ...
                    generate_slices(states, obsers, K, kk)

% split data to train slices and validation slice
%   :param: 
%       states: states in whole experiment, double array (n_bin * n_states)
%       obsers: observations in whole experiment, double array (n_bin * n_chan)
%       K: number of folds in cross validation
%       kk: use kk-th fold in K folds as validation set

%   :return: 
%       train_slices: cell array (K-1, 1), every cell is a struct including 
%                       states and observations in this training slice.
%       val_slices: cell array (1, 1), every cell is a struct including 
%                       states and observations in this validation slice.
%       n_trial: number of slices in train_slices
%       n_chan: number of channels in observations
%       n_bin_slice = number of bins in a slice

    [n_bin, n_chan] = size(obsers);
    n_trial = K - 1;
    n_bin_slice = floor(n_bin/K);

    Folds_Idx = zeros(n_bin_slice * K, 1);
    for ss = 1:K
        start_slice = n_bin_slice * (ss - 1) + 1;
        end_slice = n_bin_slice * ss;
        Folds_Idx(start_slice : end_slice, 1) = ss;
    end

    train_slices = cell(K-1, 1);
    val_slices = cell(1, 1);
    train_count = 0;
    for ss = 1:K
        this_inds = (Folds_Idx==ss);
        slice_s = struct;
        slice_s.states = states(this_inds, :);
        slice_s.obsers = obsers(this_inds, :);
        if ss == kk
            val_slices{1, 1} = slice_s;
        else
            train_count = train_count + 1;
            train_slices{train_count, 1} = slice_s;
        end    
    end

end

