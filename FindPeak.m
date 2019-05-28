function [feature] = FindPeak(data)
% dim(data) = 500*60

Fs = 1000; % Sampling frequency
T = 1/Fs; % Sampling period
L = length(data); % Length of signal
t = (0:L-1)*T; % Time Vector

data = bsxfun(@minus, data, mean(data, 1));
% data = data - mean(data);
fft_x = fft(data);
P2 = abs(fft_x./L);
P1 = P2(1:L/2+1,:);
P1(2:end-1,:) = 2*P1(2:end-1,:);

%%
% % Use the maximum value
% [val, idx] = max(P1);
% % feature = val; % Using 1st value
% 
% feature = idx; % Using 1st index
% P1(bsxfun(@eq, P1, val)) = -Inf;

% [val2, idx2] =  max(P1);
% feature = val2; % Using 2nd value
% feature = idx2; % Using 2nd index

% P1(bsxfun(@eq, P1, val2)) = -Inf;

% [val3, idx3] =  max(P1);

% feature = val3; % Using 2nd value

% feature = idx3; % Using 2nd index

% feature = val2+val; % Using 2nd value

%%
% Adopt PCA to produce features

%   Using the trainging data to generate the projection matrix
    Sample_PCA = P1;
    Mean_PCA = mean(Sample_PCA,2);
    Sample_PCA= bsxfun(@minus, Sample_PCA, Mean_PCA);
%   Obtain Covariance Matrix
    Sample_Cov=cov(Sample_PCA');
%     Sample_Cov(isnan(Sample_Cov)) = 1e-10;
    [E_Vec,E_Val]=eig(Sample_Cov);
    
    E_Vec_Pri = E_Vec(:,end);
    proj_tmp = Sample_PCA' * E_Vec_Pri ;
    feature = reshape(proj_tmp,[],1);

   

end

