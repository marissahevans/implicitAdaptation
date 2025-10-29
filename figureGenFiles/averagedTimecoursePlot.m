%Plots averaged time course data over one cycle

subjAll = [{'OY'},{'LL'},{'CK'},{'LN'},{'EN'},{'MH'},{'HL'},{'DT'},{'TC'},{'SX'},{'MG'},{'HP'},{'AS'},{'NK'},{'JH'},{'SH'},{'ML'},{'NM'},{'ET'},{'HH'}];
numSubj = length(subjAll);

for ii = 1:numSubj
    subj = subjAll{ii};
    path = sprintf('/Users/mhe229/Documents/Landy Lab/Errorclamp Experiment/data/%s',subj);
    for ss = 1:2

        if ss == 1
            load(sprintf('%s/%s_sensorimotor.mat',path,subj));

            reach2 = reshape(endPt,[20,12]);
            conf2 = reshape(confRepCent,[20,12]);

            mReach = mean(reach2,2);
            mConf = mean(conf2,2);

            sReach = std(reach2');
            sConf = std(conf2');

            figure(1)
            sgtitle('Sensorimotor')
            subplot(1,numSubj,ii)
            hold on;
            plot(1:20,errClamp(1:20))
            plot(1:20,mReach,'Color',[0.8500 0.3250 0.0980])
            plot(1:20,mReach+sReach','Color',[0.8500 0.3250 0.0980],'HandleVisibility','off')
            plot(1:20,mReach-sReach','Color',[0.8500 0.3250 0.0980],'HandleVisibility','off')
            plot(1:20,mConf,'Color',[0.4940 0.1840 0.5560])
            plot(1:20,mConf+sConf','Color',[0.4940 0.1840 0.5560],'HandleVisibility','off')
            plot(1:20,mConf-sConf','Color',[0.4940 0.1840 0.5560],'HandleVisibility','off')
            yline(0);
            legend('Errorclamp', 'Reach', 'Confidence')
            xlabel('trial')
            ylabel('direction')
            ylim([-20 20])
            title(['Participant ', num2str(ii)])


        elseif ss == 2
            load(sprintf('%s/%s_motoraware.mat',path,subj));
            
            reach2 = reshape(endPt,[20,12]);
            report2 = reshape(report,[20,12]);
            conf2 = reshape(confRepCent,[20,12]);

            mReach = mean(reach2,2);
            mReport = mean(report2,2);
            mConf = mean(conf2,2);

            sReach = std(reach2');
            sReport = std(report2');
            sConf = std(conf2');
            
            figure(2)
            sgtitle('Motor Awareness')
            subplot(1,numSubj,ii)
            hold on;
            plot(1:20,errClamp(1:20))
            plot(1:20,mReach,'Color',[0.8500 0.3250 0.0980])
            plot(1:20,mReach+sReach','Color',[0.8500 0.3250 0.0980],'HandleVisibility','off')
            plot(1:20,mReach-sReach','Color',[0.8500 0.3250 0.0980],'HandleVisibility','off')
            plot(1:20,mReport,'Color',[0.4660 0.6740 0.1880])
            plot(1:20,mReport+sReport','Color',[0.4660 0.6740 0.1880],'HandleVisibility','off')
            plot(1:20,mReport-sReport','Color',[0.4660 0.6740 0.1880],'HandleVisibility','off')
            plot(1:20,mConf,'Color',[0.4940 0.1840 0.5560])
            plot(1:20,mConf+sConf','Color',[0.4940 0.1840 0.5560],'HandleVisibility','off')
            plot(1:20,mConf-sConf','Color',[0.4940 0.1840 0.5560],'HandleVisibility','off')
            yline(0);
            xlabel('trial')
            ylabel('direction')
            ylim([-20 20])
            legend('Errorclamp', 'Reach','Report', 'Confidence')
            title(['Participant ', num2str(ii)])

        end
    end
end