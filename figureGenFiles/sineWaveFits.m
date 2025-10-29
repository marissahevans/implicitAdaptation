%Sinewave fits from FFT frequency and phase values - Figure generator

subjAll = [{'OY'},{'LL'},{'CK'},{'LN'},{'EN'},{'MH'},{'HL'},{'DT'},{'TC'},{'SX'},{'MG'},{'HP'},{'AS'},{'NK'},{'JH'},{'SH'},{'ML'},{'NM'},{'ET'},{'HH'}];
numSubj = length(subjAll);

for ii = 1:numSubj
    subj = subjAll{ii};
    path = sprintf('/Users/mhe229/Documents/Landy Lab/Errorclamp Experiment/data/%s',subj);
    for ss = 1:2

        if ss == 1
            load(sprintf('%s/%s_sensorimotor.mat',path,subj));

            t = linspace(0,1,240);
            y1 = 10*cos(2*pi*12*t - 90);
            y2 = (rms(endPt)/.707)*cos(2*pi*12*t - deg2rad(thetaReach));
            y3 = (rms(confRepCent)/.707)*cos(2*pi*24*t - deg2rad(thetaConf));

            figure(1);
            sgtitle('Sensorimotor')
            subplot(numSubj,1,ii)
            hold on
            plot(trial,y1)
            plot(trial,y2)
            plot(trial,y3,'Color',[0.4940 0.1840 0.5560])
            yline(0);
            xlabel('trial')
            ylabel('direction')
            legend('Errorclamp','Reach','Confidence')
            title(['Participant ', num2str(ii)])

        elseif ss == 2
            load(sprintf('%s/%s_motoraware.mat',path,subj));

            t = linspace(0,1,240);

            y1 = 10*cos(2*pi*12*t - 90);
            y2 = (rms(endPt)/.707)*cos(2*pi*12*t - deg2rad(thetaReach));
            y3 = (rms(report)/.707)*cos(2*pi*12*t - deg2rad(thetaReport));
            y4 = (rms(confRepCent)/.707)*cos(2*pi*24*t - deg2rad(thetaConf));

            figure(2);
            sgtitle('Motor Awareness')
            subplot(numSubj,1,ii)
            hold on
            plot(trial,y1)
            plot(trial,y2)
            plot(trial,y3)
            plot(trial,y4)
            yline(0);
            xlabel('trial')
            ylabel('direction')
            legend('Errorclamp','Reach','Report','Confidence')
            title(['Participant ', num2str(ii)])

        end
    end
end