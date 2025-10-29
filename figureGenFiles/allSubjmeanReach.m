subjAll = [{'OY'},{'LL'},{'CK'},{'LN'},{'EN'},{'MH'},{'HL'},{'DT'},{'TC'},{'SX'},{'MG'},{'HP'},{'AS'},{'NK'},{'JH'},{'SH'},{'ML'},{'NM'},{'ET'},{'HH'}];
numSubj = length(subjAll);

reach2 = [];
reach3 = [];

for ii = 1:numSubj
    subj = subjAll{ii};
    path = sprintf('/Users/mhe229/Documents/Landy Lab/Errorclamp Experiment/data/%s',subj);
    for ss = 1:2

        if ss == 1
            load(sprintf('%s/%s_sensorimotor.mat',path,subj));

            reach2 = [reach2,reshape(endPt,[20,12])];

        elseif ss == 2
            load(sprintf('%s/%s_motoraware.mat',path,subj));

            reach3 = [reach3,reshape(endPt,[20,12])];
            report2 = reshape(report,[20,12]);
 
        end
    end
end

t = linspace(0,1,21);
x = 1:21;
mReach = mean([reach2,reach3],2);
sReach = std([reach2,reach3]');
y1 = 10*cos(2*pi*1*t - deg2rad(90));
y2 = 5.1848*cos(2*pi*1*t - deg2rad(310));

figure;
hold on
yyaxis left
plot(x,y1,'LineWidth',3)
patch([1:20, fliplr(1:20)], [mReach'-sReach, fliplr(mReach'+sReach)],[0.4940 0.1840 0.5560], 'FaceAlpha',0.5,EdgeColor='none');
yline(0);
xline(11,'--');
xlabel('trial')
ylabel('direction, deg')
ylim([-20 20])
xlim([1 20])
xticks([1 11 20])
legend('Errorclamp','Reach')
box off
set(gca,'TickDir','out','FontSize',18)
set(gcf,'Color','white','position',[0,0,600,800])

figure;
hold on
yyaxis left
plot(x,y1,'LineWidth',3)
patch([1:20, fliplr(1:20)], [mReach'-sReach, fliplr(mReach'+sReach)],[0.4940 0.1840 0.5560], 'FaceAlpha',0.5,'HandleVisibility','off',EdgeColor='none');
plot(x,y2,'-','Color',[0.4940 0.1840 0.5560],'LineWidth',3)
yline(0);
xline(11,'--');
xlabel('trial')
ylabel('direction, deg')
ylim([-20 20])
xlim([1 20])
xticks([1 11 20])
legend('Errorclamp','Reach')
box off
set(gca,'TickDir','out','FontSize',18)
set(gcf,'Color','white','position',[0,0,600,800])