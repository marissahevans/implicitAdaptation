%Phase vs Amplitude 2D plot 

subjAll = [{'OY'},{'CK'},{'MG'},{'SX'},{'ML'},{'LL'},{'LN'},{'EN'},{'NK'}];
numSubj = length(subjAll);

figure
for ii = 1:numSubj
    subj = subjAll{ii};
    path = sprintf('/Users/mhe229/Documents/Landy Lab/Errorclamp Experiment/data/%s',subj);
    for ss = 1:2

        if ss == 1
            load(sprintf('%s/%s_sensorimotor.mat',path,subj));
            subplot(1,2,1); hold on
            title('Sensorimotor')
            scatter(phase(:,1),amp(:,1),'b','filled')
            scatter(phase(:,2),amp(:,2),'k','filled')
            xline(180,'--');
            yline(10);
            xlim([0 360])
            xlabel('Phase')
            ylabel('Amplitude')
            legend('Reach','Confidence','Anti-Phase')
        
        elseif ss == 2
            load(sprintf('%s/%s_motoraware.mat',path,subj));
            subplot(1,2,2); hold on
            title('Motor Awareness')
            scatter(phase(:,1),amp(:,1),'b','filled')
            scatter(phase(:,2),amp(:,2),'r','filled')
            scatter(phase(:,3),amp(:,3),'k','filled')
            xline(180,'--');
            yline(10);
            xlim([0 360])
            xlabel('Phase')
            ylabel('Amplitude')
            legend('Reach','Report','Confidence','Anti-Phase')
        end
        
       
    end
end