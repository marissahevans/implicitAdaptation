function [errResultsMat,motorError] = errorClampTrialSeq(displayInfo,numBlocks, gamephase, trial,startBlock)
%% Error clamp confidence experiment.

% 1. Instructions screen - verbal instructions for how to do the task
% 2. Wait for participant to move pen to fixation point
% 3. Turn cursor off
% 4. Display a target
% 5. Reach is made to target location at the 'go' cue
% 6. RIght hand left at reach endpoint and left used to spin dial to report
% estimated reach angle visually
% 7. Confidence report possible from reported endpoint


wacData = [];

xc = displayInfo.xCenter;
yc = displayInfo.yCenter;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Select Target Location %%%%%%%%%%%%%%%%%%%

dotXpos = xc; %target X location
dotYpos = yc-125; %target Y location
targetLoc = [dotXpos dotYpos];
startPos = [displayInfo.xCenter displayInfo.screenYpixels-175];

errorClamp = displayInfo.errorClamp;

HideCursor;
%%%%%%%%%%%%%%%%%%%%%%%%%% Output Variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%location information
trialNum =[];                   %trial number
wXwY = nan(displayInfo.totalTrials,2);      %wacom coordinates for end point
endPointWac = [];               %true end X and Y
fixError =[];                   %error (in pixels) from fixation
tform = displayInfo.tform;
pktData = zeros(1,5);
pktData3 = [];

%timestamps
tarAppearTime = [];             %target appearance time
moveStart = [];                 %movement start time
moveEnd = [];                   %movement end time
startTimes = [];                %start time of trial
endPtReportTime = [];           %time at which endpoint is reported
confTime = [];                  %time when confidence is reported

%duration measures
framerate = Screen('NominalFrameRate',displayInfo.window2);
inTimes = [];                   %time it takes for participant to get inside fixation
RTs = [];                       %time it takes for participant to start response
MTs = [];                       %duration of movement
tabletData = [];

%points
blockScore = [];
reportArc = [];
reportAngle = [];
arcStartIdx = [];
pointsEarned = [];
pointsPossible = [];

%Because tablet is smaller than projected area:
topBuff = [0 0 displayInfo.screenXpixels displayInfo.screenAdj/2]; %black bar at top of screen
bottomBuff = [0 displayInfo.screenYpixels-displayInfo.screenAdj/2 displayInfo.screenXpixels displayInfo.screenYpixels]; %black bar at bottom of screen

%%%%%%%%%%%%%%%%%%%%%%%%%% Initalizing powerMate %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pm = PsychPowerMate('Open');            %will read a numeric value.

%%%%%%%%%%%%%%%%%%%%%%% Setting up escape and timing %%%%%%%%%%%%%%%%%%%%%%
% Define the ESC key
KbName('UnifyKeynames');                    %get key names
esc = KbName('ESCAPE');                     %set escape key code
[keyIsDown, secs, keyCode] = KbCheck;       % Exits experiment when ESC key is pressed.

%%
%%%%%%%%%%%%%%%%%%%%%%%% Experimental Code %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
errResultsMat = struct();
tic                                                     %start block timer
jj = 0;
for bb = startBlock:numBlocks                                    %run for number of blocks in fucntion settings
    timeFlag = 0;                                       %flag to reshuffle trial order of remaining permutations if trial was missed do to timing error
    %%%%%%%%%%%%%%%%%%%%%%%%%%%% Trial Permutations %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for tt = 1:displayInfo.sessTrials                                  %run for set number of iterations within a block
        while jj < tt
            if displayInfo.testing == 0
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INSTRUCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%
                if trial == 1
                    %INSTRUCTIONS PAGE 1 - experiment instructions - endpoint report
                    instructions1 = ('In this experiment you will be reaching to the same target on every trial');
                    instructions2 = ('Reach forward to slice through the target, and for these next 20 trials view your actual reach trajectory');
                    instructions4 = (' ');
                    instructions5 = ('Press SPACE to start trials');
                    [instructionsX1, instructionsY1] = centreText(displayInfo.window, instructions1, 15);
                    [instructionsX2, instructionsY2] = centreText(displayInfo.window, instructions2, 15);
                    [instructionsX4, instructionsY4] = centreText(displayInfo.window, instructions4, 15);
                    [instructionsX5, instructionsY5] = centreText(displayInfo.window, instructions5, 15);
                    Screen('DrawText', displayInfo.window, instructions1, instructionsX1, instructionsY1-40, displayInfo.whiteVal);
                    Screen('DrawText', displayInfo.window, instructions2, instructionsX2, instructionsY2, displayInfo.whiteVal);
                    Screen('DrawText', displayInfo.window, instructions4, instructionsX4, instructionsY4+80, displayInfo.whiteVal);
                    Screen('DrawText', displayInfo.window, instructions5, instructionsX5, instructionsY5+160, displayInfo.whiteVal);
                    Screen('Flip', displayInfo.window);
                    pause(2);
                    
                    KbName('UnifyKeyNames');
                    KeyID = KbName('space');
                    ListenChar(2);
                    %Waits for key press
                    [keyIsDown, secs, keyCode] = KbCheck;
                    while keyCode(KeyID)~=1
                        [keyIsDown, secs, keyCode] = KbCheck;
                    end
                    ListenChar(1);
                end
                if trial == 21
                    %INSTRUCTIONS PAGE 2 - experiment instructions - confidence report
                    instructions1 = ('In this next set of trials you will not be shown any reach feedback');
                    instructions2 = ('After each reach you will be asked to indicate your perceived reach angle using the dial');
                    instructions3 = ('A randomly generated dot will represent your angle report, rotate it to your sensed location then press down to confirm your input');
                    instructions4 = (' ');
                    instructions6 = ('Leave the pen in positioned on the tablet and use dial to report your endpoint with your left hand');
                    instructions5 = ('Press SPACE to start trials');
                    [instructionsX1, instructionsY1] = centreText(displayInfo.window, instructions1, 15);
                    [instructionsX2, instructionsY2] = centreText(displayInfo.window, instructions2, 15);
                    [instructionsX3, instructionsY3] = centreText(displayInfo.window, instructions3, 15);
                    [instructionsX4, instructionsY4] = centreText(displayInfo.window, instructions4, 15);
                    [instructionsX5, instructionsY5] = centreText(displayInfo.window, instructions5, 15);
                    [instructionsX6, instructionsY6] = centreText(displayInfo.window, instructions6, 15);
                    Screen('DrawText', displayInfo.window, instructions6, instructionsX6, instructionsY6+120, displayInfo.whiteVal);
                    Screen('DrawText', displayInfo.window, instructions1, instructionsX1, instructionsY1-40, displayInfo.whiteVal);
                    Screen('DrawText', displayInfo.window, instructions2, instructionsX2, instructionsY2, displayInfo.whiteVal);
                    Screen('DrawText', displayInfo.window, instructions3, instructionsX3, instructionsY3+40, displayInfo.whiteVal);
                    Screen('DrawText', displayInfo.window, instructions4, instructionsX4, instructionsY4+80, displayInfo.whiteVal);
                    Screen('DrawText', displayInfo.window, instructions5, instructionsX5, instructionsY5+160, displayInfo.whiteVal);
                    Screen('Flip', displayInfo.window);
                    pause(2);
                    
                    KbName('UnifyKeyNames');
                    KeyID = KbName('space');
                    ListenChar(2);
                    %Waits for key press
                    [keyIsDown, secs, keyCode] = KbCheck;
                    while keyCode(KeyID)~=1
                        [keyIsDown, secs, keyCode] = KbCheck;
                    end
                    ListenChar(1);
                end
                if trial == 61
                    %INSTRUCTIONS PAGE 3 
                    instructions0 = ('For the rest of the trials you will be shown reach trajectory at a random angle. This is not your true reach angle.');
                    if displayInfo.confType == 1
                        instructions1 = ('Once you report your endpoint you will be asked for your confidence');
                        instructions2 = ('Use the dial again to adjust the size of an arc centered on your reported endpoint');
                    else
                        instructions1 = ('Once you complete your reach you will be asked for your confidence in hitting the target');
                        instructions2 = ('Use the dial again to adjust the size of an arc centered on the target location');
                    end
                    instructions3 = ('Larger arcs mean lower confidence. Press down to confirm your input');
                    instructions4 = (' ');
                    instructions5 = ('Press SPACE to move to next screen');
                    [instructionsX0, instructionsY0] = centreText(displayInfo.window, instructions0, 15);
                    [instructionsX1, instructionsY1] = centreText(displayInfo.window, instructions1, 15);
                    [instructionsX2, instructionsY2] = centreText(displayInfo.window, instructions2, 15);
                    [instructionsX3, instructionsY3] = centreText(displayInfo.window, instructions3, 15);
                    [instructionsX4, instructionsY4] = centreText(displayInfo.window, instructions4, 15);
                    [instructionsX5, instructionsY5] = centreText(displayInfo.window, instructions5, 15);
                    Screen('DrawText', displayInfo.window, instructions0, instructionsX0, instructionsY0-80, displayInfo.whiteVal);
                    Screen('DrawText', displayInfo.window, instructions1, instructionsX1, instructionsY1-40, displayInfo.whiteVal);
                    Screen('DrawText', displayInfo.window, instructions2, instructionsX2, instructionsY2, displayInfo.whiteVal);
                    Screen('DrawText', displayInfo.window, instructions3, instructionsX3, instructionsY3+40, displayInfo.whiteVal);
                    Screen('DrawText', displayInfo.window, instructions4, instructionsX4, instructionsY4+80, displayInfo.whiteVal);
                    Screen('DrawText', displayInfo.window, instructions5, instructionsX5, instructionsY5+160, displayInfo.whiteVal);
                    Screen('Flip', displayInfo.window);
                    pause(2);
                    
                    KbName('UnifyKeyNames');
                    KeyID = KbName('space');
                    ListenChar(2);
                    %Waits for key press
                    [keyIsDown, secs, keyCode] = KbCheck;
                    while keyCode(KeyID)~=1
                        [keyIsDown, secs, keyCode] = KbCheck;
                    end
                    ListenChar(1);
                    
                    %INSTRUCTIONS PAGE 4
                    instructions0 = ('Points will be awarded based on your confidence report');
                    instructions1 = ('If your true reach angle falls inside the confidence arc, you will recieve all points possible for that arc size');
                    instructions2 = ('However if you fail to enclose your reach angle 0 points will be awarded');
                    instructions3 = ('A leader board will be shown at the end of each block. Try for the high score!');
                    instructions4 = (' ');
                    instructions5 = ('Press SPACE to move to next screen');
                    [instructionsX0, instructionsY0] = centreText(displayInfo.window, instructions0, 15);
                    [instructionsX1, instructionsY1] = centreText(displayInfo.window, instructions1, 15);
                    [instructionsX2, instructionsY2] = centreText(displayInfo.window, instructions2, 15);
                    [instructionsX3, instructionsY3] = centreText(displayInfo.window, instructions3, 15);
                    [instructionsX4, instructionsY4] = centreText(displayInfo.window, instructions4, 15);
                    [instructionsX5, instructionsY5] = centreText(displayInfo.window, instructions5, 15);
                    Screen('DrawText', displayInfo.window, instructions0, instructionsX0, instructionsY0-80, displayInfo.whiteVal);
                    Screen('DrawText', displayInfo.window, instructions1, instructionsX1, instructionsY1-40, displayInfo.whiteVal);
                    Screen('DrawText', displayInfo.window, instructions2, instructionsX2, instructionsY2, displayInfo.whiteVal);
                    Screen('DrawText', displayInfo.window, instructions3, instructionsX3, instructionsY3+40, displayInfo.whiteVal);
                    Screen('DrawText', displayInfo.window, instructions4, instructionsX4, instructionsY4+80, displayInfo.whiteVal);
                    Screen('DrawText', displayInfo.window, instructions5, instructionsX5, instructionsY5+160, displayInfo.whiteVal);
                    Screen('Flip', displayInfo.window);
                    pause(2);
                    
                    KbName('UnifyKeyNames');
                    KeyID = KbName('space');
                    ListenChar(2);
                    %Waits for key press
                    [keyIsDown, secs, keyCode] = KbCheck;
                    while keyCode(KeyID)~=1
                        [keyIsDown, secs, keyCode] = KbCheck;
                    end
                    ListenChar(1);
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%% Initalizing GetMouse %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [x, y, buttons] = GetMouse(displayInfo.window2);
            
            while gamephase <= 5
                %%%%%%%%%%%%%%%%%%%%%%%% Begin drawing to screen %%%%%%%%%%%%%%%%%%%%%%%%%%
                
                %Start Screen
                if gamephase == 0                       %starting screen
                    
                    startTimes(trial) = toc;            %capture start time
                    t = toc;                            %make relative time point
                    temp = 1;                           %temp counting variable
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Trial Visualizations Begin %%%%%%%%%%%%%%%
                    
                    while temp == 1
                        %Starting instruction screen
                        Screen('FrameOval', displayInfo.window, displayInfo.whiteVal, displayInfo.controlRect, 2,2); %fixation circle
                        Screen('FillRect', displayInfo.window,displayInfo.blackVal, topBuff);
                        Screen('FillRect', displayInfo.window,displayInfo.blackVal, bottomBuff);
                        instructions = 'Place pen inside white fixation circle and hold until target turns green';
                        [instructionsX, instructionsY] = centreText(displayInfo.window, instructions, 15);
                        Screen('DrawText', displayInfo.window, instructions, instructionsX, instructionsY, displayInfo.whiteVal);
                        
                        [x, y, buttons] = GetMouse(displayInfo.window2); %get pen position
                        [x1, y1] = transformPointsForward(tform,x,y);
                        fixError(trial,1) = x1-displayInfo.xCenter; fixError(trial,2) = y1-(displayInfo.screenYpixels-175); %fixation check (must be inside circle)
                        %Show cursor when near fixation to help center at
                        %start
                        if abs(fixError(trial,1)) <= 50 && abs(fixError(trial,2)) <= 50
                            Screen('DrawDots', displayInfo.window, [x1 y1], displayInfo.dotSizePix, displayInfo.whiteVal, [], 2); %pen location
                        end
                        if abs(fixError(trial,1)) <= displayInfo.baseRect(3)/2 && abs(fixError(trial,2)) <=displayInfo.baseRect(3)/2 && buttons(1) == 1 %if error is smaller than fixation radius and pen is touching surface
                            gamephase = 1;                      %move forward to next phase
                            inTimes(trial) = toc - t;           %save time it took to find fixation
                            pause(displayInfo.pauseTime);
                            t = toc;                            %relative time point
                            temp = 0;                           %conditions are met
                            
                        else
                            temp = 1;                           %repeat until conditions are met
                        end
                        Screen('Flip', displayInfo.window);
                    end
                    penLoc = [x,y];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Target Appears %%%%%%%%%%%%%%%%%%%
                elseif gamephase == 1
                    
                    for frame = 1:displayInfo.numFrames         %display target for numFrames seconds
                        Screen('DrawDots', displayInfo.window, [dotXpos dotYpos], displayInfo.dotSizePix, displayInfo.whiteVal, [], 2); %target
                        Screen('DrawDots', displayInfo.window, [x1 y1], displayInfo.dotSizePix, displayInfo.whiteVal, [], 2); %pen
                        Screen('FillRect', displayInfo.window,displayInfo.blackVal, topBuff);
                        Screen('FillRect', displayInfo.window,displayInfo.blackVal, bottomBuff);
                        Screen('FrameOval', displayInfo.window, displayInfo.whiteVal, displayInfo.controlRect, 2,2); %fixation circle
                        Screen('Flip', displayInfo.window);
                        tarAppearTime(trial,1) = toc;
                        
                        [x, y, buttons] = GetMouse(displayInfo.window2); %get pen position
                        [x1, y1] = transformPointsForward(tform,x,y);
                        
                        if ~buttons(1) || sqrt(sum(([x y] - penLoc).^2)) > displayInfo.baseRect(3) %if they lift the pen during target display or move out of circle
                            Screen('FillRect', displayInfo.window,displayInfo.blackVal, topBuff);
                            Screen('FillRect', displayInfo.window,displayInfo.blackVal, bottomBuff);
                            instructions = 'Jumped the gun!';
                            [instructionsX, instructionsY] = centreText(displayInfo.window, instructions, 15);
                            Screen('DrawText', displayInfo.window, instructions, instructionsX, instructionsY-200, displayInfo.whiteVal);
                            Screen('Flip', displayInfo.window);
                            timeFlag = 1;                       %flag for reshuffling of locations when repeated
                            gamephase = 99;                     %restart trial phase
                            pause(displayInfo.iti+.3);
                            break
                        end
                    end
                    t = toc;                                    %relative time point
                    if gamephase == 1
                        while sqrt(sum(([x y] - penLoc).^2)) < displayInfo.baseRect(3) && toc-t<displayInfo.respWindow %while fixation is held and less than .6 seconds has elapsed
                            
                            [x, y, buttons] = GetMouse(displayInfo.window2); %get pen position
                            Screen('DrawDots', displayInfo.window, [dotXpos dotYpos], displayInfo.dotSizePix, displayInfo.dotColor, [], 2); %go cue target
                            Screen('FrameOval', displayInfo.window, displayInfo.whiteVal, displayInfo.controlRect, 2,2); %fixation circle
                            Screen('FillRect', displayInfo.window,displayInfo.blackVal, topBuff);
                            Screen('FillRect', displayInfo.window,displayInfo.blackVal, bottomBuff);
                            Screen('Flip', displayInfo.window);
                        end
                        
                        if  sqrt(sum(([x y] - penLoc).^2)) < displayInfo.baseRect(3) && toc-t > displayInfo.respWindow       %if elapsed time is longer than the response window (.6 seconds)
                            instructions = 'Too slow';
                            [instructionsX instructionsY] = centreText(displayInfo.window, instructions, 15);
                            Screen('DrawText', displayInfo.window, instructions, instructionsX, instructionsY-200, displayInfo.whiteVal);
                            Screen('FillRect', displayInfo.window,displayInfo.blackVal, topBuff);
                            Screen('FillRect', displayInfo.window,displayInfo.blackVal, bottomBuff);
                            Screen('Flip', displayInfo.window);
                            timeFlag = 1;                       %flag for reshuffling of locations when repeated
                            gamephase = 99;                     %restart trial phase
                            pause(displayInfo.iti+.3);
                        else
                            gamephase = 2;                      %if no mistakes are made move to next trial phase
                        end
                        
                    end
                    RTs(trial) = toc-t;                         %elapsed response time
                    t = toc;                                    %relative time point
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Participant Response %%%%%%%%%%%%%%%
                elseif gamephase == 2
                    
                    %%%%%% TABLET POSITION COLLECTION
                    trialLength = displayInfo.respWindow +.2; %record buffer at the end of response time
                    
                    %This loop runs for trialLength seconds.
                    start = GetSecs;
                    stop  = start + trialLength;
                    
                    for frame = 1: framerate * trialLength  %once movement has started and lasts under .6 seconds
                        moveStart(trial,1) = toc;               %movement start time
                        loopStart = GetSecs;
                        
                        [x, y, buttons] = GetMouse(displayInfo.window2);
                        pkt = [x,y,buttons(1), (GetSecs - start), 1];
                        locdiff = sqrt(sum((pktData(end,1:2) - pkt(1:2)).^2));
                        [x1 y1] = transformPointsForward(displayInfo.tform,x,y);
                        locDist = sqrt(sum(([x1 y1] - [displayInfo.xCenter, displayInfo.screenYpixels-175]).^2));
                        pktData = [pktData; pkt];
                        if locDist >= sqrt(sum((targetLoc - startPos).^2))
                            pktData(end,5) = 2;
                        end
                        if locdiff < 1
                            pktData(end,5) = 0;
                            break
                        end
                        
                        if bb > 1
                            clampPos= [(locDist*cosd(-errorClamp(trial)))+displayInfo.xCenter (locDist*sind(-errorClamp(trial)))+displayInfo.screenYpixels-175];
                            xClamp = clampPos(1);
                            yClamp = clampPos(2);
                            
                            if frame <= framerate * trialLength
                                Screen('DrawDots', displayInfo.window, [dotXpos dotYpos], displayInfo.dotSizePix, displayInfo.dotColor, [], 2);
                                Screen('FrameOval', displayInfo.window, displayInfo.whiteVal, displayInfo.controlRect, 2,2); %fixation circle
                                Screen('FillRect', displayInfo.window,displayInfo.blackVal, topBuff);
                                Screen('FillRect', displayInfo.window,displayInfo.blackVal, bottomBuff);
                                Screen('DrawDots', displayInfo.window, [xClamp yClamp], displayInfo.dotSizePix, displayInfo.dotColor, [], 2);
                                Screen('Flip', displayInfo.window);
                            end
                        elseif trial<=20 && bb == 1
                            if frame <= framerate * trialLength
                                Screen('DrawDots', displayInfo.window, [dotXpos dotYpos], displayInfo.dotSizePix, displayInfo.dotColor, [], 2);
                                Screen('FrameOval', displayInfo.window, displayInfo.whiteVal, displayInfo.controlRect, 2,2); %fixation circle
                                Screen('FillRect', displayInfo.window,displayInfo.blackVal, topBuff);
                                Screen('FillRect', displayInfo.window,displayInfo.blackVal, bottomBuff);
                                Screen('DrawDots', displayInfo.window, [x1 y1], displayInfo.dotSizePix, displayInfo.dotColor, [], 2);
                                Screen('Flip', displayInfo.window);
                            end
                            reportArc(trial,:) = [0; 0];
                            reportAngle(trial) = 0;
                            arcStartIdx(trial) = 0;
                            pointsEarned(trial,1) = 0;
                        else
                            if frame <= framerate * trialLength
                                Screen('DrawDots', displayInfo.window, [dotXpos dotYpos], displayInfo.dotSizePix, displayInfo.dotColor, [], 2);
                                Screen('FrameOval', displayInfo.window, displayInfo.whiteVal, displayInfo.controlRect, 2,2); %fixation circle
                                Screen('FillRect', displayInfo.window,displayInfo.blackVal, topBuff);
                                Screen('FillRect', displayInfo.window,displayInfo.blackVal, bottomBuff);
                                Screen('Flip', displayInfo.window);
                            end
                        end
                    end
                    pktData2 = pktData(2:end,:);  %Assemble the data and then transpose to arrange data in columns because of Matlab memory preferences
                    pktData = zeros(1,5);
                    pktData2 = [pktData2 trial*ones(size(pktData2,1),1)];
                    
                    if sum(pktData2(:,1)) == 0
                        ShowCursor;
                        instructions = 'Wacom not recording data! Restart!';
                        [instructionsX instructionsY] = centreText(displayInfo.window, instructions, 15);
                        Screen('DrawText', displayInfo.window, instructions, instructionsX, instructionsY, displayInfo.whiteVal);
                        Screen('Flip', displayInfo.window);
                        error('Wacom not recording data! Restart!');
                        break
                    end
                    tabletData = [tabletData; pktData2;];
                    
                    Screen('FillRect', displayInfo.window,displayInfo.blackVal, topBuff);
                    Screen('FillRect', displayInfo.window,displayInfo.blackVal, bottomBuff);
                    Screen('Flip', displayInfo.window);
                    
                    
                    if sum(pktData2(:,5)== 0)>=1
                        tempX = pktData2(find(pktData2(:,5) == 0,1,'first'),1); %find X location at stopping point
                        tempY = pktData2(find(pktData2(:,5) == 0,1,'first'),2); %find Y location at stopping point
                    else
                        tempX = pktData2(end,1); %find X location at stopping point
                        tempY = pktData2(end,2); %find Y location at stopping point
                    end
                    [tempEP(1) tempEP(2)] = transformPointsForward(displayInfo.tform,tempX,tempY);
                    
                    %calculate reach endpoint angle
                    radius = sqrt(sum((targetLoc - startPos).^2)); %radius
                    reachDist = sqrt(sum((tempEP - startPos).^2)); %hypotenus
                    zeroAngle = sqrt(sum((tempEP - [startPos(1)+radius startPos(2)]).^2)); %opposite
                    endPtAngle(trial) = real(acosd((radius^2 + reachDist^2 - zeroAngle^2)/(2*radius*reachDist))); %angle in degrees
                    endPointLine(trial,:) = [(radius*cosd(360-endPtAngle(trial)))+startPos(1) (radius*sind(360-endPtAngle(trial))+startPos(2))];
                    
                    
                    if sum(pktData2(:,5)== 2)<1 || pktData2(min(find(pktData2(:,5) == 2)),4) > trialLength -.2         %if movement was longer than .8 seconds
                        instructions = 'Too slow';
                        [instructionsX instructionsY] = centreText(displayInfo.window, instructions, 15);
                        Screen('DrawText', displayInfo.window, instructions, instructionsX, instructionsY-200, displayInfo.whiteVal);
                        Screen('FillRect', displayInfo.window,displayInfo.blackVal, topBuff);
                        Screen('FillRect', displayInfo.window,displayInfo.blackVal, bottomBuff);
                        Screen('Flip', displayInfo.window);
                        timeFlag = 1;                           %flagging for reshuffling of locations on repeat
                        gamephase = 99;                         %restart trial phase
                        pause(displayInfo.iti+.3);
                    end
                    if (sum(pktData2(:,3) == 0)) > 1            %if they picked up their hand
                        
                        instructions = 'Do not pick up hand during reach!';
                        [instructionsX instructionsY] = centreText(displayInfo.window, instructions, 15);
                        Screen('DrawText', displayInfo.window, instructions, instructionsX, instructionsY-200, displayInfo.whiteVal);
                        Screen('FillRect', displayInfo.window,displayInfo.blackVal, topBuff);
                        Screen('FillRect', displayInfo.window,displayInfo.blackVal, bottomBuff);
                        Screen('Flip', displayInfo.window);
                        timeFlag = 1;                           %flagging for reshuffling of locations on repeat
                        gamephase = 99;                         %restart trial phase
                        pause(displayInfo.iti+.5);
                    end
                    MTs(trial) = toc - t;                       %elapsed movement time
                    moveEnd(trial,1) = toc;                     %movement end timing saved
                    
                    if gamephase ~= 99
                        if sum(pktData2(:,5)== 0)>=1
                            wX = pktData2(find(pktData2(:,5) == 0,1,'first'),1); %find X location at stopping point
                            wY = pktData2(find(pktData2(:,5) == 0,1,'first'),2); %find Y location at stopping point
                        else
                            wX = pktData2(end,1); %find X location at stopping point
                            wY = pktData2(end,2); %find Y location at stopping point
                        end
                        wXwY(trial,1) = wX; wXwY(trial,2) = wY;
                        [endPointWac(trial,1) endPointWac(trial,2)] = transformPointsForward(displayInfo.tform,wX,wY); %transform into projector space
                        
                        gamephase = 3;
                        t = toc;                                %relative time point
                    end
                    pktData3 = [pktData3; pktData2];
                    clear pktData2
                    
                    
                    arcStart(trial) = 0;
                    confTime(trial) = 0;                           %elapsed time for rating to be set
                    confAngle(trial,1) = 0;
                    %pointsEarned(trial) = 0;
                    blockScore(bb) = 0;       %score for this block
                    runningScore(bb) = 0;                       %running score across all blocks
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Reporting End Point %%%%%%%%%%%%%%%%%
                elseif (gamephase == 3 && displayInfo.confType == 1) || (gamephase == 3 && bb == 1)
                    if trial > 20
                        
                        %%%%%%%%%%%%%%%%%%%% Report Locations in Tablet Space %%%%%%%%%%%%%%
                        theta = (180:.1:360).*pi/180;          %report locations in half circle, step sizes for dial
                        x = radius*cos(theta);
                        y = radius*sin(theta);
                        reportLocs = [x+startPos(1);(y+startPos(2))]; %target locations in PIXEL space
                        
                        %feedback report start location
                        [buttonPM, dialPos] = PsychPowerMate('Get',pm); %initalize powermate
                        startDial = dialPos;                        %get dial's starting position
                        arcStartIdx(trial) = randi([800,1000],1);               %set arc degrees to start (randomly)
                        
                        
                        %while dial is spinning to report endpoint
                        while ~buttonPM                             %until button on dial is pressed
                            
                            [buttonPM, dialPos] = PsychPowerMate('Get',pm); %get dial postion
                            
                            loc = arcStartIdx(trial) + (dialPos-startDial);
                            if loc > 1800
                                loc = 1800;
                            elseif loc < 1
                                loc = 1;
                            end
                            
                            reportArc(trial,:) = reportLocs(:,loc); %arc size adjusted for starting dial postion
                            
                            Screen('DrawDots', displayInfo.window, reportArc(trial,:), displayInfo.dotSizePix, displayInfo.whiteVal, [], 2);
                            Screen('DrawDots', displayInfo.window, [dotXpos dotYpos], displayInfo.dotSizePix, displayInfo.dotColor, [], 2); %go cue target
                            Screen('FrameOval', displayInfo.window, displayInfo.whiteVal, displayInfo.controlRect, 2,2); %fixation circle
                            Screen('FillRect', displayInfo.window,displayInfo.blackVal, topBuff);
                            Screen('FillRect', displayInfo.window,displayInfo.blackVal, bottomBuff);
                            instructions = 'Use dial to report perceived endpoint';
                            [instructionsX instructionsY] = centreText(displayInfo.window, instructions, 15);
                            Screen('DrawText', displayInfo.window, instructions, instructionsX, instructionsY-240, displayInfo.whiteVal);
                            Screen('Flip', displayInfo.window);
                            
                            [x, y, buttons] = GetMouse(displayInfo.window2);
                            if ~buttons(1)            %if they picked up their hand
                                instructions = 'Do not pick up while reporting endpoint!';
                                [instructionsX instructionsY] = centreText(displayInfo.window, instructions, 15);
                                Screen('DrawText', displayInfo.window, instructions, instructionsX, instructionsY-200, displayInfo.whiteVal);
                                Screen('FillRect', displayInfo.window,displayInfo.blackVal, topBuff);
                                Screen('FillRect', displayInfo.window,displayInfo.blackVal, bottomBuff);
                                Screen('Flip', displayInfo.window);
                                
                                timeFlag = 1;                           %flagging for reshuffling of locations on repeat
                                gamephase = 99;                         %restart trial phase
                                pause(displayInfo.iti+.5);
                                break
                            end
                        end
                        endPtReportTime(trial) = toc - t;
                        
                        %calculate reach endpoint angle
                        radius = sqrt(sum((targetLoc - startPos).^2)); %radius
                        reachDist = sqrt(sum((reportArc(trial,:) - startPos).^2)); %hypotenus
                        zeroAngle = sqrt(sum((reportArc(trial,:) - [startPos(1)+radius startPos(2)]).^2)); %opposite
                        reportAngle(trial) = 90-( real(acosd((radius^2 + reachDist^2 - zeroAngle^2)/(2*radius*reachDist)))); %angle in degrees
                        if displayInfo.confType == 1
                            gamephase = 4;
                        else
                            gamephase = 5;
                        end
                        t = toc; %relative time point
                        
                    else
                        gamephase = 5;
                    end
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Confidence report
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% motor awareness
                elseif gamephase == 4 && displayInfo.confType == 1
                    if bb > 1
                        pause(.6);
                        clear buttonPM dialPos;
                        [buttonPM, dialPos] = PsychPowerMate('Get',pm); %initalize powermate
                        startDial = dialPos;                        %get dial's starting position
                        arcStart(trial) = randi([1,10],1);               %set arc degrees to start (randomly)
                        
                        while ~buttonPM                             %until button on dial is pressed
                            
                            [buttonPM, dialPos] = PsychPowerMate('Get',pm); %get dial postion
                            
                            arcSize(trial) = (arcStart(trial) + (dialPos-startDial))/5; %arc size adjusted for starting dial postion
                            baseRect3 = [0 0 radius*2 radius*2] ;
                            
                            centeredRect3 = CenterRectOnPointd(baseRect3, startPos(1), startPos(2));
                            
                            %points to circle size calculation
                            if abs(arcSize(trial)) > 5.15                 %if the arc is larger than the target quadrant
                                pointsPos = 0;
                            elseif abs(arcSize(trial)) <= .15           %if the radius is smaller than the target size
                                pointsPos = 10;
                            else
                                pointsPos = 10.3-(abs(arcSize(trial))*2); %10 points are possible across a 150 pixel radius
                                
                            end
                            
                            Screen('DrawArc',displayInfo.window, displayInfo.rectColor,centeredRect3,reportAngle(trial),arcSize(trial))
                            Screen('DrawArc',displayInfo.window, displayInfo.rectColor,centeredRect3,reportAngle(trial)-arcSize(trial),arcSize(trial))
                            Screen('FrameOval', displayInfo.window, displayInfo.whiteVal, displayInfo.controlRect, 2,2); %fixation circle
                            Screen('FillRect', displayInfo.window,displayInfo.blackVal, topBuff);
                            Screen('FillRect', displayInfo.window,displayInfo.blackVal, bottomBuff);
                            instructions = 'Confidence arc is centered on indicated endpoint, make arc just large enough to intersect true endpoint - smaller arc = closer to goal';
                            [instructionsX] = centreText(displayInfo.window, instructions, 15);
                            instructions1 = 'Points only collected if final arc size would intersect the endpoint';
                            [instructions1X] = centreText(displayInfo.window, instructions1, 15);
                            points = ['Points possible: ' num2str(pointsPos)];
                            [pointsX, pointsY] = centreText(displayInfo.window, points, 15);
                            Screen('DrawText', displayInfo.window, instructions, instructionsX, displayInfo.yCenter-280, displayInfo.whiteVal);
                            Screen('DrawText', displayInfo.window, instructions1, instructions1X, displayInfo.yCenter-240, displayInfo.whiteVal);
                            Screen('DrawText', displayInfo.window, points, pointsX, pointsY-200, displayInfo.whiteVal);
                            Screen('Flip', displayInfo.window);
                            
                            [x, y, buttons] = GetMouse(displayInfo.window2); %get pen position
                            [x1, y1] = transformPointsForward(tform,x,y);
                            epError(trial,1) = x1-endPointWac(trial,1); epError(trial,2) = y1-endPointWac(trial,2); %fixation check (must be inside circle)
                            
                            if abs(epError(trial,1)) >= 20 || abs(epError(trial,2)) >= 20
                                alert = 'Do not move pen from reach endpoint location!';
                                [alertX, alertY] = centreText(displayInfo.window, alert, 15);
                                Screen('DrawText', displayInfo.window, alert, alertX, alertY-200, displayInfo.whiteVal);
                                Screen('FillRect', displayInfo.window,displayInfo.blackVal, topBuff);
                                Screen('FillRect', displayInfo.window,displayInfo.blackVal, bottomBuff);
                                Screen('Flip', displayInfo.window);
                                timeFlag = 1;                           %flagging for reshuffling of locations on repeat
                                gamephase = 99;                         %restart trial phase
                                pause(displayInfo.iti+.5);
                                break
                            end
                            
                        end
                        if gamephase ~= 99
                            confTime(trial) = toc - t;                           %elapsed time for rating to be set
                            confAngle(trial,1) = abs(arcSize(1,trial))*2;          %angle of confidence arc
                            
                            %Points distribution based on perturbed endpoint.
                            if confAngle(trial,1)/2 >= abs(endPtAngle(trial)-90-(-reportAngle(trial))) %-4 to crop at edge of dot
                                pointsEarned(trial,1) = pointsPos;
                            else
                                pointsEarned(trial,1) = 0;
                            end
                            pointsPossible(trial) = pointsPos;
                            
                            clear buttonPM
                            pause(displayInfo.pauseTime)
                            
                            gamephase = 5;                              %move on to final trial phase
                            
                        end
                    else
                        gamephase = 5;
                    end
                    
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Confidence Report on target %%%%%%%%%%%%%%%%%
                elseif gamephase == 3 && displayInfo.confType == 2
                    if bb > 1
                        
                        radius = sqrt(sum((targetLoc - startPos).^2)); %radius
                        [buttonPM, dialPos] = PsychPowerMate('Get',pm); %initalize powermate
                        startDial = dialPos;                        %get dial's starting position
                        arcStart(trial) = randi([1,10],1);              %set arc degrees to start (randomly)
                        
                        while ~buttonPM                             %until button on dial is pressed
                            
                            [buttonPM, dialPos] = PsychPowerMate('Get',pm); %get dial postion
                            
                            arcSize(trial) = (arcStart(trial) + (dialPos-startDial))/5; %arc size adjusted for starting dial postion
                            baseRect3 = [0 0 radius*2 radius*2] ;
                            
                            centeredRect3 = CenterRectOnPointd(baseRect3, startPos(1), startPos(2));
                            
                            %points to circle size calculation
                            
                            if abs(arcSize(trial)) > 10.15                 %if the arc is larger than the target quadrant
                                pointsPos = 0;
                            elseif abs(arcSize(trial)) <= .15           %if the radius is smaller than the target size
                                pointsPos = 10;
                            else
                                pointsPos = 10.15-(abs(arcSize(trial)));
                            end
                            
                            Screen('DrawArc',displayInfo.window, displayInfo.rectColor,centeredRect3,0,arcSize(trial))
                            Screen('DrawArc',displayInfo.window, displayInfo.rectColor,centeredRect3,0-arcSize(trial),arcSize(trial))
                            Screen('FrameOval', displayInfo.window, displayInfo.whiteVal, displayInfo.controlRect, 2,2)%fixation circle
                            Screen('FillRect', displayInfo.window,displayInfo.blackVal, topBuff);
                            Screen('FillRect', displayInfo.window,displayInfo.blackVal, bottomBuff);
                            instructions = 'Confidence arc is centered on target, make arc just large enough to intersect feedback - smaller arc = closer to goal';
                            [instructionsX] = centreText(displayInfo.window, instructions, 15);
                            instructions1 = 'Points only collected if final arc size would intersect the feedback';
                            [instructions1X] = centreText(displayInfo.window, instructions1, 15);
                            points = ['Points possible: ' num2str(pointsPos)];
                            [pointsX, pointsY] = centreText(displayInfo.window, points, 15);
                            Screen('DrawText', displayInfo.window, instructions, instructionsX, displayInfo.yCenter-280, displayInfo.whiteVal);
                            Screen('DrawText', displayInfo.window, instructions1, instructions1X, displayInfo.yCenter-240, displayInfo.whiteVal);
                            Screen('DrawText', displayInfo.window, points, pointsX, pointsY-200, displayInfo.whiteVal);
                            Screen('Flip', displayInfo.window);
                            
                            [x, y, buttons] = GetMouse(displayInfo.window2); %get pen position
                            [x1, y1] = transformPointsForward(tform,x,y);
                            epError(trial,1) = x1-endPointWac(trial,1); epError(trial,2) = y1-endPointWac(trial,2); %fixation check (must be inside circle)
                            
                            if abs(epError(trial,1)) >= 20 || abs(epError(trial,2)) >= 20
                                alert = 'Do not move pen from reach endpoint location!';
                                [alertX, alertY] = centreText(displayInfo.window, alert, 15);
                                Screen('DrawText', displayInfo.window, alert, alertX, alertY-200, displayInfo.whiteVal);
                                Screen('FillRect', displayInfo.window,displayInfo.blackVal, topBuff);
                                Screen('FillRect', displayInfo.window,displayInfo.blackVal, bottomBuff);
                                Screen('Flip', displayInfo.window);
                                timeFlag = 1;                           %flagging for reshuffling of locations on repeat
                                gamephase = 99;                         %restart trial phase
                                pause(displayInfo.iti+.5);
                                break
                            end
                            
                        end
                        
                        if gamephase ~= 99
                            confTime(trial) = toc - t;                           %elapsed time for rating to be set
                            confAngle(trial,1) = abs(arcSize(trial))*2;          %angle of confidence arc
                            
                            %Points distribution based on perturbed endpoint.
                            if confAngle(trial,1)/2 >= abs(endPtAngle(trial)-90) 
                                pointsEarned(trial,1) = pointsPos;
                            else
                                pointsEarned(trial,1) = 0;
                            end
                            pointsPossible(trial) = pointsPos;
                            clear buttonPM
                            pause(displayInfo.pauseTime)
                            
                            gamephase = 5;                              %move on to final trial phase
                            
                        end
                    else
                        gamephase = 5;
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% End of Trial %%%%%%%%%%%%%%%%%%%
                elseif gamephase == 5
                    
                    clear buttons;
                    %[pointsEarned(trial),confAngle(trial),endPtAngle(trial)-90,reportAngle(trial)]
                    
                    if jj == displayInfo.numTrials(bb)          %if this is last trial
                        instructions = 'End of Block';
                        [instructionsX instructionsY] = centreText(displayInfo.window, instructions, 15);
                        Screen('DrawText', displayInfo.window, instructions, instructionsX, instructionsY, displayInfo.whiteVal);
                        trialNum(trial) = trial;                %save trial number
                        trial = trial+1;                        %update trial counter
                        gamephase = 6;                          %signal end of trial
                        jj = jj + 1;
                    else
                        instructions = 'Get ready for next trial';
                        [instructionsX instructionsY] = centreText(displayInfo.window, instructions, 15);
                        Screen('DrawText', displayInfo.window, instructions, instructionsX, instructionsY, displayInfo.whiteVal);
                        trialNum(trial) = trial;
                        trial = trial+1;
                        gamephase = 6;
                        jj = jj+1;
                    end
                    % Flip to the screen
                    Screen('FillRect', displayInfo.window,displayInfo.blackVal, topBuff);
                    Screen('FillRect', displayInfo.window,displayInfo.blackVal, bottomBuff);
                    Screen('Flip', displayInfo.window);
                    pause(displayInfo.iti);
                    
                elseif gamephase == 99                          %flagged as a repeat trial
                    9999999                                     %visual output for testing
                    gamephase = 0;                              %reset trial phase for restart
                    instructions = 'Get ready for next trial';
                    [instructionsX instructionsY] = centreText(displayInfo.window, instructions, 15);
                    Screen('DrawText', displayInfo.window, instructions, instructionsX, instructionsY, displayInfo.whiteVal);
                    Screen('FillRect', displayInfo.window,displayInfo.blackVal, topBuff);
                    Screen('FillRect', displayInfo.window,displayInfo.blackVal, bottomBuff);
                    Screen('Flip', displayInfo.window);
                    pause(displayInfo.iti);
                end
            end
            gamephase = 0; %reset trial phase at the end of trial
        end
        
    end
    jj = 0;                     %reset trial counter at end of block
    
    motorError = std(endPtAngle(~isoutlier(endPtAngle)));
    %blockScore(bb) = sum(pointsEarned) - sum(blockScore);       %score for this block
    runningScore(bb) = sum(pointsEarned);                       %running score across all blocks
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%% Save output %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    errResultsMat.trialNum = trialNum;
    errResultsMat.targetLoc = targetLoc;
    errResultsMat.targetDist = radius;
    errResultsMat.startPos = startPos;
    errResultsMat.errorClamp = errorClamp;
    errResultsMat.wacEndPoint = wXwY;
    errResultsMat.wacScreenEnd = endPointWac;
    errResultsMat.endPtAngle = endPtAngle;
    errResultsMat.endPointLine = endPointLine;
    errResultsMat.motorError = motorError;
    errResultsMat.reportArc = reportArc;
    errResultsMat.reportAngle = -reportAngle; %negative to match reach angles
    errResultsMat.arcStartIdx = arcStartIdx;
    errResultsMat.confAngle = confAngle;
    errResultsMat.arcStart = arcStart;
    errResultsMat.tarAppearTime = tarAppearTime;
    errResultsMat.moveStart = moveStart;
    errResultsMat.moveEnd = moveEnd;
    errResultsMat.startTimes = startTimes;
    errResultsMat.inTimes = inTimes;
    errResultsMat.confTime = confTime;
    errResultsMat.endPtReportTime = endPtReportTime;
    errResultsMat.RTs = RTs;
    errResultsMat.MTs = MTs;
    errResultsMat.pointsEarned = pointsEarned;
    errResultsMat.pointsPossible = pointsPossible;
    errResultsMat.blockScore = blockScore;
    errResultsMat.runningScore = runningScore;
    
    errResultsMat.xPos = tabletData(:,1);
    errResultsMat.yPos = tabletData(:,2);
    errResultsMat.buttonState = tabletData(:,3);
    errResultsMat.getsecTimeStamp = tabletData(:,4);
    
    errResultsMat.tabletData = tabletData;
    errResultsMat.pktData = pktData3;
    save([displayInfo.fSaveFile,'_errresults.mat'],'errResultsMat');
    
    if bb > 1
        %% %%%%%%%%%%%%%%%%%%%%%%%%% END OF BLOCK LEADERBORAD %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        [names,points] = addToLeaderboard(['perturbExp_block_',num2str(bb)],displayInfo.subj,runningScore(end));
        
        KbName('UnifyKeyNames');
        spaceKeyID = KbName('space');
        ListenChar(2);
        
        instructions = ['End of block ',num2str(bb),'. Press space to continue'];
        [instructionsX instructionsY] = centreText(displayInfo.window, instructions, 15);
        Screen('DrawText', displayInfo.window, instructions, instructionsX, instructionsY-200, displayInfo.whiteVal);
        
        leader = ('------ Leader Board ------');
        [leaderX leaderY] = centreText(displayInfo.window, leader, 20);
        Screen('DrawText', displayInfo.window, leader, leaderX, leaderY-50, displayInfo.whiteVal);
        
        line1 = [names{1} ':   1st Place'];
        [line1X line1Y] = centreText(displayInfo.window, line1, 15);
        Screen('DrawText', displayInfo.window, line1, line1X, line1Y, displayInfo.whiteVal);
        
        line2 = [names{2} ':   2nd Place'];
        [line2X line2Y] = centreText(displayInfo.window, line2, 15);
        Screen('DrawText', displayInfo.window, line2, line2X, line2Y+20, displayInfo.whiteVal);
        
        line3 = [names{3} ':   3rd Place'];
        [line3X line3Y] = centreText(displayInfo.window, line3, 15);
        Screen('DrawText', displayInfo.window, line3, line3X, line3Y+40, displayInfo.whiteVal);
        
        line4 = [names{4} ':   4th Place'];
        [line4X line4Y] = centreText(displayInfo.window, line4, 15);
        Screen('DrawText', displayInfo.window, line4, line4X, line4Y+60, displayInfo.whiteVal);
        
        if ~strcmp(names{1},displayInfo.subj) && ~strcmp(names{2},displayInfo.subj) && ~strcmp(names{3},displayInfo.subj) && ~strcmp(names{4},displayInfo.subj)
            line5 = [displayInfo.subj ':   5th Place'];
        else
            line5 = [names{5} ':   5th Place'];
        end
        [line5X line5Y] = centreText(displayInfo.window, line5, 15);
        Screen('DrawText', displayInfo.window, line5, line5X, line5Y+80, displayInfo.whiteVal);
        
        Screen('FillRect', displayInfo.window,displayInfo.blackVal, topBuff);
        Screen('FillRect', displayInfo.window,displayInfo.blackVal, bottomBuff);
        Screen('Flip', displayInfo.window);
        
        pause(1);
        %Waits for space bar
        [keyIsDown, secs, keyCode] = KbCheck;
        while keyCode(spaceKeyID)~=1
            [keyIsDown, secs, keyCode] = KbCheck;
        end
        ListenChar(1);
        
    end
    pause(1);
    if bb < 6
        %End of block screen
        KbName('UnifyKeyNames');
        spaceKeyID = KbName('space');
        ListenChar(2);
        
        instructions = 'Press space bar to start next block';
        [instructionsX instructionsY] = centreText(displayInfo.window, instructions, 15);
        Screen('DrawText', displayInfo.window, instructions, instructionsX, instructionsY-200, displayInfo.whiteVal);
        
        Screen('FillRect', displayInfo.window,displayInfo.blackVal, topBuff);
        Screen('FillRect', displayInfo.window,displayInfo.blackVal, bottomBuff);
        Screen('Flip', displayInfo.window);
        
        %Waits for space bar
        [keyIsDown, secs, keyCode] = KbCheck;
        while keyCode(spaceKeyID)~=1
            [keyIsDown, secs, keyCode] = KbCheck;
        end
        ListenChar(1);
    end
end
%% %%%%%%%%%%%%%%%%%%%%%%%%% FINAL SCREEN %%%%%%%%%%%%%%%%%%%%%%%%%%%

KbName('UnifyKeyNames');
spaceKeyID = KbName('space');
ListenChar(2);

instructions = 'End of Experiment - Thank you for participating!';
[instructionsX instructionsY] = centreText(displayInfo.window, instructions, 15);
Screen('DrawText', displayInfo.window, instructions, instructionsX, instructionsY-200, displayInfo.whiteVal);

Screen('Flip', displayInfo.window);

%Waits for space bar
[keyIsDown, secs, keyCode] = KbCheck;
while keyCode(spaceKeyID)~=1
    [keyIsDown, secs, keyCode] = KbCheck;
end
ListenChar(1);
end



