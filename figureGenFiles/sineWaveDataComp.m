%Sinewave comparision to Data. Scatter plot of data on top of waves
%generated from FFT phase and frequency. 

subjAll = [{'OY'},{'CK'},{'MG'},{'SX'},{'ML'},{'LL'},{'LN'},{'EN'},{'NK'}];
numSubj = length(subjAll);

for ii = 1:numSubj
    subj = subjAll{ii};
    path = sprintf('/Users/mhe229/Documents/Landy Lab/Errorclamp Experiment/data/%s',subj);
    for ss = 1:2

        if ss == 1
            load(sprintf('%s/%s_sensorimotor.mat',path,subj));
            
            t = linspace(0,1,240);
            y1 = 10*sin(2*pi*12*t + 0);
            y2 = (rms(endPt)/.707)*sin(2*pi*12*t + deg2rad(thetaReach));
            y3 = (rms(confRepCent)/.707)*sin(2*pi*24*t + deg2rad(thetaConf));

            figure
            sgtitle(['SM - Participant ',num2str(ii)])
            subplot(3,1,1); hold on
            plot(trial,y1)
            scatter(trial,errClamp)
            title('Errorclamp')
            xlabel('trial')
            ylabel('amplitude')

            subplot(3,1,2); hold on
            plot(trial,y2)
            scatter(trial,endPt)
            title('Reach')
            xlabel('trial')
            ylabel('amplitude')

            subplot(3,1,3); hold on
            plot(trial,y3)
            scatter(trial,confRepCent)
            title('Confidence')
            xlabel('trial')
            ylabel('amplitude')
            
        
        
        elseif ss == 2
            load(sprintf('%s/%s_motoraware.mat',path,subj));

            t = linspace(0,1,240);

            y1 = 10*sin(2*pi*12*t + 0);
            y2 = (rms(endPt)/.707)*sin(2*pi*12*t + deg2rad(thetaReach));
            y3 = (rms(report)/.707)*sin(2*pi*12*t + deg2rad(thetaReport));
            y4 = (rms(confRep)/.707)*sin(2*pi*24*t + deg2rad(thetaConf));

            figure
            sgtitle(['MA - Participant ',num2str(ii)])
            subplot(4,1,1); hold on
            plot(trial,y1)
            scatter(trial,errClamp)
            title('Errorclamp')
            xlabel('trial')
            ylabel('amplitude')

            subplot(4,1,2); hold on
            plot(trial,y2)
            scatter(trial,endPt)
            title('Reach')
            xlabel('trial')
            ylabel('amplitude')

            subplot(4,1,3); hold on
            plot(trial,y3)
            scatter(trial,report)
            title('Report')
            xlabel('trial')
            ylabel('amplitude')

            subplot(4,1,4); hold on
            plot(trial,y4)
            scatter(trial,confRepCent)
            title('Confidence')
            xlabel('trial')
            ylabel('amplitude')
        end
    end
end