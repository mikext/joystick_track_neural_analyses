clear;clc;close all;
load('../data/raw/fp_joystick.mat');
%%
time_l = size(data, 1);
n_channels = size(data, 2);
n_points = floor(time_l / 167);
%% calculate running average of neural recordings
run_avg = zeros(n_points-1, n_channels);
for ic = 1:n_channels
    chan_rec = data(:, ic);
    for ii = 1:n_points-1
        mid_t = ii * 167;
        start_t = mid_t - 166;
        end_t = mid_t + 166;
        run_avg(ii, ic) = mean(chan_rec(start_t : end_t, :));
    end
end
%% calculate running average of positions
xpos_rec = CursorPosX;
avg_x_pos = zeros(n_points-1, 1);
for ii = 1:n_points-1
    mid_t = ii * 167;
    start_t = mid_t - 166;
    end_t = mid_t + 166;
    avg_x_pos(ii, 1) = mean(xpos_rec(start_t : end_t, :));
end
%% experiments
K = 5;
n_pts = n_points;
before_step = 0;
X_raw = run_avg;
y_raw = avg_x_pos;

[cc_arr, RMSE_arr] = KFlodCV_linearmodel(K, n_pts, before_step, ...
    X_raw, y_raw);

%% function

function [cc_arr, RMSE_arr] = KFlodCV_linearmodel(K, n_pts, before_step, ...
    X_raw, y_raw)


    N = n_pts - 1 - before_step;
    
    N_slice = floor(N/K);
    Folds_Idx = zeros(N_slice * K, 1);
    
    for ss = 1:K
        start_slice = N_slice * (ss - 1) + 1;
        end_slice = N_slice * ss;
        Folds_Idx(start_slice : end_slice, 1) = ss;
    end
    
    cc_arr = zeros(K, 1);
    RMSE_arr = zeros(K, 1);

    for k = 1:K
        train_fold=(Folds_Idx~=k);
        val_fold=(Folds_Idx==k); %% k is validation fold


        X = X_raw(1:end-before_step, :);
        y = y_raw(1+before_step:end, :);


        X_train=X(train_fold, :); X_val=X(val_fold, :);
        y_train=y(train_fold); y_val=y(val_fold);

        % Linear model
        mdl = fitlm(X_train, y_train);
        plotResiduals(mdl)
        y_pred = predict(mdl, X_val);

        RMSE = @(x,y)sqrt(mean((x-y).^2));
        RMSE_val = RMSE(y_val, y_pred);

        R_val = corrcoef(y_val, y_pred);
        cc_val = R_val(1, 2);

        cc_arr(k, 1) = cc_val;
        RMSE_arr(k, 1) = RMSE_val;
    end

    disp(mean(cc_arr));
end