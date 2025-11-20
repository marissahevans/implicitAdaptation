%Amplitude comparisons

subjAll = [{'OY'},{'LL'},{'CK'},{'LN'},{'EN'},{'MH'},{'HL'},{'DT'},{'TC'},{'SX'},{'MG'},{'HP'},{'AS'},{'NK'},{'JH'},{'SH'},{'ML'},{'NM'},{'ET'},{'HH'}];
numSubj = length(subjAll);

for ii = 1:numSubj
    subj = subjAll{ii};
    path = sprintf('/Users/mhe229/Documents/Landy Lab/Errorclamp Experiment/publicGitHubRepo/implicitAdaptation/data/%s',subj);
    load(sprintf('%s/%s_confPermute.mat',path,subj));
    for ss = 1:2

        if ss == 1
            load(sprintf('%s/%s_sensorimotor.mat',path,subj));
            load(sprintf('%s/%s_sigmaFit.mat',path,subj));

            reachAmpSM(ii) = rms(endPt)/.707;
            sigPmarg1(ii) = sigPmarg;

            figure(1)
            subplot(1,2,1); hold on
            scatter(reachAmpSM(ii),sigPmarg,80,'k','filled')
            text(reachAmpSM(ii),sigPmarg,['  ',num2str(ii)],'FontSize',12)
            xlabel('reach adaptation sine amplitude, deg')
            %ylabel('proprioceptive uncertainty, deg')
            %title('sensorimotor')
            axis([0 22 0 20])
            grid on
            box off
            set(gca,'TickDir','out','FontSize',18)


        elseif ss == 2
            load(sprintf('%s/%s_motoraware.mat',path,subj));
            load(sprintf('%s/%s_sigmaFit.mat',path,subj));

            reachAmpMA(ii) = rms(endPt)/.707;

            figure(1)
            subplot(1,2,2); hold on
            scatter(reachAmpMA(ii),sigPmarg,80,'k','filled')
            text(reachAmpMA(ii),sigPmarg,['  ',num2str(ii)],'FontSize',12)
            xlabel('reach adaptation sine amplitude, deg')
            ylabel('proprioceptive uncertainty, deg')
            %title('sensorimotor')
            axis([0 22 0 20])
            grid on
            box off
            set(gca,'TickDir','out','FontSize',18)
            set(gcf,'Color','white','position',[0,0,1600,800])



        end
    end
end



y = sigPmarg1';
x = reachAmpSM';

X = [ones(length(x),1) x];
b = X\y;
yCalc = X*b;
rSqr = 1 - sum((y - yCalc).^2)/sum((y - mean(y)).^2);
[~,~,~,~,stats] = regress(y,X);
stats(3)

figure(1)
subplot(1,2,1); hold on
plot(x,yCalc,'r','LineWidth',2)
if stats(3) <.05
    title(['sensorimotor, R^2 =' num2str(rSqr,'%05.2f'),'*'])
else
    title(['sensorimotor, R^2 =' num2str(rSqr,'%05.2f')])
end


y = sigPmarg1';
x = reachAmpMA';

X = [ones(length(x),1) x];
b = X\y;
yCalc = X*b;
rSqr = 1 - sum((y - yCalc).^2)/sum((y - mean(y)).^2);
[~,~,~,~,stats] = regress(y,X);
stats(3)

figure(1)
subplot(1,2,2); hold on
plot(x,yCalc,'r','LineWidth',2)
if stats(3) <.05
    title(['motor-awareness, R^2 =' num2str(rSqr,'%05.2f'),'*'])
else
    title(['motor-awareness, R^2 =' num2str(rSqr,'%05.2f')])
end

y = reachAmpSM';
x = reachAmpMA';

X = [ones(length(x),1) x];
b = X\y;
yCalc = X*b;
rSqr = 1 - sum((y - yCalc).^2)/sum((y - mean(y)).^2);
[~,~,~,~,stats] = regress(y,X);
stats(3)

figure(2)
hold on
plot(x,yCalc,'r','LineWidth',2)
scatter(x,y)
if stats(3) <.05
    title(['sensorimotor, R^2 =' num2str(rSqr,'%05.2f'),'*'])
else
    title(['sensorimotor, R^2 =' num2str(rSqr,'%05.2f')])
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

y = sigPmarg1';
x = reportAllMA';

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

