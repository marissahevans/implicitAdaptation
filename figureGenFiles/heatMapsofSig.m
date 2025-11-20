
subjAll = [{'OY'},{'LL'},{'CK'},{'LN'},{'EN'},{'MH'},{'HL'},{'DT'},{'TC'},{'SX'},{'MG'},{'HP'},{'AS'},{'NK'},{'JH'},{'SH'},{'ML'},{'NM'},{'ET'},{'HH'}];
numSubj = length(subjAll);

for ii = 1:numSubj
    subj = subjAll{ii};
    path = sprintf('/Users/mhe229/Documents/Landy Lab/Errorclamp Experiment/data/%s',subj);
    load(sprintf('%s/%s_confPermute.mat',path,subj));
    confPvalAll(:,ii) = confPval;
    load(sprintf('%s/%s_reportPermute.mat',path,subj));
    reportPvalAll(ii) = reportPval;

    for ss = 1:2

        if ss == 1
            load(sprintf('%s/%s_sensorimotor.mat',path,subj));
            x = [abs(endPt-errClamp)];
            y = confRep;
            X = [ones(length(x),1) x];
            [~,~,~,~,stats] = regress(y,X);
            sig1(ii) = stats(3);

        elseif ss == 2
            load(sprintf('%s/%s_motoraware.mat',path,subj));
            x = [abs(endPt-errClamp)];
            y = confRep;
            X = [ones(length(x),1) x];
            [~,~,~,~,stats] = regress(y,X);
            sig2(ii) = stats(3);
        end
    end
end

%%
% figure(1)
% subplot(2,1,1)
% h = heatmap(1:20,{'confidence FFT'},confPvalAll(2,:),'FontSize',18); 
% h.CellLabelFormat = '%.2f'; 
% colormap(flipud(hot))
% 
% subplot(2,1,2)
% h = heatmap(1:20,{'mismatch R^2'},sig1,'FontSize',18); 
% h.CellLabelFormat = '%.2f'; 
% colormap(flipud(hot))
% xlabel('participant')
% %set(gcf,'Color','white','position',[0,0,1200,300])
% 
% figure(2)
% subplot(3,1,1)
% h = heatmap(1:20,{'confidence FFT'},confPvalAll(1,:),'FontSize',18); 
% h.CellLabelFormat = '%.2f'; 
% colormap(flipud(hot))
% 
% subplot(3,1,2)
% h = heatmap(1:20,{'report FFT'},reportPvalAll,'FontSize',18); 
% h.CellLabelFormat = '%.2f'; 
% colormap(flipud(hot))
% 
% subplot(3,1,3)
% set(gcf,'Color','white')
% h = heatmap(1:20,{'mismatch R^2'},sig2,'FontSize',18); 
% h.CellLabelFormat = '%.2f'; 
% colormap(flipud(hot))
% xlabel('participant')
% set(gcf,'Color','white','position',[0,0,1200,500])

%%

cdata = [confPvalAll(2,:);sig1];
xdata = 1:20;
ydata = {'confidence FFT 24 cycles \it p','hand/eye vs confidence R^2 \it p'};

figure(1)
h = heatmap(xdata,ydata,cdata,'FontSize',18); 
h.CellLabelFormat = '%.2f'; 
colormap(flipud(hot))
xlabel('participant')
set(gcf,'position',[0,0,1500,300])


cdata = [confPvalAll(1,:);reportPvalAll;sig2];
xdata = 1:20;
ydata = {'confidence FFT 24 cycles \it p','report FFT 12 cycles \it p','hand/eye vs confidence R^2 \it p'};
figure(2)
h = heatmap(xdata,ydata,cdata,'FontSize',18); 
h.CellLabelFormat = '%.2f'; 
colormap(flipud(hot))
xlabel('participant')
set(gcf,'position',[0,0,1500,500])
