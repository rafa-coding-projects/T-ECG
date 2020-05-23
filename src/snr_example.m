[mpdict,~,~,longs] = wmpdictionary(250,'lstcpt',{{'sym4',3}});
sig = mpdict(:,11);
for i = 1:50
    sig = [sig; mpdict(:,11)];
end
noise = 0.05*rand(size(sig));
noise = noise - mean(noise);
snrTrue = sum(sig.^2)/sum(noise.^2);
snrEst = snr(sig+noise);
disp([snrTrue db2mag(snrEst)]);
figure(1);
plot(sig+noise);