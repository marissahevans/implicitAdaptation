%% Proprioceptive and motor sigmas

subjAll = [{'OY'},{'LL'},{'CK'},{'LN'},{'EN'},{'MH'},{'HL'},{'DT'},{'TC'},{'SX'},{'MG'},{'HP'},{'AS'},{'NK'},{'JH'},{'SH'},{'ML'},{'NM'},{'ET'},{'HH'}];
numSubj = length(subjAll);
clear report 

for ii = 1:numSubj
    subj = subjAll{ii};
    path = sprintf('/Users/mhe229/Documents/Landy Lab/Errorclamp Experiment/publicGitHubRepo/implicitAdaptation/data/%s',subj);
    if subj == 'OY'
        % OY
        load('OY_errClamp_exp_S1_2025-03-04_14-26_errresults.mat')
        reach(1:40) = errResultsMat.endPtAngle(21:60)'-90;
        report(1:40) = errResultsMat.reportAngle(21:60)';

        load('OY_errClamp_exp_S3_2025-03-07_16-55_errresults.mat')
        reach(41:80) = errResultsMat.endPtAngle(21:60)'-90;
        report(41:80) = errResultsMat.reportAngle(21:60)';

        reach(abs(reach)>25) = mean(reach);
        report(abs(report)>25) = mean(report);

    elseif subj == 'CK'
        % CK
        load('CK_errClamp_exp_S2_2025-03-06_17-01_errresults.mat')
        reach(1:40) = errResultsMat.endPtAngle(21:60)'-90;
        report(1:40) = errResultsMat.reportAngle(21:60)';

        load('CK_errClamp_exp_S1_2025-03-06_15-50_errresults.mat')
        reach(41:80) = errResultsMat.endPtAngle(21:60)'-90;
        report(41:80) = errResultsMat.reportAngle(21:60)';
        
        reach(abs(reach)>25) = mean(reach);
        report(abs(report)>25) = mean(report);

    elseif subj == 'MG'
        load('MG_errClamp_exp_S1_2025-03-24_14-48_errresults.mat')
        reach(1:40) = errResultsMat.endPtAngle(21:60)'-90;
        report(1:40) = errResultsMat.reportAngle(21:60)';

        load('MG_errClamp_exp_S2_2025-03-27_15-00_errresults.mat')
        reach(41:80) = errResultsMat.endPtAngle(21:60)'-90;
        report(41:80) = errResultsMat.reportAngle(21:60)';

    elseif subj == 'SX'
        load('SX_errClamp_exp_S1_2025-03-26_15-50_errresults.mat')
        reach(1:40) = errResultsMat.endPtAngle(21:60)'-90;
        report(1:40) = errResultsMat.reportAngle(21:60)';

        load('SX_errClamp_exp_S2_2025-04-10_15-00_errresults.mat')
        reach(41:80) = errResultsMat.endPtAngle(21:60)'-90;
        report(41:80) = errResultsMat.reportAngle(21:60)';

    elseif subj == 'ML'
        load('ML_errClamp_exp_S1_2025-03-25_14-59_errresults.mat')
        reach(1:40) = errResultsMat.endPtAngle(21:60)'-90;
        report(1:40) = errResultsMat.reportAngle(21:60)';

        load('ML_errClamp_exp_S2_2025-03-25_16-34_errresults.mat')
        reach(41:80) = errResultsMat.endPtAngle(21:60)'-90;
        report(41:80) = -errResultsMat.reportAngle(21:60)';

    elseif subj == 'LL'
        load('LL_errClamp_exp_S1_2025-03-27_12-50_errresults.mat')
        reach(1:40) = errResultsMat.endPtAngle(21:60)'-90;
        report(1:40) = errResultsMat.reportAngle(21:60)';

        load('LL_errClamp_exp_S2_2025-03-28_14-45_errresults.mat')
        reach(41:80) = errResultsMat.endPtAngle(21:60)'-90;
        report(41:80) = errResultsMat.reportAngle(21:60)';

    elseif subj == 'LN'
        load('LN_errClamp_exp_S1_2025-04-10_16-00_errresults.mat')
        reach(1:40) = errResultsMat.endPtAngle(21:60)'-90;
        report(1:40) = errResultsMat.reportAngle(21:60)';

        load('LN_errClamp_exp_S2_2025-04-14_15-46_errresults.mat')
        reach(41:80) = errResultsMat.endPtAngle(21:60)'-90;
        report(41:80) = errResultsMat.reportAngle(21:60)';

    elseif subj == 'EN'
        load('EN_errClamp_exp_S1_2025-04-15_15-57_errresults.mat')
        reach(1:40) = errResultsMat.endPtAngle(21:60)'-90;
        report(1:40) = errResultsMat.reportAngle(21:60)';

        load('EN_errClamp_exp_S2_2025-04-15_17-07_errresults.mat')
        reach(41:80) = errResultsMat.endPtAngle(21:60)'-90;
        report(41:80) = errResultsMat.reportAngle(21:60)';

        reach(abs(reach)>30) = mean(reach);
        report(abs(report)>30) = mean(report);

    elseif subj == 'NK'
        load('NK_errClamp_exp_S1_2025-04-17_15-29_errresults.mat')
        reach(1:40) = errResultsMat.endPtAngle(21:60)'-90;
        report(1:40) = errResultsMat.reportAngle(21:60)';

        load('NK_errClamp_exp_S2_2025-04-17_16-20_errresults.mat')
        reach(41:80) = errResultsMat.endPtAngle(21:60)'-90;
        report(41:80) = errResultsMat.reportAngle(21:60)';

    elseif subj == 'SH'
        load('SH_errClamp_exp_S1_2025-04-25_15-16_errresults.mat')
        reach(1:40) = errResultsMat.endPtAngle(21:60)'-90;
        report(1:40) = errResultsMat.reportAngle(21:60)';

        load('SH_errClamp_exp_S2_2025-04-25_16-30_errresults.mat')
        reach(41:80) = errResultsMat.endPtAngle(21:60)'-90;
        report(41:80) = errResultsMat.reportAngle(21:60)';

    elseif subj == 'HP'
        load('HP_errClamp_exp_S1_2025-04-29_09-01_errresults.mat')
        reach(1:40) = errResultsMat.endPtAngle(21:60)'-90;
        report(1:40) = errResultsMat.reportAngle(21:60)';

        load('HP_errClamp_exp_S2_2025-04-29_09-45_errresults.mat')
        reach(41:80) = errResultsMat.endPtAngle(21:60)'-90;
        report(41:80) = errResultsMat.reportAngle(21:60)';

    elseif subj == 'DT'
        load('DT_errClamp_exp_S1_2025-04-28_13-01_errresults.mat')
        reach(1:40) = errResultsMat.endPtAngle(21:60)'-90;
        report(1:40) = errResultsMat.reportAngle(21:60)';

        load('DT_errClamp_exp_S2_2025-04-29_13-59_errresults.mat')
        reach(41:80) = errResultsMat.endPtAngle(21:60)'-90;
        report(41:80) = errResultsMat.reportAngle(21:60)';

        elseif subj == 'MH'
        load('MH_errClamp_exp_S1_2025-04-24_16-06_errresults.mat')
        reach(1:40) = errResultsMat.endPtAngle(21:60)'-90;
        report(1:40) = errResultsMat.reportAngle(21:60)';

        load('MH_errClamp_exp_S2_2025-04-30_15-55_errresults.mat')
        reach(41:80) = errResultsMat.endPtAngle(21:60)'-90;
        report(41:80) = errResultsMat.reportAngle(21:60)';

        elseif subj == 'TC'
        load('TC_errClamp_exp_S1_2025-05-02_15-05_errresults.mat')
        reach(1:40) = errResultsMat.endPtAngle(21:60)'-90;
        report(1:40) = errResultsMat.reportAngle(21:60)';

        load('TC_errClamp_exp_S2_2025-05-02_16-30_errresults.mat')
        reach(41:80) = errResultsMat.endPtAngle(21:60)'-90;
        report(41:80) = errResultsMat.reportAngle(21:60)';

        elseif subj == 'ET'
        load('ET_errClamp_exp_S1_2025-04-30_13-59_errresults.mat')
        reach(1:40) = errResultsMat.endPtAngle(21:60)'-90;
        report(1:40) = errResultsMat.reportAngle(21:60)';

        load('ET_errClamp_exp_S2_2025-05-07_13-59_errresults.mat')
        reach(41:80) = errResultsMat.endPtAngle(21:60)'-90;
        report(41:80) = errResultsMat.reportAngle(21:60)';

        elseif subj == 'HH'
        load('HH_errClamp_exp_S1_2025-05-06_16-00_errresults.mat')
        reach(1:40) = errResultsMat.endPtAngle(21:60)'-90;
        report(1:40) = -errResultsMat.reportAngle(21:60)';

        load('HH_errClamp_exp_S2_2025-05-07_16-00_errresults.mat')
        reach(41:80) = errResultsMat.endPtAngle(21:60)'-90;
        report(41:80) = errResultsMat.reportAngle(21:60)';

        elseif subj == 'HL'
        load('HL_errClamp_exp_S1_2025-04-29_13-02_errresults.mat')
        reach(1:40) = errResultsMat.endPtAngle(21:60)'-90;
        report(1:40) = errResultsMat.reportAngle(21:60)';

        load('HL_errClamp_exp_S2_2025-05-09_12-14_errresults.mat')
        reach(41:80) = errResultsMat.endPtAngle(21:60)'-90;
        report(41:80) = errResultsMat.reportAngle(21:60)';

        elseif subj == 'JH'
        load('JH_errClamp_exp_S1_2025-05-07_15-01_errresults.mat')
        reach(1:40) = errResultsMat.endPtAngle(21:60)'-90;
        report(1:40) = errResultsMat.reportAngle(21:60)';

        load('JH_errClamp_exp_S2_2025-05-12_13-58_errresults.mat')
        reach(41:80) = errResultsMat.endPtAngle(21:60)'-90;
        report(41:80) = errResultsMat.reportAngle(21:60)';

        elseif subj == 'AS'
        load('AS_errClamp_exp_S1_2025-05-09_15-12_errresults.mat')
        reach(1:40) = errResultsMat.endPtAngle(21:60)'-90;
        report(1:40) = errResultsMat.reportAngle(21:60)';

        load('AS_errClamp_exp_S2_2025-05-12_15-03_errresults.mat')
        reach(41:80) = errResultsMat.endPtAngle(21:60)'-90;
        report(41:80) = errResultsMat.reportAngle(21:60)';

        elseif subj == 'NM'
        load('NM_errClamp_exp_S1_2025-05-13_16-14_errresults.mat')
        reach(1:40) = errResultsMat.endPtAngle(21:60)'-90;
        report(1:40) = errResultsMat.reportAngle(21:60)';

        load('NM_errClamp_exp_S2_2025-05-13_17-19_errresults.mat')
        reach(41:80) = errResultsMat.endPtAngle(21:60)'-90;
        report(41:80) = errResultsMat.reportAngle(21:60)';
    end
    
    
    %%
   
    %Likelihood fitting of sigma_m and sigma_p
    m_vec = 1:.1:40;
    p_vec = 1:.1:40;
    LL=zeros(length(m_vec),length(p_vec));
    LLigivene=zeros(length(m_vec),length(p_vec));
    LLe=zeros(length(m_vec),1);

    N = length(reach);

    for vv = 1:length(m_vec)        %loop over all sigma_m options
        RmTemp = 1/m_vec(vv)^2;

        LLe(vv) = -N*log(2*pi) - 2*N*log(m_vec(vv)) - (sum(reach.^2)/(2*m_vec(vv)^2));
        for jj = 1:length(p_vec)    %loop over all sigma_p options
            RpTemp = 1/p_vec(jj)^2;
            meanigivene = (RpTemp/(RpTemp+RmTemp))*reach + ...
                (RmTemp/(RpTemp+RmTemp))*0;
            SDigivene = (RpTemp/(RpTemp+RmTemp))*p_vec(jj);

            % log likelihood of sigma_p given sensed location and endpoint:
            LLigivene(vv,jj) = -N*log(2*pi) - 2*N*log(SDigivene) - (sum((report-meanigivene).^2)/(2*SDigivene^2));

            % log likelihood of the sigma_p/sigma_m pair:
            LL(vv,jj) = LLe(vv) + LLigivene(vv,jj);
        end
    end

    % treat LL like a log posterior (i.e., treat prior as flat over the grid)
    % and calculate marginals. First add a constant to all LL values so that
    % the maximum is one (to minimize underflows) and normalize afterward.

    NormPost = exp(LL - max(LL(:)));

    %Motor Error Marginal
    mmarg = sum(NormPost,2);
    mmarg = mmarg/sum(mmarg);
    sigMmarg = m_vec(find(mmarg == max(mmarg)));
    sigMmarg1(ii) = sigMmarg;

    %Proprioception Marginal
    pmarg = sum(NormPost,1);
    pmarg = pmarg/sum(pmarg);
    sigPmarg = p_vec(find(pmarg == max(pmarg)));
    sigPmarg1(ii) = sigPmarg;

    filename = sprintf('%s_sigmaFit.mat',subj);
    save(fullfile(path,filename),'sigMmarg','sigPmarg');

    %% Scatter Plots
    rm = 1/sigMmarg^2;
    rp = 1/sigPmarg^2;
    r_p = rp/(rp+rm);
    x = -20:20;
    y1 = r_p*x;

    if ii == 2
        figure(1)
        subplot(2,3,2); hold on
        scatter(reach,report,75,'filled','MarkerFaceAlpha',.5)
        plot(x,y1,'LineWidth',2)
        ylim([-20 20])
        xlim([-20 20])        
        xlabel('end point error, deg')
        ylabel('report direction, deg')
        grid on
        box off
        set(gca,'TickDir','out','FontSize',18)
        title(['Participant ', num2str(ii)])

    elseif ii == 3
        figure(1)
        subplot(2,3,3); hold on
        scatter(reach,report,75,'filled','MarkerFaceAlpha',.5)
        plot(x,y1,'LineWidth',2)
        ylim([-20 20])
        xlim([-20 20])        
        xlabel('end point error, deg')
        ylabel('report direction, deg')
        grid on
        box off
        set(gca,'TickDir','out','FontSize',18)
        title(['Participant ', num2str(ii)])

    elseif ii == 16
        figure(1)
        subplot(2,3,5); hold on
        scatter(reach,report,75,'filled','MarkerFaceAlpha',.5)
        plot(x,y1,'LineWidth',2)
        ylim([-20 20])
        xlim([-20 20])
        xlabel('end point error, deg')
        ylabel('report direction, deg')
        grid on
        box off
        set(gca,'TickDir','out','FontSize',18)
        title(['Participant ', num2str(ii)])

    elseif ii == 19
        figure(1)
        subplot(2,3,6); hold on
        scatter(reach,report,75,'filled','MarkerFaceAlpha',.5)
        plot(x,y1,'LineWidth',2)
        ylim([-20 20])
        xlim([-20 20])
        xlabel('end point error, deg')
        ylabel('report direction, deg')
        grid on
        box off
        set(gca,'TickDir','out','FontSize',18)
        title(['Participant ', num2str(ii)])
        legend('data','model parameter ratio')
    end
end


%%
figure(1)
subplot(2,3, [1 4]); hold on
%plot(0:20,0:20,'k--')
scatter(sigMmarg1,sigPmarg1,100,'filled')
text(sigMmarg1,sigPmarg1,[{' 1'},{' 2'},{' 3'},{' 4'},{' 5'},{' 6'},{' 7'},{' 8'},{' 9'},{' 10'},{' 11'},{' 12'},{' 13'},{' 14'},{' 15'},{' 16'},{' 17'},{' 18'},{' 19'},{' 20'}],'FontSize',18)
xlim([0 8])
ylim([0 18])
xlabel('motor error, deg')
ylabel('proprioceptive error, deg')
grid on
box off
set(gca,'TickDir','out','FontSize',18)
set(gcf,'Color','white','position',[0,0,1400,800])

%%
% figure
% scatter(reach,report)