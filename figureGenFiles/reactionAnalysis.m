%Reaction time comparisions 

subjAll = [{'OY'},{'CK'},{'MG'},{'SX'},{'ML'},{'LL'},{'LN'},{'EN'},{'NK'}];
numSubj = length(subjAll);

for ii = 1:numSubj
    subj = subjAll{ii};
    path = sprintf('/Users/mhe229/Documents/Landy Lab/Errorclamp Experiment/data/%s',subj);
    figure
    sgtitle(['Participant ',num2str(ii)])
    for ss = 1:2

        if ss == 1
            load(sprintf('%s/%s_sensorimotor.mat',path,subj));

            %Confidence vs confidence time
            y = confRep;
            x = confTime;

            X = [ones(length(x),1) x];
            b = X\y;
            yCalc = X*b;
            rSqr = 1 - sum((y - yCalc).^2)/sum((y - mean(y)).^2);
            [~,~,~,~,stats] = regress(y,X);

            subplot(1,3,1); hold on
            scatter(x,y)
            plot(x,yCalc)
            xlabel('Confidence Time')
            ylabel('Confidence')
            if stats(3) <.05
                title(['SM - R sqr =' num2str(rSqr),'*'])
            else
                title(['SM - R sqr =' num2str(rSqr)])
            end
            grid on

        elseif ss == 2
            load(sprintf('%s/%s_motoraware.mat',path,subj));
                 %Confidence vs confidence time
            y = confRep;
            x = confTime;

            X = [ones(length(x),1) x];
            b = X\y;
            yCalc = X*b;
            rSqr = 1 - sum((y - yCalc).^2)/sum((y - mean(y)).^2);
            [~,~,~,~,stats] = regress(y,X);

            subplot(1,3,2); hold on
            scatter(x,y)
            plot(x,yCalc)
            xlabel('Confidence Time')
            ylabel('Confidence')
            if stats(3) <.05
                title(['MA - R sqr =' num2str(rSqr),'*'])
            else
                title(['MA - R sqr =' num2str(rSqr)])
            end
            grid on

             %Confidence vs report time
            y = confRep;
            x = reportTime;

            X = [ones(length(x),1) x];
            b = X\y;
            yCalc = X*b;
            rSqr = 1 - sum((y - yCalc).^2)/sum((y - mean(y)).^2);
            [~,~,~,~,stats] = regress(y,X);

            subplot(1,3,3); hold on
            scatter(x,y)
            plot(x,yCalc)
            xlabel('Report Time')
            ylabel('Confidence')
            if stats(3) <.05
                title(['MA - R sqr =' num2str(rSqr),'*'])
            else
                title(['MA - R sqr =' num2str(rSqr)])
            end
            grid on
        end
    end
end
