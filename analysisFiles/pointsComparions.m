subjAll = [{'OY'},{'LL'},{'CK'},{'LN'},{'EN'},{'MH'},{'HL'},{'DT'},{'TC'},{'SX'},{'MG'},{'HP'},{'AS'},{'NK'},{'JH'},{'SH'},{'ML'},{'NM'},{'ET'},{'HH'}];
numSubj = length(subjAll);

for ii = 1:numSubj
    subj = subjAll{ii};
    path = sprintf('/Users/mhe229/Documents/Landy Lab/Errorclamp Experiment/data/%s',subj);
    for ss = 1:2

        if ss == 1
            load(sprintf('%s/%s_sensorimotor.mat',path,subj));
           
            figure(1); hold on 
            scatter(ii,sum(pointsEarned),100,'k')
            SMpts(ii) = sum(pointsEarned);
            SMsuccess(ii) = sum(pointsEarned~=0);


        elseif ss == 2
            load(sprintf('%s/%s_motoraware.mat',path,subj));

            % figure(2); hold on 
            % scatter(ii,sum(pointsEarned),100,'k')
            MApts(ii) = sum(pointsEarned);
            MAsuccess(ii) = sum(pointsEarned~=0);

            % figure(3); hold on
            % if any([1:9,12,13] == ii)
            %     subplot(1,2,1)
            %     plot(abs(abs(endPt)-abs(report)))
            % else
            %     subplot(1,2,2)
            %     plot(abs(abs(endPt)-abs(report)))
            % end

            repErrM(ii) = sum(abs(abs(endPt)-abs(report)));
            repErrSD(ii) = std(abs(abs(endPt)-abs(report)));

        end
    end
end

% figure(1)
% yline(mean(SMpts(1:11)))
% yline(mean(SMpts(12:20)))
% 
% figure(2)
% yline(mean(MApts([1:9 12 13])))
% yline(mean(MApts([10 11 14:20])))

ttest(MApts([1:9 12 13]),mean(MApts([10 11 14:20])));
ttest(MApts([10 11 14:20]),mean(MApts([1:9 12 13])));

ttest(SMpts(1:11),mean(SMpts(12:20)));
ttest(SMpts(12:20),mean(SMpts(1:11)));

[h, p, ci, stats] = ttest(SMpts,MApts)
std(SMpts - MApts)

[h, p, ci, stats] = ttest2(SMpts(1:11),SMpts(12:20));
[h, p, ci, stats] =ttest2(MApts([1:9 12 13]),MApts([10 11 14:20]));

[h, p, ci, stats] =ttest2(repErrM([1:9 12 13]),repErrM([10 11 14:20]));

%[h, p, ci, stats] =ttest2(sigPmarg1([1:9, 12,13]),sigPmarg1([10 11,14:20]));