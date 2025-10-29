 %% Perturb Reach Experiment main operational code
%This file is the main control script for the experiment. For each session
%edit the necessary information in the Participant Info section then run
%from thi s script. 
 
%This s  cript calls several functions, namely:
%screenVisuals.m - sets up colors and screens
%startExp.m - starts psychToolbox
%wacCalib2.m - calibration script
%errrorClampTrialSeq.m - main experimental trials

%Output is save as results.mat and dispInfo.mat
 
%setting the file path 
cd('C:\Users\labadmin\Documents\errorClampExperiment');
%% Experiment start
% Clear the workspace and the screen
sca;  
close all;
clearvars;
%%%%%%%%%%%%%%%%%%%%%%%% Participant Info %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subj = 'NM';                        %participant initials, two letters only
session = 02;                      %session being run {01 or 02)
confType = 2;                       %1 if motor awareness, 2 if sensorimotor 
redoCalib = 0;                    %force re-calibration. Always 0 unless session calibration was inaccurate, then 1
testing = 0;                          %if testing skip instructions
startBlock = 1;                       %in case of restart, specifies start block
%% DO NOT EDIT BELOW THIS LINE 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numBlocks = 5;              %number of blocks
numIter = 60;                   %number of trials per block
 
expName = 'errClamp';          %experiment title

confTrial = 1;                 %how often does a confidence trial appear
restart = 0;                    %Always 0

dateTime = clock;               %gets time for seed
rng(sum(100*dateTime));         %sets seed to be dependent on the clock

%%%%%%%%%%%%%%%%%%%%%%%%% File Save Path %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%using file save stucture function from Shannon
%create save structure for experimental trials
[exp,fSaveFile,tSaveFile,restart] = expDataSetup(expName,subj,session,'exp',restart);

%% %%%%%%%%%%%%%%%%%%%%%%% Setting up Psychtoolbox %%%%%%%%%%%%%%%%%%%%%%%%

%Standard settings for number of screens, screen size, screen selection,
%refresh rate, color space, and screen coordinates.
[displayInfo] = startExp(subj,datetime,rng);

%%
%%%%%%%%%%%%%%%%%%%%%%% Visual Trial Settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Visual settings includng target color, size, location, quantity,rcle color and shape, fixation circle color and shape

[displayInfo] = screenVisuals(displayInfo);

%% %%%%%%%%%%%%%%%%%%%%% Screen Calibration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Check if calibration for TODAY already exists for a given participant, and
%no recalibration has been requested
if exist(['data_errClamp\' subj '\' subj '_' expName '_S' num2str(session) '_' date,'_tform.mat']) && redoCalib == 0
    load(['data_errClamp\' subj '\' subj '_' expName '_S' num2str(session) '_' date,'_tform.mat']) %load calibration incase of restart
    load(['data_errClamp\' subj '\' subj '_' expName '_S' num2str(session) '_' date,'_calibration.mat'])
else
    %9 point calibration for WACOM tablet and projector screen. Includes
    %calibration, affine transform, calibration test, and acceptance check.
    startPhase = 0;
    while startPhase == 0
        [tform, calibration,startPhase] = wacCalib2(displayInfo);
        if startPhase == 1
            save(['data_errClamp\' subj '\' subj '_' expName '_S' num2str(session) '_' date,'_tform.mat'],'tform')
            save(['data_errClamp\' subj '\' subj '_' expName '_S' num2str(session) '_' date,'_calibration.mat'],'calibration')
        end
        pause(1);
    end
    
    %% %%%%%%%% Pause in experiment to change to full siver mirror %%%%%%%%%%%%
    
    instructions = ('Please wait for experimenter to change mirror, then press T to continue to the experiment');
    [instructionsX instructionsY] = centreText(displayInfo.window, instructions, 15);
    Screen('DrawText', displayInfo.window, instructions, instructionsX, instructionsY, displayInfo.whiteVal);
    Screen('Flip', displayInfo.window);
    
    KbName('UnifyKeyNames');
    tKeyID = KbName('t');
    ListenChar(2);
    
    %Waits for T key to move forward with experiment
    [keyIsDown, secs, keyCode] = KbCheck;
    while keyCode(tKeyID)~=1
        [keyIsDown, secs, keyCode] = KbCheck;
    end
    ListenChar(1);
    
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% Trial Specifics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%starting position for values within the trial loop
gamephase = 0;                  %trial phase start

%settings specific to the trial set
numTrials = ones(numBlocks,1)*numIter; %total trial number in each block
sessTrials = numTrials(1); %number of trials in 1 block
totalTrials = sum(numTrials);   %total trials in all blocks
numSecs = .3;                    %stimulus hold time
numFrames = round(numSecs/displayInfo.ifi); %stimulus hold time on screen adjusted for refresh
tarDispTime = round(.25/displayInfo.ifi);   %target display duration
pauseTime = .3;                  %pauses within trial
iti = .3;                        %inter-trial interval in seconds
respWindow = .8;                 %time participant has to respond

trial = 1+((startBlock-1)*sessTrials);                      %trial counter start

expTrials1 = totalTrials-sessTrials; 
expTrials = 0:(1/expTrials1):1;
sineWave = 10*sin(2*pi*12*expTrials');
errorClamp = [90*ones(sessTrials,1);90+sineWave];

%saving trial specifics to structure
displayInfo.confType = confType;
displayInfo.errorClamp = errorClamp;
displayInfo.numBlocks = numBlocks;
displayInfo.numIterations = numIter;
displayInfo.numTrials = numTrials;
displayInfo.sessTrials = sessTrials;
displayInfo.totalTrials = totalTrials;
displayInfo.confTrial = confTrial;
displayInfo.numFrames = numFrames;
displayInfo.pauseTime = pauseTime;
displayInfo.iti = iti;
displayInfo.tarDispTime = tarDispTime;
displayInfo.respWindow = respWindow;
displayInfo.tform = tform;
displayInfo.calibration = calibration;
displayInfo.fSaveFile = fSaveFile ;
displayInfo.testing = testing;

%%
%%%%%%%%%%%%%%%%%%%%%%% Save Display Settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%saving visual and system settings for experimental trials
save([fSaveFile,'_dispInfo.mat'],'displayInfo')


%%
%%%%%%%%%%%%%%%%%%%%%% Run experimental trials %%%%%%%%%%%%%%%%%%%%%%%%%%
%first block is practice trials
HideCursor;
save([fSaveFile,'_dispInfo.mat'],'displayInfo')
[errResultsMat] = errorClampTrialSeq(displayInfo, numBlocks, gamephase, trial, startBlock);
save([fSaveFile,'_errresults.mat'],'errResultsMat'); %saves final expermimental data (also saved at the end of each run, and text files per trial)
ShowCursor;


%%
%%%%%%%%%%%%%%%%%%%%%%%%%% Finish Experiment %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%'end' page is displayed at the end of the experimental trials
%clear tablet

% Clear the screen
sca;