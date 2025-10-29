subjAll = [{'OY'},{'LL'},{'CK'},{'LN'},{'EN'},{'MH'},{'HL'},{'DT'},{'TC'},{'SX'},{'MG'},{'HP'},{'AS'},{'NK'},{'JH'},{'SH'},{'ML'},{'NM'},{'ET'},{'HH'}];
numSubj = length(subjAll);

for ii = 1:numSubj
    subj = subjAll{ii};
    path = sprintf('/Users/mhe229/Documents/Landy Lab/Errorclamp Experiment/data/%s',subj);
    for ss = 1:2

        if ss == 1
            load(sprintf('%s/%s_sensorimotor.mat',path,subj));
           
            figure(1)
            subplot(numSubj,1,ii); hold on
            plot(1:240,confRep)
            plot(1:240,arcStart)
            title(['Partcipant ', num2str(ii)])


        elseif ss == 2
            load(sprintf('%s/%s_motoraware.mat',path,subj));

            figure(2)
            subplot(numSubj,1,ii); hold on
            plot(1:240,confRep.*2)
            plot(1:240,arcStart)
            title(['Partcipant ', num2str(ii)])
        end
    end
end