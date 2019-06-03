clear;clc;close all;
%%
unbox_LMPs = cell(4, 1);
subs = ["fp", "gf", "rh", "rr"];

%% calculate running average of neural recordings
for ind = 1:4
    sub = char(subs(ind));
    filepath = ['../data/raw/', sub, '_joystick.mat'];
    load(filepath, 'data');
    
    time_l = size(data, 1);
    n_channels = size(data, 2);
    n_points = floor(time_l / 167);

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

    LMP = run_avg;
    ss = struct('sub', sub, ...
                'LMP', LMP);

    unbox_LMPs{ind, 1} = ss;
end