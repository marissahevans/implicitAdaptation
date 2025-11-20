%Plotting the trial lags across participants.

subjAll = [{'OY'},{'LL'},{'CK'},{'LN'},{'EN'},{'MH'},{'HL'},{'DT'},{'TC'},{'SX'},{'MG'},{'HP'},{'AS'},{'NK'},{'JH'},{'SH'},{'ML'},{'NM'},{'ET'},{'HH'}];
numSubj = length(subjAll);

sigConfSM = logical(zeros(1,20));
sigConfMA = logical(zeros(1,20));
sigReportMA = logical(zeros(1,20));

reachColor = hex2rgb('#3DE0AE'); %teal
confColor = hex2rgb('#CA49E0'); %pink
reportColor = hex2rgb('#E0B643'); %sand

for ii = 1:numSubj
    subj = subjAll{ii};
    path = sprintf('/Users/mhe229/Documents/Landy Lab/Errorclamp Experiment/publicGitHubRepo/implicitAdaptation/data/%s',subj);
    load(sprintf('%s/%s_confPermute.mat',path,subj));
    for ss = 1:2

        if ss == 1
            load(sprintf('%s/%s_sensorimotor.mat',path,subj));

            lagReachSM(ii) = lagReach;
            lagConfSM(ii) = lagConf;
            reachAmpSM(ii) = rms(endPt)/.707;
            confAmpSM(ii) = (rms(confRep)/.707) - mean(confRep);

            if signifFreq(2) == 1
                sigConfSM(ii) = 1;
            end


        elseif ss == 2
            load(sprintf('%s/%s_motoraware.mat',path,subj));
            reportWin1 = signifFreq;
            load(sprintf('%s/%s_reportPermute.mat',path,subj));
            reportWin2 = signifFreq;

            lagReachMA(ii) = lagReach;
            lagConfMA(ii) = lagConf;
            lagReportMA(ii) = lagReport;

            reachAmpMA(ii) = rms(endPt)/.707;
            confAmpMA(ii) = (rms(confRep)/.707)-mean(confRep);
            reportAmpMA(ii) = rms(report)/.707;

            
            if reportWin2 == 1
                sigReportMA(ii) = 1;
            end

            if reportWin1(1) == 1
                sigConfMA(ii) = 1;
            end

        end
    end
end

figure(1)
plot_gaussian_ellipsoid(mean([lagReachSM',reachAmpSM']),cov([lagReachSM',reachAmpSM']),reachColor)
plot_gaussian_ellipsoid(mean([lagConfSM(sigConfSM)',confAmpSM(sigConfSM)']),cov([lagConfSM(sigConfSM)',confAmpSM(sigConfSM)']),confColor)

scatter(lagReachSM,reachAmpSM,100,reachColor,'filled')

scatter(lagConfSM(sigConfSM),confAmpSM(sigConfSM),100,confColor,'filled')
scatter(lagConfSM(~sigConfSM),confAmpSM(~sigConfSM),100,confColor,'HandleVisibility','off')

for ii = 1:numSubj
text(lagReachSM(ii),reachAmpSM(ii),['  ',num2str(ii)])
text(lagConfSM(ii),confAmpSM(ii),['  ',num2str(ii)])
end

xlabel('trial lag')
ylabel('sine wave amplitude')
legend('Reach','Confidence')
ylim([0 22])
xlim([0 20])
xticks([0 5 10 15 20])
set(gca,'TickDir','out','FontSize',18)
set(gcf,'Color','white','position',[0,0,1000,800])


figure(2)
plot_gaussian_ellipsoid(mean([lagReachMA',reachAmpMA']),cov([lagReachMA',reachAmpMA']),reachColor)
plot_gaussian_ellipsoid(mean([lagConfMA(sigConfMA)',confAmpMA(sigConfMA)']),cov([lagConfMA(sigConfMA)',confAmpMA(sigConfMA)']),confColor)
plot_gaussian_ellipsoid(mean([lagReportMA(sigReportMA)',reportAmpMA(sigReportMA)']),cov([lagReportMA(sigReportMA)',reportAmpMA(sigReportMA)']),reportColor)

scatter(lagReachMA,reachAmpMA,100,reachColor,'filled')

scatter(lagConfMA(sigConfMA),confAmpMA(sigConfMA),100,confColor,'filled')
scatter(lagConfMA(~sigConfMA),confAmpMA(~sigConfMA),100,confColor,'HandleVisibility','off')

scatter(lagReportMA(sigReportMA),reportAmpMA(sigReportMA),100,reportColor,'filled')
scatter(lagReportMA(~sigReportMA),reportAmpMA(~sigReportMA),100,reportColor,'HandleVisibility','off')

for ii = 1:numSubj
text(lagReachMA(ii),reachAmpMA(ii),['  ',num2str(ii)])
text(lagConfMA(ii),confAmpMA(ii),['  ',num2str(ii)])
text(lagReportMA(ii),reportAmpMA(ii),['  ',num2str(ii)])
end

xlabel('trial lag')
ylabel('sine wave amplitude')
legend('Reach','Confidence','Report')
ylim([0 22])
xlim([0 20])
xticks([0 5 10 15 20])
set(gca,'TickDir','out','FontSize',18)
set(gcf,'Color','white','position',[0,0,1000,800])