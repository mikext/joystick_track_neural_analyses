%%
% May.25th 2019 Group Project for ECE 209
% Code written by Yudi Wang
% Data Preprocessing
%%
% Load the data
clear; clc; close all;
load('fp_joystick.mat');

% % Plot the frequency of the circle activity
% 
% PlotFreq(CursorPosX);
% PlotFreq(CursorPosY);
% PlotFreq(TargetPosX);
% PlotFreq(TargetPosY);

%%
% when sampling frequency is 2Hz

bin_num = 500;
[sz,dim] = size(data);  
K = fix(sz/bin_num);

feature = zeros(K, dim*2);
% for each bins, do fft
for k = 1 : K
    min_pos = bin_num*(k-1)+1;
    max_pos = bin_num*k;
    data_slice = data(min_pos:max_pos,:);
    feature(k, :) = FindPeak(data_slice);

end

figure();
imagesc(feature);
colorbar;  

