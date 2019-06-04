
clear; clc; close all;
%%
for l = 1 : 4
% Load the data
    switch l
        case 1
            load('fp_joystick.mat');
            [feature_fp_pca, feature_fp_smo_pca] = feature_extract_paper_method_smo_pca(data);
        case 2
            load('gf_joystick.mat');
            [feature_gf_pca, feature_gf_smo_pca] = feature_extract_paper_method_smo_pca(data);  
        case 3
            load('rh_joystick.mat');
            [feature_rh_pca, feature_rh_smo_pca] = feature_extract_paper_method_smo_pca(data);
        case 4
            load('rr_joystick.mat');
            [feature_rr_pca, feature_rr_smo_pca] = feature_extract_paper_method_smo_pca(data);

    end

end