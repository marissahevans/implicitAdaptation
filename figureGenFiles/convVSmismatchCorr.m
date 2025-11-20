subjAll = [{'OY'},{'LL'},{'CK'},{'LN'},{'EN'},{'MH'},{'HL'},{'DT'},{'TC'},{'SX'},{'MG'},{'HP'},{'AS'},{'NK'},{'JH'},{'SH'},{'ML'},{'NM'},{'ET'},{'HH'}];
numSubj = length(subjAll);
count = 0;
for ii = [2 3 16 19]
    subj = subjAll{ii};
    path = sprintf('/Users/mhe229/Documents/Landy Lab/Errorclamp Experiment/data/%s',subj);

    %MOTOR AWARENESS
    load(sprintf('%s/%s_motoraware.mat',path,subj));
    clampRound = floor(abs(errClamp));
    count = count+1;
    figure(1)
    %sgtitle('Motor Awareness')
    x = [abs(endPt-errClamp)];
    y = confRep;

    X = [ones(length(x),1) x];
    b = X\y;
    yCalc = X*b;
    rSqr2(ii) = 1 - sum((y - yCalc).^2)/sum((y - mean(y)).^2);
    [~,~,~,~,stats] = regress(y,X);
    sig2(ii) = stats(3);

    subplot(1,4,count); hold on
    plot(1:20,1:20,'k--')
    scatter(x,y,'k.')
    plot_gaussian_ellipsoid(mean([x,y]),cov([x,y]))
    % scatter(x(clampRound == 0),y(clampRound == 0),300,[41 47 86]./255,'.')
    % scatter(x(clampRound == 3),y(clampRound == 3),300,[0 92 139]./255,'.')
    % scatter(x(clampRound == 5),y(clampRound == 5),300,[0 139 160]./255,'.')
    % scatter(x(clampRound == 8),y(clampRound == 8),300,[0 188 161]./255,'.')
    % scatter(x(clampRound == 9),y(clampRound == 9),300,[105 232 130]./255,'.')
    % scatter(x(clampRound == 10),y(clampRound == 10),300,[172 250 112]./255,'.')
    plot(x,yCalc,'r','LineWidth',2)

    ylabel('confidence, deg')
    xlabel('mismatch, deg')
    xlim([0 20])
    ylim([0 20])
    if stats(3) <.05
        title(['P',num2str(ii),' \it{r} = ' num2str(rSqr2(ii),'%05.2f'),'*'])
    else
        title(['P',num2str(ii),' \it{r} = ' num2str(rSqr2(ii),'%05.2f')])
    end
    grid on
    box off
    set(gca,'TickDir','out','FontSize',18)
    set(gcf,'Color','white','position',[0,0,1200,400])

    %SENSORIMOTOR
    load(sprintf('%s/%s_sensorimotor.mat',path,subj));
    clampRound = floor(abs(errClamp));

    figure(2)
    %sgtitle('Sensorimotor')

    %Confidence vs Error abs. value
    y = confRep;
    x = abs(endPt-errClamp);

    X = [ones(length(x),1) x];
    b = X\y;
    yCalc = X*b;
    rSqr1(ii) = 1 - sum((y - yCalc).^2)/sum((y - mean(y)).^2);
    [~,~,~,~,stats] = regress(y,X);
    sig1(ii) = stats(3);

    subplot(1,4,count); hold on
    plot(0:20,0:20,'k--')
    scatter(x,y,'k.')
    plot_gaussian_ellipsoid(mean([x,y]),cov([x,y]))
    % scatter(x(clampRound == 0),y(clampRound == 0),300,[41 47 86]./255,'.')
    % scatter(x(clampRound == 3),y(clampRound == 3),300,[0 92 139]./255,'.')
    % scatter(x(clampRound == 5),y(clampRound == 5),300,[0 139 160]./255,'.')
    % scatter(x(clampRound == 8),y(clampRound == 8),300,[0 188 161]./255,'.')
    % scatter(x(clampRound == 9),y(clampRound == 9),300,[105 232 130]./255,'.')
    % scatter(x(clampRound == 10),y(clampRound == 10),300,[172 250 112]./255,'.')
    plot(x,yCalc,'r','LineWidth',2)
    xlabel('mismatch, deg')
    ylabel('confidence, deg')
    xlim([0 20])
    ylim([0 20])
    if stats(3) <.05
        title(['P',num2str(ii),' \it{r} = ' num2str(rSqr1(ii),'%05.2f'),'*'])
    else
        title(['P',num2str(ii),' \it{r} = ' num2str(rSqr1(ii),'%05.2f')])
    end
    grid on
    box off
    set(gca,'TickDir','out','FontSize',18)
    set(gcf,'Color','white','position',[0,0,1200,400])


    % if ii == 7
    %     clampRound = floor(abs(errClamp));
    % 
    %     figure; hold on
    %     plot(0:20,0:20,'k--')
    %     scatter(x(clampRound == 0),y(clampRound == 0),300,[41 47 86]./255,'.')
    %     scatter(x(clampRound == 3),y(clampRound == 3),300,[0 92 139]./255,'.')
    %     scatter(x(clampRound == 5),y(clampRound == 5),300,[0 139 160]./255,'.')
    %     scatter(x(clampRound == 8),y(clampRound == 8),300,[0 188 161]./255,'.')
    %     scatter(x(clampRound == 9),y(clampRound == 9),300,[105 232 130]./255,'.')
    %     scatter(x(clampRound == 10),y(clampRound == 10),300,[172 250 112]./255,'.')
    %     plot(x,yCalc,'LineWidth',5)
    %     xlabel('feedback to hand mismatch, deg')
    %     ylabel('confidence width, deg')
    %     xlim([0 20])
    %     title(['R sqr =' num2str(rSqr),'*'])
    %     grid on
    %     box off
    %     set(gca,'TickDir','out','FontSize',18)
    %     set(gcf,'Color','white','position',[0,0,600,800])
    % end


end

%%
% figure(3)
% subplot(2,1,1)
% set(gcf,'Color','white')
% heatmap(1:20,{'mismatch'},sig1,'CellLabelColor','none','FontSize',18)
% colormap(turbo)
% xlabel('participant')
% set(gcf,'Color','white','position',[0,0,1200,105])
% 
% subplot(2,1,2)
% set(gcf,'Color','white')
% heatmap(1:20,{'mismatch'},sig2,'CellLabelColor','none','FontSize',18)
% colormap(turbo)
% xlabel('participant')
% set(gcf,'Color','white','position',[0,0,1200,105])