clc;clear all;close all;
inputDir = 'D:\Backup Rafael\Documents\NC State\Research Related\ML and DSP\Proj - Assist_paper\';
list_of_signals = ls([inputDir '*csv*']);
% File to go over
keySet = {'LA-BLW-LMS','LA-EM-LMS','LA-MA-LMS','LA-PLI-LMS','LA-W-LMS',...
    'C-BLW-LMS','C-EM-LMS','C-MA-LMS','C-PLI-LMS',...
    'C-PLI-RLS','C-W-LMS','LA-PLI-RLS'};
% Threshold values for RR peak detection
valueSet = [2.85,3.45,3,3.35,2.95,3.6,3.5,3,3.5,4,3.4,3.45];
% Creation of a hashtable
M = containers.Map(keySet,valueSet);
% Results table
results = zeros(size(list_of_signals,1),7);
% Fixed reference variables
signals = readmatrix('C-EM-LMS.csv');
Chest = signals(:,2);
time = signals(:,1);

for k=1:size(list_of_signals,1)
    
    % Select the signal to work with
    signals = readmatrix(strcat(extractBefore(list_of_signals(k,:),"v"),'v'));
    fprintf('--------------------------------------------------\n');
    fprintf('Current file: %s\n',list_of_signals(k,:));
    baseline = signals(:,2);
    signal_denoised = signals(:,6);
    noisy = signals(:,4);
    % Obtain transform between them
    [T2, template] = genTransform(Chest, signal_denoised, ...
        0.96*max(Chest), M(extractBefore(list_of_signals(k,:),".")));
    
    figure;plot(T2);title(['Transform for ' list_of_signals(k,1:end-6)]);
    % Transform denoised signal to baseline
    T2_denoised = transformSig(Chest, signal_denoised, T2,...
        0.96*max(Chest), M(extractBefore(list_of_signals(k,:),".")));
    
    %---------------------------------------------------------------------
    % Plot denoised signal and baseline
    figure;plot(time, Chest);hold on;plot(time, T2_denoised);
    axis([0 5 2.5 5]);
    xlabel('Time (s)');ylabel('Voltage (V)');
    legend('Original chest', 'Transformed signal');
    set(gca,'FontSize',15);
    saveas(gca,strcat(['Match between ' list_of_signals(k,1:end-4) ' and baseline'],'.fig'));
    saveas(gca,strcat(['Match between ' list_of_signals(k,1:end-4) ' and baseline'],'.png'));

    % MSE
    results(k,1) = sum((Chest-T2_denoised).^2)/length(Chest);
    fprintf('MSE: %.4f\n', results(k,1));
    %{
    % Clean signal (baseline)
    results(k,2) = snr(baseline);
    fprintf('SNR to baseline (before): %.4f\n', results(k,2));
    % Clean ECG
    % Transformed denoised
    results(k,3) = snr(T2_denoised);
    fprintf('SNR of T_denoised (After): %.4f\n', snr(T2_denoised));
    % Noisy signal
    results(k,4) = snr(noisy);
    fprintf('SNR to %s: %.4f\n', list_of_signals(k,:), results(k,4));
    %}
    % SNR2 Baseline
    if list_of_signals(k,1:1) == 'C'
        results(k,5) = custom_snr(template,baseline, 0.96*max(baseline));
    else
        % Obtain transform between them
        [T3, template3] = genTransform(Chest, baseline, ...
        0.96*max(Chest), 3.4);
        % Transform LA clean signal signal to Chest
        T3_baseline = transformSig(Chest, baseline, T3,...
        0.96*max(Chest), 3.4);
        results(k,5) = custom_snr(template,T3_baseline, 0.96*max(T3_baseline));
    end
    fprintf('Custom SNR (before): %.4f\n', results(k,5));
    % SNR2 T_denoised
    results(k,6) = custom_snr(template,T2_denoised, M(extractBefore(...
        list_of_signals(k,:),".")));
    fprintf('Custom SNR (After): %.4f\n', results(k,6));
    % SNR of noisy signals
    if list_of_signals(k,1:1) == 'C'
        results(k,7) = custom_snr4noisy(template,baseline, ...
        0.96*max(baseline),noisy);
    else
        % Transform noisy signal to baseline
        [T3, template3] = genTransform4noisy(Chest, baseline, noisy, ...
        0.96*max(Chest), 3.4);
        T3_noisy = transformSig4noisy(Chest, baseline, noisy, T3,...
        0.96*max(Chest),3.4);
        results(k,7) = custom_snr4noisy(template,Chest, ...
        0.96*max(Chest),T3_noisy);
    end
    fprintf('Custom SNR to %s: %.4f\n',list_of_signals(k,:),results(k,7));
    title(['Match between ' list_of_signals(k,1:end-6) ' and baseline']);
    
    %close all;
end
ECGsig = ECGgenerator(25, [75 81],signal_denoised, T2,...
    M(extractBefore(list_of_signals(k,:),".")));
interval = size(ECGsig,1)*0.01/size(ECGsig,1);
figure;plot(0:interval:size(ECGsig,1)*0.01-interval,ECGsig);
axis([0 5 2.5 5]);
xlabel('Time (s)');ylabel('Voltage (V)');
set(gca,'FontSize',15);
writematrix(results,'Auxiliary files/results.csv');
saveas(gca,'generatedsignal.png');
saveas(gca,'generatedsignal.fig');
