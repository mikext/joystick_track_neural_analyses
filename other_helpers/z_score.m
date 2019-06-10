function X_zscore = z_score(X)
% Z_SCORE compute z-score
% input Arg:
% X(#entry, #dim)
% Output Arg:
% X_zscore(#entry, #dim)

    mean_X = mean(X, 1);
    std_X = std(X,0,1);
    mean_mat = repmat(mean_X, size(X, 1), 1);
    std_mat = repmat(std_X, size(X, 1), 1);
    X_zscore = (X - mean_mat) ./ std_mat;
    
end