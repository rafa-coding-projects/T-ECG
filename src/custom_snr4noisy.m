% custom_snr.m
%
% custom_snr(template, sig, pk_sig, noisy) for ECG signals
%   Computes the SNR of noisy related to the given template, it uses sig as
%   the reference to find the where the RR peaks should be in the noisy
%   signal.
% 
% Inputs:
%   template - signal of reference
%   sig -  signal to be transformed
%   pk_sig - signal threshold
%   noisy - corrupted version of sig
%
% Outputs:
%   SNR - custom version of SNR
%
% Date: Apr. 3rd, 2020
% Author: Rafael L. da Silva
function SNR = custom_snr4noisy(template, sig, pk_sig, noisy)

    [pks_cand, locs_cand] = findpeaks(sig,'MinPeakHeight', pk_sig);
    % Initilization
    P_noise = 0;
    tmpSig = zeros(size(sig));
    % Baseline window
    baseline = size(template,1);
    noisy = sig - noisy;
    
    for k=2:length(pks_cand)
        
        % Resample Signal
        if size(noisy(locs_cand(k-1):locs_cand(k)),1) > baseline
            tmpSig = reduce_signal(noisy(locs_cand(k-1):locs_cand(k)),baseline);
        elseif size(noisy(locs_cand(k-1):locs_cand(k)),1) < baseline
            tmpSig = increase_signal(noisy(locs_cand(k-1):locs_cand(k)),baseline);
        else
            tmpSig = noisy(locs_cand(k-1):locs_cand(k),1);
        end
        
        % Calculate power of estimated noise
        P_noise = P_noise + sum(tmpSig-template).^2/(length(pks_cand)+1);
    end
    % Estimated power of signal
    P_signal = sum(template.^2);
    SNR = 10*log10(P_signal/P_noise);
end

function sig = reduce_signal(sig,baseline)
    % length(sig) > baseline
    sig = resample(sig,baseline,length(sig));
end

function sig = increase_signal(sig,baseline)
    % length(sig) < baseline
    sig = resample(sig,baseline,length(sig));
end
        