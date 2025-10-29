subjAll = [{'OY'},{'LL'},{'CK'},{'LN'},{'EN'},{'MH'},{'HL'},{'DT'},{'TC'},{'SX'},{'MG'},{'HP'},{'AS'},{'NK'},{'JH'},{'SH'},{'ML'},{'NM'},{'ET'},{'HH'}];
numSubj = length(subjAll);

for ii = 1:numSubj
    subj = subjAll{ii};
    path = sprintf('/Users/mhe229/Documents/Landy Lab/Errorclamp Experiment/data/%s',subj);
    for ss = 1:2

        if ss == 1
            load(sprintf('%s/%s_sensorimotor.mat',path,subj));

            confChange = abs(confRep - arcStart);
            [confTrunk, trunkVal] = rmoutliers(confRep);
            x = confChange(~trunkVal);
            y = confTime(~trunkVal);

            confRound = floor(abs(confTrunk));
            confRound = confRound-min(confRound);
            maxVal = max(confRound);
            rangeStep = maxVal/6;

            confVal(1,:) = confRound >= 0 & confRound < rangeStep;
            confVal(2,:) = confRound >= rangeStep & confRound < 2*rangeStep;
            confVal(3,:) = confRound >= 2*rangeStep & confRound < 3*rangeStep;
            confVal(4,:) = confRound >= 3*rangeStep & confRound < 4*rangeStep;
            confVal(5,:) = confRound >= 4*rangeStep & confRound < 5*rangeStep;
            confVal(6,:) = confRound >= 5*rangeStep & confRound <= 6*rangeStep;

            figure(1)
            sgtitle('Sensorimotor Conf')
            subplot(4,5,ii); hold on
            scatter(x(confVal(1,:)),y(confVal(1,:)),300,[153 255 255]./255,'.')
            scatter(x(confVal(2,:)),y(confVal(2,:)),300,[102 255 255]./255,'.')
            scatter(x(confVal(3,:)),y(confVal(3,:)),300,[51 255 255]./255,'.')
            scatter(x(confVal(4,:)),y(confVal(4,:)),300,[0 204 204]./255,'.')
            scatter(x(confVal(5,:)),y(confVal(5,:)),300,[0 102 102]./255,'.')
            scatter(x(confVal(6,:)),y(confVal(6,:)),300,[0 0 0]./255,'.')
            xlabel('change amount')
            ylabel('time s')

            clear confVal

        elseif ss == 2
            load(sprintf('%s/%s_motoraware.mat',path,subj));

            confChange = abs(confRep - arcStart);
            [confTrunk, trunkVal] = rmoutliers(confRep);
            x = confChange(~trunkVal);
            y = confTime(~trunkVal);

            confRound = floor(abs(confTrunk));
            confRound = confRound-min(confRound);
            maxVal = max(confRound);
            rangeStep = maxVal/6;

            confVal(1,:) = confRound >= 0 & confRound < rangeStep;
            confVal(2,:) = confRound >= rangeStep & confRound < 2*rangeStep;
            confVal(3,:) = confRound >= 2*rangeStep & confRound < 3*rangeStep;
            confVal(4,:) = confRound >= 3*rangeStep & confRound < 4*rangeStep;
            confVal(5,:) = confRound >= 4*rangeStep & confRound < 5*rangeStep;
            confVal(6,:) = confRound >= 5*rangeStep & confRound <= 6*rangeStep;

            figure(2)
            sgtitle('Motor Aware Conf')
            subplot(4,5,ii); hold on
            scatter(x(confVal(1,:)),y(confVal(1,:)),300,[153 255 255]./255,'.')
            scatter(x(confVal(2,:)),y(confVal(2,:)),300,[102 255 255]./255,'.')
            scatter(x(confVal(3,:)),y(confVal(3,:)),300,[51 255 255]./255,'.')
            scatter(x(confVal(4,:)),y(confVal(4,:)),300,[0 204 204]./255,'.')
            scatter(x(confVal(5,:)),y(confVal(5,:)),300,[0 102 102]./255,'.')
            scatter(x(confVal(6,:)),y(confVal(6,:)),300,[0 0 0]./255,'.')
            xlabel('change amount')
            ylabel('time s')

            clear confVal

        end
    end
end

