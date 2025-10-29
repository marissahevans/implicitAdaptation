subjAll = [{'OY'},{'LL'},{'CK'},{'LN'},{'EN'},{'MH'},{'HL'},{'DT'},{'TC'},{'SX'},{'MG'},{'HP'},{'AS'},{'NK'},{'JH'},{'SH'},{'ML'},{'NM'},{'ET'},{'HH'}];
numSubj = length(subjAll);
count = 0;
for ii = 1:numSubj
    subj = subjAll{ii};
    path = sprintf('/Users/mhe229/Documents/Landy Lab/Errorclamp Experiment/data/%s',subj);
    for ss = 2

        if ss == 1
            load(sprintf('%s/%s_sensorimotor.mat',path,subj));

            clampRound = floor(abs(errClamp));
            x = 1:6;
            confstd(1) = std(confRep(clampRound == 0));
            confstd(2) = std(confRep(clampRound == 3));
            confstd(3) = std(confRep(clampRound == 5));
            confstd(4) = std(confRep(clampRound == 8));
            confstd(5) = std(confRep(clampRound == 9));
            confstd(6) = std(confRep(clampRound == 10));

            figure(1)
            sgtitle('Sensorimotor Conf')
            subplot(4,5,ii)
            scatter(x,confstd)
            xlabel('distance from target')
            xticks([1 2 3 4 5 6])
            xticklabels({'0','3','5','8','9','10'})
            ylim([0 5])
            xlim([1 6])
            ylabel('standard deviation')
            title(['Participant ', num2str(ii)])
      

        elseif ss == 2
            load(sprintf('%s/%s_motoraware.mat',path,subj));
            count = count + 1;

            clampRound = floor(abs(errClamp));

            confstd(1) = std(confRep(clampRound == 0));
            confstd(2) = std(confRep(clampRound == 3));
            confstd(3) = std(confRep(clampRound == 5));
            confstd(4) = std(confRep(clampRound == 8));
            confstd(5) = std(confRep(clampRound == 9));
            confstd(6) = std(confRep(clampRound == 10));

            confmean(1) = mean(confRep(clampRound == 0));
            confmean(2) = mean(confRep(clampRound == 3));
            confmean(3) = mean(confRep(clampRound == 5));
            confmean(4) = mean(confRep(clampRound == 8));
            confmean(5) = mean(confRep(clampRound == 9));
            confmean(6) = mean(confRep(clampRound == 10));

            % figure(2)
            % sgtitle('Motor Aware Conf')
            % subplot(4,5,ii)
            % scatter(x,confstd)
            % xlabel('distance from target')
            % xticks([1 2 3 4 5 6])
            % xticklabels({'0','3','5','8','9','10'})
            % xlim([1 6])
            % ylim([0 5])
            % ylabel('standard deviation')
            % title(['Participant ', num2str(ii)])

            reportstd(1) = std(abs(report(clampRound == 0)));
            reportstd(2) = std(abs(report(clampRound == 3)));
            reportstd(3) = std(abs(report(clampRound == 5)));
            reportstd(4) = std(abs(report(clampRound == 8)));
            reportstd(5) = std(abs(report(clampRound == 9)));
            reportstd(6) = std(abs(report(clampRound == 10)));

            % figure(3)
            % sgtitle('Motor Aware Report')
            % subplot(4,5,ii)
            % scatter(x,reportstd)
            % xlabel('distance from target')
            % xticks([1 2 3 4 5 6])
            % xticklabels({'0','3','5','8','9','10'})
            % ylabel('standard deviation')
            % xlim([1 6])
            % ylim([0 5])
            % title(['Participant ', num2str(ii)])

            %Regression of mean conf vs report std for a given errorclamp
            %width
            y = confmean';
            x = reportstd';

            X = [ones(length(x),1) x];
            b = X\y;
            yCalc = X*b;
            rSqr = 1 - sum((y - yCalc).^2)/sum((y - mean(y)).^2);
            [~,~,~,~,stats] = regress(y,X);

            figure(4)
            %sgtitle('Motor Aware Report vs Conf')
            subplot(4,5,count); hold on
            scatter(x,y,80,'k','filled')
            plot(x,yCalc,'r','LineWidth',2)
            if stats(3) <.05
                title(['Participant ', num2str(ii),'R sqr =' num2str(rSqr),'*'])
            else
                title(['Participant ', num2str(ii),'R sqr =' num2str(rSqr)])
            end
            grid on
            xlabel('report standard deviation')
            ylabel('confidence mean')
            grid on
            box off
            set(gca,'TickDir','out','FontSize',18)
            set(gcf,'Color','white','position',[0,0,1200,1200])


        end
    end
end