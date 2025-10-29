%Phase on a polar angle plot

subjAll = [{'OY'},{'LL'},{'CK'},{'LN'},{'EN'},{'MH'},{'HL'},{'DT'},{'TC'},{'SX'},{'MG'},{'HP'},{'AS'},{'NK'},{'JH'},{'SH'},{'ML'},{'NM'},{'ET'},{'HH'}];
numSubj = length(subjAll);

for ii = 1:numSubj
    subj = subjAll{ii};
    path = sprintf('/Users/mhe229/Documents/Landy Lab/Errorclamp Experiment/data/%s',subj);
    load(sprintf('%s/%s_confPermute.mat',path,subj));
    for ss = 2%:2

        if ss == 1
            load(sprintf('%s/%s_sensorimotor.mat',path,subj));
            confThetaAllSM(ii) = -thetaConf-90;
            reachThetaAllSM(ii) = -thetaReach-90;

            radClamp = deg2rad(-thetaClamp-90);
            radReach1(ii) = deg2rad(-thetaReach-90);
            fourierWin1(ii) = signifFreq(2);
            radConf1(ii) = deg2rad(-thetaConf-90);

            figure(1)
            polarscatter(radClamp,10,100,[0, 0.4470, 0.7410],'filled');
            hold on
            polarscatter(radReach1(ii),(rms(endPt)/.707),100,[0.4940 0.1840 0.5560],'filled')
            text(radReach1(ii),(rms(endPt)/.707),['  ',num2str(ii)])

            if signifFreq(2) == 1
                polarscatter(radConf1(ii),(rms(confRep)/.707),100,[0.8500 0.3250 0.0980],'filled')
                text(radConf1(ii),(rms(confRep)/.707),['  ',num2str(ii)])
            end

            legend('Error Clamp','Reach','Confidence')
            box off
            set(gca,'TickDir','out','FontSize',18)
            set(gcf,'Color','white','position',[0,0,1200,1200])

        elseif ss == 2
            load(sprintf('%s/%s_motoraware.mat',path,subj));

            confThetaAllMA(ii) = -thetaConf-90;
            reachThetaAllMA(ii) = -thetaReach-90;
            reportThetaAllMA(ii) = -thetaReport-90;

            radClamp = deg2rad(-thetaClamp-90);
            radReach2(ii) = deg2rad(-thetaReach-90);
            radReport(ii) = deg2rad(-thetaReport-90);
            fourierWin2(ii) = signifFreq(1);

            load(sprintf('%s/%s_reportPermute.mat',path,subj));
            reportWin(ii) = signifFreq;
            radConf2(ii) = deg2rad(-thetaConf-90);

            figure(2)
            polarscatter(radClamp,10,100,[0, 0.4470, 0.7410],'filled')
            hold on
            polarscatter(radReach2(ii),(rms(endPt)/.707),100,[0.4940 0.1840 0.5560],'filled')
            text(radReach2(ii),(rms(endPt)/.707),['  ',num2str(ii)])

            if reportWin(ii) == 1
                polarscatter(radReport(ii),(rms(report)/.707),100,[0.4660 0.6740 0.1880],'filled')
                text(radReport(ii),(rms(report)/.707),['  ',num2str(ii)])
            end

            if fourierWin2(ii) == 1
                polarscatter(radConf2(ii),(rms(confRep)/.707),100,[0.8500 0.3250 0.0980],'filled')
                text(radConf2(ii),(rms(confRep)/.707),['  ',num2str(ii)])
            end


            legend('Error Clamp','Reach','Report','Confidence')
            box off
            set(gca,'TickDir','out','FontSize',18)
            set(gcf,'Color','white','position',[0,0,1200,1200])


        end
    end
end

figure(3)
set(gcf,'Color','white')
heatmap(1:20,{'Confidence'},double(fourierWin1),'CellLabelColor','none','FontSize',18)
colormap(sky)
xlabel('Participant')
set(gcf,'Color','white','position',[0,0,1200,105])

figure(4)
set(gcf,'Color','white')
heatmap(1:20,{'Confidence','Report'},double([fourierWin2;reportWin]),'CellLabelColor','none','FontSize',18)
colormap(sky)
xlabel('Participant')
set(gcf,'Color','white','position',[0,0,1200,150])


