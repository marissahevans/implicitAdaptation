%Phase comparisons

subjAll = [{'OY'},{'LL'},{'CK'},{'LN'},{'EN'},{'MH'},{'HL'},{'DT'},{'TC'},{'SX'},{'MG'},{'HP'},{'AS'},{'NK'},{'JH'},{'SH'},{'ML'},{'NM'},{'ET'},{'HH'}];
numSubj = length(subjAll);

for ii = 1:numSubj
    subj = subjAll{ii};
    path = sprintf('/Users/mhe229/Documents/Landy Lab/Errorclamp Experiment/data/%s',subj);
    load(sprintf('%s/%s_reportPermute.mat',path,subj));
    reportWin(ii) = signifFreq;
    load(sprintf('%s/%s_confPermute.mat',path,subj));
    for ss = 1:2

        if ss == 1
            load(sprintf('%s/%s_sensorimotor.mat',path,subj));
            load(sprintf('%s/%s_sigmaFit.mat',path,subj));
            sigPmarg1(ii) = sigPmarg;

            reachAmpSM(ii) = rms(endPt)/.707;

            % %reach vs conf
            % figure(1)
            % subplot(2,3,1); hold on
            % if signifFreq(2) == 1
            %     scatter(-thetaReach-90,-thetaConf-90,80,'filled')
            %     text(-thetaReach-90,-thetaConf-90,['  ',num2str(ii)])
            % else
            %     scatter(-thetaReach-90,0,80,'filled')
            %     text(-thetaReach-90,0,['  ',num2str(ii)])
            % end
            % xlabel('reach phase')
            % ylabel('conf phase')
            % title('sensorimotor')
            % axis([180 250 0 150])
            % grid on
            % box off
            % set(gca,'TickDir','out','FontSize',18)
            % set(gcf,'Color','white')

            figure(1)
            subplot(1,3,1); hold on
            if signifFreq(2) == 1
                scatter(-thetaConf-90,sigPmarg,80,'k','filled')
                text(-thetaConf-90,sigPmarg,['  ',num2str(ii)],'FontSize',12)
            end
            xlabel('confidence phase')
            ylabel('proprioceptive uncertainty')
            title('sensorimotor')
            axis([0 150 0 20])
            confAllSM(ii) = -thetaConf-90;
            sigFreqSM(ii) = signifFreq(2);
            reachesAllSM(ii) = -thetaReach-90;
            grid on
            box off
            set(gca,'TickDir','out','FontSize',18)

            % figure(3); hold on
            % if signifFreq(2) == 1
            % scatter3(-thetaReach-90,-thetaConf-90,sigPmarg)
            % else
            %     scatter3(-thetaReach-90,0,sigPmarg)
            % end
            % %text3(-thetaReach-90,-thetaConf-90,-thetaReport-90,['  ',num2str(ii)])
            % xlabel('reach')
            % ylabel('conf')
            % zlabel('sigma p')
            % title('sensorimotor')
            % grid on


        elseif ss == 2
            load(sprintf('%s/%s_motoraware.mat',path,subj));
            load(sprintf('%s/%s_sigmaFit.mat',path,subj));

            reachAmpMA(ii) = rms(endPt)/.707;

            %reach vs conf
            % figure(1)
            % subplot(2,3,6); hold on
            % if signifFreq(1) == 1
            %     scatter(-thetaReach-90,-thetaConf-90,80,'filled')
            %     text(-thetaReach-90,-thetaConf-90,['  ',num2str(ii)])
            % else
            %     scatter(-thetaReach-90,0,80,'filled')
            %     text(-thetaReach-90,0,['  ',num2str(ii)])
            % end
            % 
            % xlabel('reach phase')
            % ylabel('conf phase')
            % title('motor aware')
            % axis([180 250 0 150])
            % grid on
            % set(gca,'TickDir','out','FontSize',18)

            %report vs conf
            % figure(1)
            % subplot(2,3,4); hold on
            % if signifFreq(1) == 1
            %     scatter(-thetaReport-90,-thetaConf-90,80,'filled')
            %     text(-thetaReport-90,-thetaConf-90,['  ',num2str(ii)])
            % else
            %     scatter(-thetaReport-90,0,80,'filled')
            %     text(-thetaReport-90,0,['  ',num2str(ii)])
            % end
            % xlabel('report phase')
            % ylabel('conf phase')
            % title('motor aware')
            % %axis([0 200 0 150])
            % grid on
            % set(gca,'TickDir','out','FontSize',18)

            %report vs reach
            % figure(1)
            % subplot(2,3,5); hold on
            % scatter(-thetaReport-90,-thetaReach-90,80,'filled')
            % text(-thetaReport-90,-thetaReach-90,['  ',num2str(ii)])
            % xlabel('report phase')
            % ylabel('reach phase')
            % title('motor aware')
            % %axis([0 200 180 250])
            % grid on
            % set(gca,'TickDir','out','FontSize',18)
             

            figure(1)
            subplot(1,3,2); hold on
            if reportWin(ii) == 1
                if -thetaReport-90 > 0
                    scatter(-thetaReport-90,sigPmarg,80,'k','filled')
                    text(-thetaReport-90,sigPmarg,['  ',num2str(ii)],'FontSize',12)
                    reportAllMA(ii) = -thetaReport-90;
                else
                    scatter(360+(-thetaReport-90),sigPmarg,80,'k','filled')
                    text(360+(-thetaReport-90),sigPmarg,['  ',num2str(ii)],'FontSize',12)
                    reportAllMA(ii) = 360+(-thetaReport-90);
                end
            end
            xlabel('report phase')
            %ylabel('proprioceptive uncertainty')
            title('motor aware')
            axis([0 360 0 20])
            grid on
            box off
            set(gca,'TickDir','out','FontSize',18)

            figure(1)
            subplot(1,3,3); hold on
            if signifFreq(1) == 1
                scatter(-thetaConf-90,sigPmarg,80,'k','filled')
                text(-thetaConf-90,sigPmarg,['  ',num2str(ii)],'FontSize',12)
            end
            xlabel('confidence phase')
            %ylabel('proprioceptive uncertainty')
            title('motor aware')
            axis([0 150 0 20])
            grid on
            box off
            set(gca,'TickDir','out','FontSize',18)
            set(gcf,'Color','white','position',[0,0,1600,800])

            sigFreqMA(ii) = signifFreq(1);
            confAllMA(ii) = -thetaConf-90;
            reachesAllMA(ii) = -thetaReach;

            

            % figure(2); hold on
            % scatter3(-thetaReach-90,sigPmarg,-thetaReport-90)
            % %text3(-thetaReach-90,-thetaConf-90,-thetaReport-90,['  ',num2str(ii)])
            % xlabel('reach')
            % ylabel('sigma p')
            % zlabel('report')
            % title('motor aware')
            % grid on



        end
    end
end

y = temp';
x = confAllMA';

X = [ones(length(x),1) x];
b = X\y;
yCalc = X*b;
rSqr = 1 - sum((y - yCalc).^2)/sum((y - mean(y)).^2);
[~,~,~,~,stats] = regress(y,X);
stats(3)

figure; hold on
scatter(x,y)
plot(x,yCalc,'r','LineWidth',2)
if stats(3) <.05
    title(['sensorimotor, R sqr =' num2str(rSqr),'*'])
else
    title(['sensorimotor, R sqr =' num2str(rSqr)])
end

%Sensory Motor
y = sigPmarg1(sigFreqSM)';
x = confAllSM(sigFreqSM)';

X = [ones(length(x),1) x];
b = X\y;
yCalc = X*b;
rSqr = 1 - sum((y - yCalc).^2)/sum((y - mean(y)).^2);
[~,~,~,~,stats] = regress(y,X);
stats(3)

figure(1)
subplot(1,3,1)
plot(x,yCalc,'r','LineWidth',2)
if stats(3) <.05
    title(['sensorimotor, R sqr =' num2str(rSqr),'*'])
else
    title(['sensorimotor, R sqr =' num2str(rSqr)])
end

%Motor Aware
y = sigPmarg1(sigFreqMA)';
x = confAllMA(sigFreqMA)';

X = [ones(length(x),1) x];
b = X\y;
yCalc = X*b;
rSqr = 1 - sum((y - yCalc).^2)/sum((y - mean(y)).^2);
[~,~,~,~,stats] = regress(y,X);
stats(3)

figure(1)
subplot(1,3,3)
plot(x,yCalc,'r','LineWidth',2)
if stats(3) <.05
    title(['motor aware, R sqr =' num2str(rSqr),'*'])
else
    title(['motor aware, R sqr =' num2str(rSqr)])
end

y = sigPmarg1(reportWin)';
x = reportAllMA(reportWin)';

X = [ones(length(x),1) x];
b = X\y;
yCalc = X*b;
rSqr = 1 - sum((y - yCalc).^2)/sum((y - mean(y)).^2);
[~,~,~,~,stats] = regress(y,X);
stats(3)

figure(1)
subplot(1,3,2); hold on
plot(x,yCalc,'r','LineWidth',2)
if stats(3) <.05
    title(['motor aware, R sqr =' num2str(rSqr),'*'])
else
    title(['motor aware, R sqr =' num2str(rSqr)])
end




%%
figure
subplot(1,2,1)
scatter(reachAmpSM,sigPmarg1,80,'filled')
text(reachAmpSM,sigPmarg1,[{' 1'},{' 2'},{' 3'},{' 4'},{' 5'},{' 6'},{' 7'},{' 8'},{' 9'},{' 10'},{' 11'},{' 12'},{' 13'},{' 14'},{' 15'},{' 16'},{' 17'},{' 18'},{' 19'},{' 20'}])
xlabel('reach amp')
ylabel('sigma p')
title('sensorimotor')
axis([0 20 0 20])
grid on
box off
set(gca,'TickDir','out','FontSize',18)

subplot(1,2,2)
scatter(reachAmpMA,sigPmarg1,80,'filled')
text(reachAmpMA,sigPmarg1,[{' 1'},{' 2'},{' 3'},{' 4'},{' 5'},{' 6'},{' 7'},{' 8'},{' 9'},{' 10'},{' 11'},{' 12'},{' 13'},{' 14'},{' 15'},{' 16'},{' 17'},{' 18'},{' 19'},{' 20'}])
xlabel('reach amp')
ylabel('sigma p')
title('motor aware')
axis([0 20 0 20])
grid on
box off
set(gca,'TickDir','out','FontSize',18)
set(gcf,'Color','white')


figure
subplot(1,2,1)
scatter3(reachAmpSM,sigPmarg1,reachesAllSM,80,'filled')
%text(reachAmpSM,sigPmarg1,[{' 1'},{' 2'},{' 3'},{' 4'},{' 5'},{' 6'},{' 7'},{' 8'},{' 9'},{' 10'},{' 11'},{' 12'},{' 13'},{' 14'},{' 15'},{' 16'},{' 17'}])
xlabel('reach amp')
ylabel('sigma p')
zlabel('reach phase')
title('sensorimotor')
axis([0 20 0 20])
grid on
box off
set(gca,'TickDir','out','FontSize',18)

subplot(1,2,2)
scatter3(reachAmpMA,sigPmarg1,reachesAllMA,80,'filled')
%text(reachAmpMA,sigPmarg1,[{' 1'},{' 2'},{' 3'},{' 4'},{' 5'},{' 6'},{' 7'},{' 8'},{' 9'},{' 10'},{' 11'},{' 12'},{' 13'},{' 14'},{' 15'},{' 16'},{' 17'}])
xlabel('reach amp')
ylabel('sigma p')
zlabel('reach phase')
title('motor aware')
axis([0 20 0 20])
grid on
box off
set(gca,'TickDir','out','FontSize',18)
set(gcf,'Color','white')


y = sigPmarg1';
x = reachesAllMA' - reportAllMA';

X = [ones(length(x),1) x];
b = X\y;
yCalc = X*b;
rSqr = 1 - sum((y - yCalc).^2)/sum((y - mean(y)).^2);
[~,~,~,~,stats] = regress(y,X);
stats(3)

figure; hold on
plot(x,yCalc)
scatter(reachesAllMA-reportAllMA,sigPmarg1)
text(reachesAllMA-reportAllMA,sigPmarg1,[{' 1'},{' 2'},{' 3'},{' 4'},{' 5'},{' 6'},{' 7'},{' 8'},{' 9'},{' 10'},{' 11'},{' 12'},{' 13'},{' 14'},{' 15'},{' 16'},{' 17'},{' 18'},{' 19'},{' 20'}])
if stats(3) <.05
    title(['sensorimotor, R sqr =' num2str(rSqr),'*'])
else
    title(['sensorimotor, R sqr =' num2str(rSqr)])
end

y = sigPmarg1(reportWin)';
x = reportAllMA(reportWin)';

X = [ones(length(x),1) x];
b = X\y;
yCalc = X*b;
rSqr = 1 - sum((y - yCalc).^2)/sum((y - mean(y)).^2);
[~,~,~,~,stats] = regress(y,X);
stats(3)
figure; hold on
plot(x,yCalc)
scatter(reportAllMA,sigPmarg1)
text(reportAllMA,sigPmarg1,[{' 1'},{' 2'},{' 3'},{' 4'},{' 5'},{' 6'},{' 7'},{' 8'},{' 9'},{' 10'},{' 11'},{' 12'},{' 13'},{' 14'},{' 15'},{' 16'},{' 17'},{' 18'},{' 19'},{' 20'}])
if stats(3) <.05
    title(['sensorimotor, R sqr =' num2str(rSqr),'*'])
else
    title(['sensorimotor, R sqr =' num2str(rSqr)])
end

