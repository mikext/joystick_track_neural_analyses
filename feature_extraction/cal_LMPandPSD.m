clear; clc; close all;
%%
LMPandPSD = cell(4, 1);
subs = ["fp", "gf", "rh", "rr"];
for ind = 1:4
    sub = char(subs(ind));
    filepath = ['../data/raw/', sub, '_joystick.mat'];
    load(filepath, 'data');
    [feature_smo, feature] = feature_extract_paper_method_smo(data);
    ss = struct('sub', sub, ...
                'feature', feature, ...
                'feature_smo', feature_smo);
    LMPandPSD{ind, 1} = ss;
end

%%
save_fp = '../data/LMPandPSD.mat';
save(save_fp, 'LMPandPSD');