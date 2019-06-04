clear; clc; close all;
%%
box_LMPandPSD = cell(4, 1);
subs = ["fp", "gf", "rh", "rr"];
for ind = 1:4
    sub = char(subs(ind));
    filepath = ['../data/raw/', sub, '_joystick.mat'];
    load(filepath, 'data');
    features = feature_extract_paper_method_smo(data);
    ss = struct('sub', sub, ...
                'features', features);
    box_LMPandPSD{ind, 1} = ss;
end