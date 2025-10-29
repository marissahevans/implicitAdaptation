%% Regression

subjAll = [{'OY'},{'LL'},{'CK'},{'LN'},{'EN'},{'MH'},{'HL'},{'DT'},{'TC'},{'SX'},{'MG'},{'HP'},{'AS'},{'NK'},{'JH'},{'SH'},{'ML'},{'NM'},{'ET'},{'HH'}];
numSubj = length(subjAll);

for ii = 1:numSubj
    subj = subjAll{ii};
    path = sprintf('/Users/mhe229/Documents/Landy Lab/Errorclamp Experiment/data/%s',subj);
    for ss = 2
        if ss == 1
            load(sprintf('%s/%s_motoraware.mat',path,subj));
            
            figure
            sgtitle(['MA - Participant ',num2str(ii)])
            %Confidence vs Error abs. value
            y = confRep;
            x = abs(endPt);

            X = [ones(length(x),1) x];
            b = X\y;
            yCalc = X*b;
            rSqr = 1 - sum((y - yCalc).^2)/sum((y - mean(y)).^2);
            [~,~,~,~,stats] = regress(y,X);

            subplot(2,3,1); hold on
            scatter(x,y)
            plot(x,yCalc)
            xlabel('Endpoint Error')
            ylabel('Confidence')
            if stats(3) <.05
                title(['R sqr =' num2str(rSqr),'*'])
            else
                title(['R sqr =' num2str(rSqr)])
            end
            grid on

            %Confidence vs Report abs. value
            y = [confRep];
            x = abs([report]);

            X = [ones(length(x),1) x];
            b = X\y;
            yCalc = X*b;
            rSqr = 1 - sum((y - yCalc).^2)/sum((y - mean(y)).^2);

            subplot(2,3,2); hold on
            scatter(x,y)
            plot(x,yCalc)
            xlabel('Report Distance')
            ylabel('Confidence')
            if stats(3) <.05
                title(['R sqr =' num2str(rSqr),'*'])
            else
                title(['R sqr =' num2str(rSqr)])
            end
            grid on

            %Endpoint vs Report
            y = endPt;
            x = report;

            X = [ones(length(x),1) x];
            b = X\y;
            yCalc = X*b;
            rSqr = 1 - sum((y - yCalc).^2)/sum((y - mean(y)).^2);
            [~,~,~,~,stats] = regress(y,X);

            subplot(2,3,3); hold on
            scatter(x,y)
            plot(x,yCalc)
            xlabel('Report')
            ylabel('Endpoint')
            if stats(3) <.05
                title(['R sqr =' num2str(rSqr),'*'])
            else
                title(['R sqr =' num2str(rSqr)])
            end
            grid on

            %Endpoint vs Prev. Errorclamp
            y = [endPt(2:end)];
            x = [errClamp(1:end-1)];

            X = [ones(length(x),1) x];
            b = X\y;
            yCalc = X*b;
            rSqr = 1 - sum((y - yCalc).^2)/sum((y - mean(y)).^2);
            [~,~,~,~,stats] = regress(y,X);

            subplot(2,3,4); hold on
            scatter(x,y)
            plot(x,yCalc)
            ylabel('Endpoint Error')
            xlabel('Prev. Error Clamp')
            if stats(3) <.05
                title(['R sqr =' num2str(rSqr),'*'])
            else
                title(['R sqr =' num2str(rSqr)])
            end
            grid on

            %Confidence vs Report Error
            y = [abs(endPt-report)];
            x = confRep;

            X = [ones(length(x),1) x];
            b = X\y;
            yCalc = X*b;
            rSqr = 1 - sum((y - yCalc).^2)/sum((y - mean(y)).^2);
            [~,~,~,~,stats] = regress(y,X);

            subplot(2,3,5); hold on
            scatter(x,y)
            plot(x,yCalc)
            xlabel('Confidence')
            ylabel('Report Error')
            if stats(3) <.05
                title(['R sqr =' num2str(rSqr),'*'])
            else
                title(['R sqr =' num2str(rSqr)])
            end
            grid on

            %Report vs Errorclamp
            y = report;
            x = errClamp;

            X = [ones(length(x),1) x];
            b = X\y;
            yCalc = X*b;
            rSqr = 1 - sum((y - yCalc).^2)/sum((y - mean(y)).^2);
            [~,~,~,~,stats] = regress(y,X);

            subplot(2,3,6); hold on
            scatter(x,y)
            plot(x,yCalc)
            xlabel('Error Clamp')
            ylabel('Report')
            if stats(3) <.05
                title(['R sqr =' num2str(rSqr),'*'])
            else
                title(['R sqr =' num2str(rSqr)])
            end
            grid on

        elseif ss == 2
            load(sprintf('%s/%s_sensorimotor.mat',path,subj));

            figure
            sgtitle(['SM - Participant ',num2str(ii)])
            
            %Confidence vs Error abs. value
            y = confRep;
            x = abs(endPt);

            X = [ones(length(x),1) x];
            b = X\y;
            yCalc = X*b;
            rSqr = 1 - sum((y - yCalc).^2)/sum((y - mean(y)).^2);
            [~,~,~,~,stats] = regress(y,X);

            subplot(1,3,1); hold on
            scatter(x,y)
            plot(x,yCalc)
            xlabel('Endpoint Error')
            ylabel('Confidence')
            if stats(3) <.05
                title(['R sqr =' num2str(rSqr),'*'])
            else
                title(['R sqr =' num2str(rSqr)])
            end
            grid on

            %Endpoint vs Prev. Errorclamp
            y = [endPt(2:end)];
            x = [errClamp(1:end-1)];

            X = [ones(length(x),1) x];
            b = X\y;
            yCalc = X*b;
            rSqr = 1 - sum((y - yCalc).^2)/sum((y - mean(y)).^2);
            [~,~,~,~,stats] = regress(y,X);

            subplot(1,3,2); hold on
            scatter(x,y)
            plot(x,yCalc)
            ylabel('Endpoint')
            xlabel('Prev. Error Clamp')
            if stats(3) <.05
                title(['R sqr =' num2str(rSqr),'*'])
            else
                title(['R sqr =' num2str(rSqr)])
            end
            grid on

            %Confidence vs Error Clamp
            y = confRep;
            x = abs(errClamp);

            X = [ones(length(x),1) x];
            b = X\y;
            yCalc = X*b;
            rSqr = 1 - sum((y - yCalc).^2)/sum((y - mean(y)).^2);
            [~,~,~,~,stats] = regress(y,X);

            subplot(1,3,3); hold on
            scatter(x,y)
            plot(x,yCalc)
            xlabel('Error Clamp')
            ylabel('Confidence')
            if stats(3) <.05
                title(['R sqr =' num2str(rSqr),'*'])
            else
                title(['R sqr =' num2str(rSqr)])
            end
            grid on
        end
    end
end