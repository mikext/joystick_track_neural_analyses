function pred_states = ...
            KF_predicting(val_slices, A, Q, C, R, Pai, V)
%KF_PREDICTING predict states using observations and paramters of Kalman
%Filter
%   :params:
%       val_slices: cell array (1, 1), every cell is a struct including 
%                       states and observations in this validation slice.
%       A(n_states, n_states), 
%       Q(n_states, n_states), 
%       C(n_chan, n_states), 
%       R(n_chan, n_chan),
%       Pai(n_states, 1),
%       V(n_states, n_states)
%       are parameters of Kalman Filter.
%   :return:
%       pred_states: array of (n_states, n_bin), predicted states by
%                       Kalman Filter.

    obsers = (val_slices{1}.obsers)';
    n_bin = size(obsers, 2);
    n_chan = size(R, 1);

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
        % K = sigma_2 * C.' / (C * sigma_2 * C.' + R);
        K = sigma_2 * C.' / ((C * sigma_2 * C.' + R) + eye(n_chan));
        mu_3 = mu_2 + K * (x_t - C * mu_2);
        sigma_3 = sigma_2 - K * C * sigma_2;

        pred_states(:, tt) = mu_3;
    end
end

