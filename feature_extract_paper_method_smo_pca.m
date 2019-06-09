
function [feature_pca, feature_smo_pca] = feature_extract_paper_method_smo_pca(data)
% extracted feature use the method mentioned in the paper
bin_num = 333;
half_num = 167;
[sz,dim] = size(data);  

K = fix(sz/half_num) - 1; % number of bins

Fs = 1000; % Sampling frequency
T = 1/Fs; % Sampling period
L = length(data); % Length of signal
% t = (0:L-1)*T; % Time Vector
feature = zeros(8, dim, K); % Features: 8 Feature, 64 sensors, K time step
% sum_tmp = 0;

for k = 1:K
    
    min_pos = half_num*(k-1)+1;
    max_pos = min_pos + bin_num -1;
    data_slice = data(min_pos:max_pos,:);
    
    
    data_slice1 = bsxfun(@minus, data_slice, mean(data_slice, 2));
    L = length(data_slice); % Length of signal
    t = (0:L-1)*T; % Time Vector
    fft_x = fft(data_slice1);
    P2 = abs(fft_x/L);
    P1 = P2(1:round(L/2+1),:);
    P1(2:end-1,:) = 2*P1(2:end-1,:);
    
    % Calculate the Power Spectral Density (PSD) of the given signal
    Hpsd = dspdata.psd(P1,'Fs',333);
    
%     freq_tmp = round(Hpsd.Frequencies);
    
    feature(1,:,k) = mean(Hpsd.Data(9:13,:),1);
    feature(2,:,k) = mean(Hpsd.Data(19:25,:),1);
    feature(3,:,k) = mean(Hpsd.Data(36:43,:),1);
    feature(4,:,k) = mean(Hpsd.Data(43:71,:),1);
    feature(5,:,k) = mean(Hpsd.Data(71:101,:),1);
    feature(6,:,k) = mean(Hpsd.Data(101:141,:),1);
    feature(7,:,k) = mean(Hpsd.Data(141:min(191,length((Hpsd.Data))),:),1);

    feature(8,:,k) = mean(data_slice);

  
end

% % plot the feature map
% for m = 1:8
%     figure();
%     imagesc(squeeze(feature(m,:,:)));
%     colorbar;  
% end

for k = 1:K
    min_pos = max(1, k-4);
    max_pos = min(K, k+4);
    feature_smo(:,:,k) = mean(feature(:,:,min_pos:max_pos),3);
    
end

    [h, w, ~]= size(feature_smo);
%   Using the trainging data to generate the projection matrix
    Sample_PCA = reshape(feature_smo,h*w,[]);
    Mean_PCA = mean(Sample_PCA);
    Sample_PCA= bsxfun(@minus, Sample_PCA, Mean_PCA);
    Sample_PCA = normc(Sample_PCA);
%   Obtain Covariance Matrix
    Sample_Cov=cov(Sample_PCA');
%     Sample_Cov(isnan(Sample_Cov)) = 1e-10;
    [E_Vec,E_Val]=eig(Sample_Cov);
    
    E_Vec_Pri = E_Vec(:,end-7:end);
    proj_tmp = Sample_PCA' * E_Vec_Pri ;
    feature_smo_pca = proj_tmp;
   
    
%   Using the trainging data to generate the projection matrix
    Sample_PCA = reshape(feature,h*w,[]);
    Mean_PCA = mean(Sample_PCA);
    Sample_PCA= bsxfun(@minus, Sample_PCA, Mean_PCA);
    Sample_PCA = normc(Sample_PCA);
%   Obtain Covariance Matrix
    Sample_Cov=cov(Sample_PCA');
%     Sample_Cov(isnan(Sample_Cov)) = 1e-10;
    [E_Vec,E_Val]=eig(Sample_Cov);
    
    E_Vec_Pri = E_Vec(:,end-7:end);
    proj_tmp = Sample_PCA' * E_Vec_Pri ;
    feature_pca = proj_tmp;
    
    


end

