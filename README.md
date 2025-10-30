# implicitAdaptation
Data and code for 'Implicit adaptation’s effect on sensorimotor and motor confidence' manuscript

### Abstract
Sensorimotor adaptation is essential for maintaining movement accuracy; it seeks to minimize the effects of external perturbations. It can occur explicitly, by adjusting the intended motor plan to overcome task errors, or implicitly, by automatically and incrementally calibrating the sensorimotor mapping (while the motor plan remains stable).  While explicit adaptation has been shown to reduce sensorimotor confidence (confidence in the success of a motor action with a sensory-directed goal), it remains unknown if the operation of implicit adaptation also affects confidence in one’s sensorimotor or motor awareness judgments. Participants made a slicing reach through a visual target with an unseen hand. We provided “error-clamped feedback”: visual feedback of radial hand position moved forward with the hand but went in a fixed direction independent of hand position, which participants were instructed to ignore. Error-clamp direction varied over trials (sinusoid, amplitude +/-10 deg, 12 cycles/session). They reported perceived hand direction and reported confidence by adjusting the length of an arc centered on the reported end point direction or target position depending on the session, with larger arcs reflecting lower confidence. Points were awarded if the arc encompassed the true reach direction; fewer points for larger arcs. This incentivized attentive confidence report and minimizing direction-report error. A leaderboard was presented every 50 trials. No other feedback was provided. A significant 12 cycle/session Fourier component in reach direction provides strong evidence for implicit adaptation from the error clamp. The same frequency component was also obtained for reported reach direction. Thus, while adaptation is unconscious, a mismatch is created between the motor plan (reach for the target) and proprioceptive signal (implicitly adapted), resulting in a judgment of an unsuccessful reach. However, confidence judgments of sensorimotor and motor awareness were not always affected by adaptation, indicating that sensorimotor confidence and confidence in one’s own proprioceptive measurements are calculated differently. 


### Participants
Twenty individuals were selected from the New York University student body (average age: 27.3 years, SD: 4.8 years, 10 males, one left-handed). None of the participants were familiar with the experimental design. All participants had either normal or corrected-to-normal vision, no restrictions on their right arm’s mobility, and reported no motor abnormalities. All participants completed both the motor-awareness and sensorimotor tasks across two sessions.

### Experimental Files
The experimental set up involves a Wacom Cintiq 22 tablet placed on a table below a projector.
The experimental code runs under the assumption there are 3 screens in use (main computer, tablet and projector). 
PsychToolBox runs all visualizations through Matlab

Data is collected through the pen position via GetMouse() and with a Griffin PowerMate control knob using PsychPowerMate()

'errorClampExpCode.m' is the main shell for running the experiment. This is where you can enter the participant specifications and request the
control experiment or practice trials. This calls all the other functions in the file accordingly. 

### Analysis
The main analysis is run using a Fourier analysis on the confidence reports for the sensorimotor task, and for the hand position reports and associated confidence for the motor-awareness task. 
All relevant files are in the 'data' folder but to follow the process yourself run the files in this order:
1: dataProcessingSaveFiles.m (processes and centers raw data)
2: clampFitSigmaP.m (runs fit on control experiment) 
3: confPermuteFFT.m & reportPermuteFFT.m (runs a permutation test for significant Fourier components) 

Other analysis files have been includes to check some behavioral aspects of the data and look at simulations. 

