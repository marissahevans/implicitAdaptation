%Plots of the raw time course data

subjAll = [{'OY'},{'LL'},{'CK'},{'LN'},{'EN'},{'MH'},{'HL'},{'DT'},{'TC'},{'SX'},{'MG'},{'HP'},{'AS'},{'NK'},{'JH'},{'SH'},{'ML'},{'NM'},{'ET'},{'HH'}];
numSubj = length(subjAll);
count1 = 1;
count2 = 1;

reachColor = hex2rgb('#CA49E0'); %pink
confColor = hex2rgb('#3DE0AE'); %teal
reportColor = hex2rgb('#E0B643'); %sand

for ii = [2 3 16 19]%1:numSubj
    

    subj = subjAll{ii};
    path = sprintf('/Users/mhe229/Documents/Landy Lab/Errorclamp Experiment/data/%s',subj);
    for ss = 1:2

        if ss == 1
            load(sprintf('%s/%s_sensorimotor.mat',path,subj));
            mConf1 = mean(confRep);

            figure(1)
            %sgtitle('Sensorimotor')
            subplot(4,1,count1)
            hold on;
            yyaxis left
            plot(trial,errClamp,'k','LineWidth',2)
            plot(trial,endPt,'-','Color',reachColor,'LineWidth',2)
            ylabel('direction')
            ylim([-15 15])

            yyaxis right
            plot(trial,confRep,'Color',confColor,'LineWidth',2)
            ylim([mConf1-20 mConf1+20])
            yticks([0 5 10 15 20])

            if count1 == 4
                legend('Errorclamp', 'Reach', 'Confidence')
                xlabel('trial')
            end
            title(['Participant ', num2str(ii)])
            box off
            set(gca,'TickDir','out','FontSize',18)
            ax = gca;
            ax.YAxis(1).Color = 'k';
            ax.YAxis(2).Color = confColor;
            set(gcf,'Color','white','position',[0,0,1200,1000])

            count1 = count1 + 1;


        elseif ss == 2
            load(sprintf('%s/%s_motoraware.mat',path,subj));
            mConf1 = mean(confRep);
            
            figure(2)
            %sgtitle('Motor Awareness')
            subplot(4,1,count2)
            hold on;
            yyaxis left
            plot(trial,errClamp,'k','LineWidth',2)
            plot(trial,endPt,'-','Color',reachColor,'LineWidth',2)
            plot(trial,report,'-','Color',reportColor,'LineWidth',2)
            ylabel('direction')
            ylim([-15 15])

            yyaxis right
            plot(trial,confRep,'Color',confColor,'LineWidth',2)
            ylim([mConf1-20 mConf1+20])
            yticks([0 5 10 15 20])

            if count2 == 4
                legend('Errorclamp', 'Reach','Report', 'Confidence')
                xlabel('trial')
            end
            title(['Participant ', num2str(ii)])
            box off
            set(gca,'TickDir','out','FontSize',18)
            ax = gca;
            ax.YAxis(1).Color = 'k';
            ax.YAxis(2).Color = confColor;
            set(gcf,'Color','white','position',[0,0,1200,1000])

            count2 = count2 + 1;

        end
    end
end