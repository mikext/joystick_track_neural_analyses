%%
% May.25th 2019 Group Project for ECE 209
% Code written by Yudi Wang
% Data Preprocessing
%%
% Load the data
clear; clc; close all;
load('rh_joystick.mat');

%%
% Example ECoG time course for Subject C.
clear; clc; close all;
load('rh_joystick.mat');

figure();
hold on;

for cnt = 21:40
        plot(data(1:60000, cnt)+(40-cnt)*3e4, 'k');
end

plot(CursorPosX(1:60000)-1*5e4,'g','LineWidth',1);
plot(TargetPosX(1:60000)-2*5e4,'g');
plot(CursorPosY(1:60000)-3*5e4,'r','LineWidth',1);
plot(TargetPosY(1:60000)-4*5e4,'r');

set(gca,'XTickLabel',0:10:60);
set(gca,'ytick',[])
set(gcf, 'position', [0 0 600 4000]);
ylabel('Normailized Amplitude');
xlabel('TIME(s)');
title(['TIME vs. Normailized Amplitude']);

%%
% % % Plot the frequency of the circle activity
% % 
% PlotFreq(CursorPosX);
% PlotFreq(CursorPosY);
% PlotFreq(TargetPosX);
% PlotFreq(TargetPosY);

%%
% % when sampling frequency is 2Hz
% 
% bin_num = 500;
% [sz,dim] = size(data);  
% K = fix(sz/bin_num);
% 
% feature = zeros(K, dim);
% % for each bins, do fft
% for k = 1 : K
%     min_pos = bin_num*(k-1)+1;
%     max_pos = bin_num*k;
%     data_slice = data(min_pos:max_pos,:);
%     feature(k, :) = FindPeak(data_slice);
% 
% end
% 
% figure();
% imagesc(feature);
% colorbar;  

%%
% Implement of the paper mentioned method

bin_num = 333;
half_num = 166;
[sz,dim] = size(data);  
K = 2 * fix(sz/bin_num) - 1; % number of bins
feature = zeros(K, dim);

for k = 2
    min_pos = half_num*(k-1)+1;
    max_pos = min_pos + bin_num -1;
    data_slice = data(min_pos:max_pos,:);
    data_slice1 = bsxfun(@minus, data_slice, mean(data_slice, 2));
end
