%Plots of the raw time course data

subjAll = [{'OY'},{'LL'},{'CK'},{'LN'},{'EN'},{'MH'},{'HL'},{'DT'},{'TC'},{'SX'},{'MG'},{'HP'},{'AS'},{'NK'},{'JH'},{'SH'},{'ML'},{'NM'},{'ET'},{'HH'}];
numSubj = length(subjAll);
count1 = 0;
count2 = 0;

reachColor = hex2rgb('#3DE0AE'); %teal
confColor = hex2rgb('#CA49E0'); %pink
reportColor = hex2rgb('#E0B643'); %sand


for ii = [2 3 16 19]
    subj = subjAll{ii};
    path = sprintf('/Users/mhe229/Documents/Landy Lab/Errorclamp Experiment/data/%s',subj);
    load(sprintf('%s/%s_confPermute.mat',path,subj));
    confFreq = signifFreq;
    load(sprintf('%s/%s_reportPermute.mat',path,subj));
    reportFreq = signifFreq;

    for ss = 1:2

        if ss == 1
            load(sprintf('%s/%s_sensorimotor.mat',path,subj));

            count1 = count1 + 1;
            mConf1 = mean(confRep);
            reach2 = reshape(endPt,[20,12]);
            conf2 = reshape(confRep,[20,12]);

            mReach = mean(reach2,2);
            mConf = mean(conf2,2);

            sReach = std(reach2');
            sConf = std(conf2');

            t = linspace(0,1,21);
            x = 1:21;

            %if using data
            y2 = (rms(endPt)/.707)*cos(2*pi*1*t + deg2rad(thetaReach));
            if confFreq(2) == 1
                y3 = (rms(confRep-mean(confRep))/.707)*cos(2*pi*2*t + deg2rad(thetaConf))+mean(confRep);
            else
                y3 = 0*cos(2*pi*2*t + deg2rad(thetaConf))+mean(confRep);
            end

            %Averaged time course with fft fits
            figure(5)
            subplot(2,2,count1)
            hold on;
            yyaxis left
            plot(1:20,errClamp(1:20),'k','LineWidth',2)
            patch([1:20, fliplr(1:20)], [mReach'-sReach, fliplr(mReach'+sReach)],reachColor, 'FaceAlpha',0.5,'HandleVisibility','off',EdgeColor='none');
            plot(1:20,mReach,'--','Color',reachColor,'LineWidth',2,'HandleVisibility','off')
            plot(x,y2,'-','Color',reachColor,'LineWidth',4)
            ylabel('direction, deg')
            ylim([-20 20])
            yline(0,'HandleVisibility','off');

            yyaxis right
            patch([1:20, fliplr(1:20)], [mConf'-sConf, fliplr(mConf'+sConf)],confColor, 'FaceAlpha',0.5,'HandleVisibility','off',EdgeColor='none');
            plot(1:20,mConf,'--','Color',confColor,'LineWidth',2,'HandleVisibility','off')
            plot(x,y3,'-','Color',confColor,'LineWidth',4)
            ylabel('confidence width, deg')
            ylim([mConf1-20 mConf1+20])
            yticks([0 5 10 15 20])

            xline(11,'--');
            xlabel('trial')
            xlim([1 20])
            xticks([1 11 20])
            if count1 == 4
                legend('Errorclamp', 'Reach', 'Confidence')
            end
            title(['Participant ', num2str(ii)])
            box off
            set(gca,'TickDir','out','FontSize',18)
            ax = gca;
            ax.YAxis(1).Color = 'k';
            ax.YAxis(2).Color = confColor;
            set(gcf,'Color','white','position',[0,0,1200,1600])

            %MOTOR AWARENESS
        elseif ss == 2
            load(sprintf('%s/%s_motoraware.mat',path,subj));

            count2 = count2+1;
            mConf1 = mean(confRep);
            reach2 = reshape(endPt,[20,12]);
            report2 = reshape(report,[20,12]);
            conf2 = reshape(confRep,[20,12]);

            mReach = mean(reach2,2);
            mReport = mean(report2,2);
            mConf = mean(conf2,2);

            sReach = std(reach2');
            sReport = std(report2');
            sConf = std(conf2');

            t = linspace(0,1,21);
            x = 1:21;

            y2 = (rms(endPt)/.707)*cos(2*pi*1*t + deg2rad(thetaReach));
            if reportFreq == 1
                y3 = (rms(report)/.707)*cos(2*pi*1*t + deg2rad(thetaReport));
            else
                y3 = 0*cos(2*pi*1*t + deg2rad(thetaReport));
            end
            if confFreq(1) == 1
                y4 = (rms(confRep-mean(confRep))/.707)*cos(2*pi*2*t + deg2rad(thetaConf))+mean(confRep);
            else
                y4 = 0*cos(2*pi*2*t + deg2rad(thetaConf))+mean(confRep);
            end

            %averaged time course with fft fits
            figure(6)
            subplot(2,2,count2)
            hold on;
            yyaxis left
            plot(1:20,errClamp(1:20),'k','LineWidth',2)
            patch([1:20, fliplr(1:20)], [mReach'-sReach, fliplr(mReach'+sReach)],reachColor, 'FaceAlpha',0.5,'HandleVisibility','off',EdgeColor='none');
            plot(1:20,mReach,'--','Color',reachColor,'LineWidth',2,'HandleVisibility','off')
            patch([1:20, fliplr(1:20)], [mReport'-sReport, fliplr(mReport'+sReport)],reportColor, 'FaceAlpha',0.5,'HandleVisibility','off',EdgeColor='none');
            plot(1:20,mReport,'--','Color',reportColor,'LineWidth',2,'HandleVisibility','off')
            plot(x,y2,'-','Color',reachColor,'LineWidth',4)
            plot(x,y3,'-','Color',reportColor,'LineWidth',4)
            ylabel('direction, deg')
            ylim([-20 20])
            yline(0,'HandleVisibility','off');

            yyaxis right
            patch([1:20, fliplr(1:20)], [mConf'-sConf, fliplr(mConf'+sConf)],confColor, 'FaceAlpha',0.5,'HandleVisibility','off',EdgeColor='none');
            plot(1:20,mConf,'--','Color',confColor,'LineWidth',2,'HandleVisibility','off')
            plot(x,y4,'-','Color',confColor,'LineWidth',4)
            ylabel('confidence width, deg')
            ylim([mConf1-20 mConf1+20])
            yticks([0 5 10 15 20])

            xline(11,'--');
            xlabel('trial')
            xlim([1 20])
            xticks([1 11 20])
            if count2 == 4
                legend('Errorclamp', 'Reach', 'Report','Confidence')
            end
            title(['Participant ', num2str(ii)])
            box off
            set(gca,'TickDir','out','FontSize',18)
            ax = gca;
            ax.YAxis(1).Color = 'k';
            ax.YAxis(2).Color = confColor;
            set(gcf,'Color','white','position',[0,0,1200,1600])


        end
    end
end