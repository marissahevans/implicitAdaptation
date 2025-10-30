%tests significance of frequencies found in FFT of data through shuffled
%permutation testing.

subjAll = [{'OY'},{'LL'},{'CK'},{'LN'},{'EN'},{'MH'},{'HL'},{'TC'},{'DT'},{'SX'},{'MG'},{'HP'},{'AS'},{'NK'},{'JH'},{'SH'},{'ML'},{'NM'},{'ET'},{'HH'}];
numSubj = length(subjAll);

for ii = 1:numSubj
    subj = subjAll{ii};
    path = sprintf('/Users/mhe229/Documents/Landy Lab/Errorclamp Experiment/publicGitHubRepo/implicitAdaptation/data/%s',subj);

    load(sprintf('%s/%s_motoraware.mat',path,subj));

    %% Permutations
    numPerm = 100000;

    n = length(errClamp);
    x = 0:(n/2)-1;

    %Confidence
    fourier1 = abs(fft(report));
    fourMatRep = nan(n,numPerm);

    for cc = 1:numPerm
        datShuff = confRepCent(randperm(n));
        datShuff = datShuff - mean(datShuff);
        fourMatRep(:,cc) = abs(fft(datShuff));
    end

    for idx = 1:120
        exactP4(idx) = sum(fourMatRep(idx,:)>fourier1(idx))/numPerm;
    end

    permutePval = exactP4;



    %%
    %significant amplitudes
    figure(1)
    subplot(numSubj,1,ii); hold on
    plot(x,permutePval)
    scatter(x(permutePval<.01),permutePval(permutePval<.01),'r*')
    yline(.01);
    xline(12);
    sgtitle('Report Motor Awareness')
    title(['Participant ',num2str(ii)])
    ylabel('p-value')
    xlabel('Frequency')




    signifFreq = permutePval(:,13)<.01;
    reportPval = permutePval(:,13);

    filename = sprintf('%s_reportPermute.mat',subj);
    save(fullfile(path,filename),'permutePval','signifFreq','reportPval');


end
