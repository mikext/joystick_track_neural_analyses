
clear; clc; close all;
%%
for l = 1:4
% Load the data
    switch l
        case 1
            load('fp_joystick.mat');
            feature_fp = feature_extract_paper_method_smo(data);
        case 2
            load('gf_joystick.mat');
            feature_gf = feature_extract_paper_method_smo(data);  
        case 3
            load('rh_joystick.mat');
            feature_rh = feature_extract_paper_method_smo(data);
        case 4
            load('rr_joystick.mat');
            feature_rr = feature_extract_paper_method_smo(data);

    end

end