% This Script calculates Cartesian states(Px, Py, Vx, Vy) of four subjects.
%%
clear;clc;close all;
%% 
cartesian_states = cell(4, 1);
subs = ["fp", "gf", "rh", "rr"];

for ind = 1:4
    sub = char(subs(ind));
    [Px, Py, Vx, Vy] = Cal_Pxy_Vxy(sub);

    ss = struct('sub', sub, ...
                'Px', Px, ...
                'Py', Py, ...
                'Vx', Vx, ...
                'Vy', Vy);

    cartesian_states{ind, 1} = ss;
end
        



