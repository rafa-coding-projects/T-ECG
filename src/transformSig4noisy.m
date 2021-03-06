% transformSig4noisy.m
%
% transformSig4noisy(base_sig, candidate_sig, noisy, T, pk_base,pk_cand) 
%   for ECG signals
%   This functions transforms noisy to base_sig. The reference
%   signal, base_sig and candidate_sig, are verified for each window 
%   within RR peaks. The size of noisy and T are equated to the 
%   size of current window of base_sig and then the trasnformation is done.
% 
% Inputs:
%   base_sig - signal of reference
%   candidate_sig -  Left arm signal used as a reference
%   noisy - signal to be transformed
%   T - transformation signal (generated by genTransform.m)
%   pk_base -  threshold value of RR peaks for base_sig
%   pk_cand -  threshold value of RR peaks for candidate_sig
% Outputs:
%   transformedSig4noisy - Approximation of noisy to base_sig
%
% Date: Apr. 9th, 2020
% Author: Rafael L. da Silva
function transformedSig = transformSig(base_sig, candidate_sig, noisy, T, pk_base,pk_cand)

    [pks_base, locs_base] = findpeaks(base_sig,'MinPeakHeight',pk_base);
    [pks_cand, locs_cand] = findpeaks(candidate_sig,'MinPeakHeight', pk_cand);
    fprintf('Peaks in baseline: %d\n', size(pks_base,1));
    fprintf('Peaks in candidate: %d\n', size(pks_cand,1));
    if length(pks_base) ~= length(pks_cand)
        warning('Signals had different number of peaks detected!!')
        % Use smaller number of peaks as reference
        pks_base = pks_base(1:min(size(pks_base,1),size(pks_cand,1)),1);
        pks_cand = pks_cand(1:min(size(pks_base,1),size(pks_cand,1)),1);
    end   
    transformedSig = zeros(size(base_sig));
    tmpCand = zeros(size(T));
    tmpBase = zeros(size(T));
    tmpT = zeros(size(T));
    sizeT = length(T);
    for k=2:length(pks_base)
        % Baseline window
        baseline = size(base_sig(locs_base(k-1):locs_base(k)),1);
        
        % Resample Noisy signal
        if size(noisy(locs_cand(k-1):locs_cand(k)),1) > baseline
            tmpCand = reduce_signal(noisy(locs_cand(k-1):locs_cand(k)),baseline);
        elseif size(noisy(locs_cand(k-1):locs_cand(k)),1) < baseline
            tmpCand = increase_signal(noisy(locs_cand(k-1):locs_cand(k)),baseline);
        else
            tmpCand = noisy(locs_cand(k-1):locs_cand(k),1);
        end
        % Resample T
        if sizeT > baseline
            tmpT = reduce_signal(T,baseline);
        elseif sizeT < baseline
            tmpT = increase_signal(T,baseline);
        else
            tmpT = T;
        end
        % Transform LA for given window
        transformedSig(locs_base(k-1):locs_base(k),1) = diag(tmpT)*tmpCand;
    end
end

function sig = reduce_signal(sig,baseline)
    % length(sig) > baseline
    sig = resample(sig,baseline,length(sig));
end

function sig = increase_signal(sig,baseline)
    % length(sig) < baseline
    sig = resample(sig,baseline,length(sig));
end