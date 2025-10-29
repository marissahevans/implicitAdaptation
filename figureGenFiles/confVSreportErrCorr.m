subjAll = [{'OY'},{'LL'},{'CK'},{'LN'},{'EN'},{'MH'},{'HL'},{'DT'},{'TC'},{'SX'},{'MG'},{'HP'},{'AS'},{'NK'},{'JH'},{'SH'},{'ML'},{'NM'},{'ET'},{'HH'}];
numSubj = length(subjAll);

for ii = 1:numSubj
    subj = subjAll{ii};
    path = sprintf('/Users/mhe229/Documents/Landy Lab/Errorclamp Experiment/data/%s',subj);
    
            load(sprintf('%s/%s_motoraware.mat',path,subj));

            figure(1)
            sgtitle('Motor Awareness')
            x = [abs(endPt-report)];
            y = confRep;

            X = [ones(length(x),1) x];
            b = X\y;
            yCalc = X*b;
            rSqr = 1 - sum((y - yCalc).^2)/sum((y - mean(y)).^2);
            [~,~,~,~,stats] = regress(y,X);

            subplot(4,5,ii); hold on
            plot(1:20,1:20,'--')
            scatter(x,y)
            plot(x,yCalc)
            
            ylabel('Confidence')
            xlabel('Report Error')
            xlim([0 20])
            if stats(3) <.05
                title(['P',num2str(ii),' R sqr =' num2str(rSqr),'*'])
            else
                title(['P',num2str(ii),' R sqr =' num2str(rSqr)])
            end
            grid on

            load(sprintf('%s/%s_sensorimotor.mat',path,subj));

            figure(2)
            sgtitle('Sensorimotor')
            
            %Confidence vs Error abs. value
            y = confRep;
            x = abs(endPt);

            X = [ones(length(x),1) x];
            b = X\y;
            yCalc = X*b;
            rSqr = 1 - sum((y - yCalc).^2)/sum((y - mean(y)).^2);
            [~,~,~,~,stats] = regress(y,X);

            subplot(4,5,ii); hold on
            plot(0:20,0:20,'--')
            scatter(x,y)
            plot(x,yCalc)
            xlabel('Endpoint Error')
            ylabel('Confidence')
            xlim([0 20])
            if stats(3) <.05
                title(['P',num2str(ii),' R sqr =' num2str(rSqr),'*'])
            else
                title(['P',num2str(ii),' R sqr =' num2str(rSqr)])
            end
            grid on

end