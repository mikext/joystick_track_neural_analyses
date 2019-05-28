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
%% linear model 5 folds
K = 5;
N = 2231;
Folds_Idx=randi(K,N,1);

k = 1;
train_fold=(Folds_Idx~=k);
valid_fold=(Folds_Idx==k); %% k is validation fold

X = run_avg;
y = avg_x_pos;

X_train=X(train_fold, :); X_valid=X(valid_fold, :);
y_train=y(train_fold); y_valid=y(valid_fold);
%% Linear model
mdl = fitlm(X_train, y_train);
plotResiduals(mdl)
ypred = predict(mdl, X_valid);
RMSE = @(x,y)sqrt(mean((x-y).^2));
RMSE_valid = RMSE(y_valid, ypred);
disp(['RMSE = ', num2str(RMSE_valid)]);
R_val = corrcoef(y_valid, ypred);
cc_val = R_val(1, 2);
disp(['c.c. = ', num2str(cc_val)]);
%% plot true and pred pos
plot(ypred, 'b');
hold on
plot(y_valid, 'r');
hold off