% genTransform.m
%
% This functions finds a transformation signal, transformedSig, that
% transforms candidate_sig to base_sig. The signal transformedSig can be
% used as a transformation matrix by doing "diag(transformedSig)". The
% transformation can be done by "diag(transformedSig)*candidate_sig".
% 
% Inputs:
%   base_sig - signal of reference
%   candidate_sig -  signal to be transformed
% Outputs:
%   T - Transformation signal
%   tmpBase_sum - Template for baseline signal, (it can be used for SNR)
% Date: Mar. 31st, 2020
% Author: Rafael L. da Silva
function [T, tmpBase_sum] = genTransform(base_sig, candidate_sig,pk_base,pk_cand)
    
    [pks_base, locs_base] = findpeaks(base_sig,'MinPeakHeight',pk_base);
    [pks_cand, locs_cand] = findpeaks(candidate_sig,'MinPeakHeight',pk_cand);
    fprintf('Peaks in baseline: %d\n', size(pks_base,1));
    fprintf('Peaks in candidate: %d\n', size(pks_cand,1));
    if length(pks_base) ~= length(pks_cand)
        warning('Signals had different number of peaks detected!!');
        % Use smaller number of peaks as reference
        pks_base = pks_base(1:min(size(pks_base,1),size(pks_cand,1)),1);
        pks_cand = pks_cand(1:min(size(pks_base,1),size(pks_cand,1)),1);
    end
    tmpBase = [];
    tmpCand = [];
    % Calculate the average of interval for the given Chest signal
    avg = ceil(mean(diff(locs_base)));
    fprintf('Average size of windows: %.d, Std: %.4f\n',avg, std(diff(locs_base)));
    tmpBase_sum = zeros(avg,1);
    tmpCand_sum = zeros(avg,1);
    normalization = 0;
    for k=2:length(pks_base)
        % Check Chest first
        if size(base_sig(locs_base(k-1):locs_base(k)),1) > avg
            tmpBase = resample(base_sig(locs_base(k-1):locs_base(k)), avg,...
                size(base_sig(locs_base(k-1):locs_base(k)),1));
        elseif size(base_sig(locs_base(k-1):locs_base(k)),1) < avg
            tmpBase = resample(base_sig(locs_base(k-1):locs_base(k)), avg,...
                size(base_sig(locs_base(k-1):locs_base(k)),1));
        else
            tmpBase = base_sig(locs_base(k-1):locs_base(k));
        end
        % Now check LA
        if size(candidate_sig(locs_cand(k-1):locs_cand(k)),1) > avg
            tmpCand = resample(candidate_sig(locs_cand(k-1):locs_cand(k)), avg,...
                size(candidate_sig(locs_cand(k-1):locs_cand(k)),1));
        elseif size(candidate_sig(locs_cand(k-1):locs_cand(k)),1) < avg
            tmpCand = resample(candidate_sig(locs_cand(k-1):locs_cand(k)), avg, ...
                size(candidate_sig(locs_cand(k-1):locs_cand(k)),1));
        else
            tmpCand = candidate_sig(locs_cand(k-1):locs_cand(k));
        end
        tmpBase_sum = tmpBase_sum + tmpBase;
        tmpCand_sum = tmpCand_sum + tmpCand;
        
        normalization = normalization + 1;
    end
    tmpBase_sum = tmpBase_sum./(normalization+1);
    T = tmpBase_sum./(tmpCand_sum./(normalization+1));
end