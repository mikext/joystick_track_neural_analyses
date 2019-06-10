function [result_Px, result_Py] = ...
    linear_model_with_slices(train_slices, val_slices, n_chan, n_trial, n_bin_slice)
%   train and evaluate linear model on Px and Py using slices data
%   :params:
%       train_slices: cell array (K-1, 1), every cell is a struct including 
%                       states and observations in this training slice.
%       val_slices: cell array (1, 1), every cell is a struct including 
%                       states and observations in this validation slice.
%       n_trial: number of slices in train_slices
%       n_chan: number of channels in observations
%       n_bin_slice = number of bins in a slice
%
%   :return:
%       result_Px: a struct including model, ground true and prediction
%                   value of Px.
%       result_Py: a struct including model, ground true and prediction
%                   value of Py.

    X_train = zeros(n_bin_slice * n_trial, n_chan);
    y_train = zeros(n_bin_slice * n_trial, 4);
    for ff = 1:n_trial
        start_ind = n_bin_slice * (ff - 1) + 1;
        end_ind = n_bin_slice * ff;
        X_train(start_ind:end_ind, :) = train_slices{ff}.obsers;
        y_train(start_ind:end_ind, :) = train_slices{ff}.states;
    end

    X_val = val_slices{1}.obsers;
    y_val = val_slices{1}.states;
    Px_real = y_val(:, 1);
    Py_real = y_val(:, 2);

    mdl_x = fitlm(X_train, y_train(:, 1));
    Px_pred = predict(mdl_x, X_val);

    mdl_y = fitlm(X_train, y_train(:, 2));
    Py_pred = predict(mdl_y, X_val);

    result_Px = struct('model', mdl_x, 'real', Px_real, 'pred', Px_pred);
    result_Py = struct('model', mdl_y, 'real', Py_real, 'pred', Py_pred);
end

