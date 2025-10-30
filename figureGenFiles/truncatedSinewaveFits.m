%Single cycle sinewave fits from FFT frequency and phase values - Figure generator

subjAll = [{'OY'},{'LL'},{'CK'},{'LN'},{'EN'},{'MH'},{'HL'},{'DT'},{'TC'},{'SX'},{'MG'},{'HP'},{'AS'},{'NK'},{'JH'},{'SH'},{'ML'},{'NM'},{'ET'},{'HH'}];
numSubj = length(subjAll);

reachColor = hex2rgb('#CA49E0'); %pink
confColor = hex2rgb('#3DE0AE'); %teal
reportColor = hex2rgb('#E0B643'); %sand

for ii = 1:numSubj
    subj = subjAll{ii};
    path = sprintf('/Users/mhe229/Documents/Landy Lab/Errorclamp Experiment/data/%s',subj);
    load(sprintf('%s/%s_confPermute.mat',path,subj));
    for ss = 2

        if ss == 1
            load(sprintf('%s/%s_sensorimotor.mat',path,subj));

            t = linspace(0,1,100);
            x = 1:100;
            y1 = 10*cos(2*pi*1*t - deg2rad(90));
            y2 = (rms(endPt)/.707)*cos(2*pi*1*t + deg2rad(thetaReach));
            if signifFreq(2) == 1
                y3 = (rms(confRepCent)/.707)*cos(2*pi*2*t + deg2rad(thetaConf));
                minConf = 25+find(y3(25:75)==min(y3(25:75)));
            else
                y3 = (rms(confRepCent)/.707)*cos(2*pi*0*t + deg2rad(thetaConf));
                minConf = 0;
            end

            figure(3);
            sgtitle('Sensorimotor')
            subplot(1,numSubj,ii)
            hold on
            plot(x,y1, 'k')
            plot(x,y2,'Color',reachColor)
            plot(x,y3,'Color',confColor)
            xline(minConf,'--')
            yline(0);
            xline(50);
            xlabel('trial')
            ylabel('direction')
            ylim([-20 20])
            xticks([0 50 100])
            xticklabels({'0','10','20'})
            legend('Errorclamp','Reach','Confidence')
            title(['Participant ', num2str(ii)])

        elseif ss == 2
            load(sprintf('%s/%s_motoraware.mat',path,subj));

            t = linspace(0,1,100);
            x = 1:100;

            y1 = 10*cos(2*pi*1*t - deg2rad(90));
            y2 = (rms(endPt)/.707)*cos(2*pi*1*t + deg2rad(thetaReach));
            y3 = (rms(report)/.707)*cos(2*pi*1*t + deg2rad(thetaReport));
            if signifFreq(1) == 1
                y4 = (rms(confRepCent)/.707)*cos(2*pi*2*t + deg2rad(thetaConf));
                minConf = 25+find(y4(25:75)==min(y4(25:75)));
            else
                y4 = (rms(confRepCent)/.707)*cos(2*pi*0*t + deg2rad(thetaConf));
                minConf = 0;
            end

            figure(4);
            sgtitle('Motor Awareness')
            subplot(1,numSubj,ii)
            hold on
            plot(x,y1,'k')
            plot(x,y2,'Color',reachColor)
            plot(x,y3,'Color',reportColor)
            plot(x,y4,'Color',confColor)
            xline(minConf,'--')
            yline(0);
            xline(50);
            xlabel('trial')
            ylabel('direction')
            ylim([-20 20])
            xticks([0 50 100])
            xticklabels({'0','10','20'})
            legend('Errorclamp','Reach','Report','Confidence')
            title(['Participant ', num2str(ii)])

        end
    end
end