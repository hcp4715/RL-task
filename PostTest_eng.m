function [rslt,aborted] = PostTest_eng(subj,expe)

%  Post learning stimuli choice
%  Stefano Palminteri and Dejan Draschkow: 2013
% Modified VS September 2016 

% ==================================
% condition 1 = Rew Fc
% condition 2 = Rew Cf
% condition 3 = Pun Fc
% condition 4 = Pun Cf
% ===================================


if isempty(subj) 
    argindlg = inputdlg({'Subject number ?'},'POSTTEST',1,{'','','','',''})
    nsub=str2double(argindlg{1});
else
    nsub = subj; 
end


if isempty(expe)
    argindlg = inputdlg({'Load main experiment?'},'POSTTEST',1,{'','','','',''})
    loadexp=str2double(argindlg{1});
    
    if loadexp == 1
        resultname2=strcat('Sub',num2str(nsub),'_Session',num2str(last));
        
        filename = sprintf('./Data/S%02d/CRL_S%02d.mat',subj,subj);
        if exist(filename)
        load(filename); 
        else
            error('Data file doesnt exist!\n'); 
        end
    else
        error('no main experiment provided, exiting\n')
    end
    
end


% Take the last session of the experiment: the default the last session = 2nd session  
if ~isempty(expe.rslt.data{2})
    last = 2; 
    fprintf('taking the second session\n'); 
else
    argindlg = inputdlg({'Last session number?'},'POSTTEST',1,{'','','','',''})
    last=str2double(argindlg{1});
end 


stimuli = expe.rslt.stimuli{last}; 

% cogent parameters
%config_display(0,2,[0 0 0],[1 1 1], 'Arial', 55, 1);    % easier to work on - window mode
config_display(1,3,[0 0 0],[1 1 1], 'Arial', 55, 1);    
config_log;
config_keyboard(100,5,'exclusive');

% generator reset
rand('state',sum(100*clock));

start_cogent;

% load feedback screens 
memfeedback1 = loadpict('memfeedback1_screen_eng.bmp');
memfeedback2 = loadpict('memfeedback2_screen_eng.bmp');
memfeedback3 = loadpict('memfeedback3_screen_eng.bmp');

dfeedback1 = loadpict('rewfeedback_screen_eng.bmp');
dfeedback2 = loadpict('punfeedback_screen_eng.bmp');
dfeedback3 = loadpict('neutfeedback_screen_eng.bmp');

face1 = loadpict('neutralface.png'); % neutral
face2 = loadpict('smilingface.png'); % positive 
face3 = loadpict('smilingface2.png'); % very positive 

% loading images                
cross=loadpict('Cross.bmp');
prepscr = loadpict('test2_screen_eng.bmp'); 
finalscr = loadpict('final_screen_eng.bmp'); 
framescr = loadpict('frame2_blue.png'); 


for i=1:8;
    stimulus{i}=loadpict(stimuli{i});
end
% you have to display it following the trials defined in the
% matrix defining the stimuli per trial (3*random3, scrambled) 

% In this matrix there are two columns-left column correspond to left side
% In image display you should keep in mind the fact that in the stimuli cell
% vector (the one retrieved from the last version), you should know which 
% stimulus was associated with the corresponding outcome.

%creating all possible combinations for the different pairs, i.e. AB AC AD
random1(1:7)  =1;
random1(8:13) =2;
random1(14:18)=3;
random1(19:22)=4;
random1(23:25)=5;
random1(26:27)=6;
random1(28)   =7;

random2(1:7)  =2:8;
random2(8:13) =3:8;
random2(14:18)=4:8;
random2(19:22)=5:8;
random2(23:25)=6:8;
random2(26:27)=7:8;
random2(28)   =8:8;
comparisons=[random1 random1 random2 random2; random2 random2 random1 random1]'


index=randperm(112);

for i=1:112
comparisons2(i,:)=comparisons(index(i),:);
end



totaltrial=112;                  


% data to save
subject(1:totaltrial)=nsub;
trial=1:totaltrial;
compare = comparisons2';
checktime=zeros(1,totaltrial);
side=zeros(1,totaltrial);
rt=zeros(1,totaltrial);

% parameters
fixationtime=500;
sidetime=500;
ITItime=1000;
leftkey=97;         % left alt
rightkey=98;         % right alt
% leftkey=60;           % left alt
% rightkey=90;          % right alt
keyquit=52;           % ESCAPE key to quit the session

setforecolour(1,0,0);

%  preparation screen during the instruction phase 2 
% ready to start

preparepict(prepscr,1,0,140);
preparestring('START',1,0,0);
drawpict(1);

waitkeydown(inf);%, [leftkey,rightkey]
clearpict(1,0,0,0);

% setforecolour(1,0,0);
% preparestring('Quel est le meilleur simbol',1,0,0);
% drawpict(1);
% waitkeydown(inf);%, [leftkey,rightkey]
% clearpict(1,0,0,0);


% behavioural task
setforecolour(1,0,0);
counter=zeros(1,4);
choice=zeros(1,totaltrial);         

aborted = false; 

for ntrial = 1:totaltrial
    
    
    
%    fixation
    preparepict(cross,1,0,0);
    preparepict(framescr,1,-200,0);
    preparepict(framescr,1,200,0);
    
    drawpict(1);
    wait(fixationtime);
    
 %   stimuli
    
    preparepict(stimulus{comparisons2(ntrial,1)},1,-200,0);
    preparepict(stimulus{comparisons2(ntrial,2)},1,200,0);
    
    clearkeys;
    startime=drawpict(1);
    checktime(ntrial)=time;
    % response self paced
    
    [keydown,timedown,numberdown] = waitkeydown(inf,[leftkey rightkey keyquit]); 

    % create reaction times and string that remembers which key is pressed
    rt(ntrial)=timedown(end)-startime;
    if keydown(numberdown)==rightkey;
        choice(ntrial)=1;
    elseif keydown(numberdown)==leftkey;
        choice(ntrial)=-1;
    elseif keydown(numberdown)== keyquit;
        aborted = true;
        break
    end

    preparestring('^',1,200*choice(ntrial),-100);
    drawpict(1);
    wait(sidetime);
    clearpict(1,0,0,0);
    
    
    wait(ITItime);        
    clearpict(1,0,0,0);
    
end % trial 


if ~aborted
    data=[subject;trial;compare;checktime;choice;rt]';
    
    rslt.data = data; 
    rslt.lastses = last; 
    
      %% determine the feedback: how well the subject recognizied the most rewarding pair and avoided the most punishing one: 
    
    % 8 stim 4 pairs 
    % condition 1 = Rew Fc
    % condition 2 = Rew Cf
    % condition 3 = Pun Fc
    % condition 4 = Pun Cf
    
    % odd stims were side_A - better decks: 1 the most rew 3 - the most rew counterf 
    % 6 and 8 are the most punishing 
    
    % find pairs with the most rewarding stim 
    [i1,j1] = find(compare ==1); 
    [i3,j3] = find(compare ==3)
    [i6,j6] = find(compare ==6)
    [i8,j8] = find(compare ==8)
     
     
   % compute how many times the most rewarding stim was chosen over the others 
    ch1 = choice(i1); 
    ch3 = choice(i3); 
    ch6 = choice(i6); 
    ch8 = choice(i8); 
    
  
   
    corrch1 = sum(j1' == 1 & ch1 == -1)+sum(j1'==2 & ch1 ==1); % max 28 
    corrch3 = sum(j3' == 1 & ch3 == -1)+sum(j3' ==2 & ch3 ==1); 
    corrch6 = sum(j6' == 1 & ch6 == 1)+sum(j6'==2 & ch6 ==-1); % avoiding the stim 
    corrch8 = sum(j8' == 1 & ch8 == 1)+sum(j8'==2 & ch8 ==-1); 
  
  

    rewmem = (corrch1+corrch3)/2; 
    punmem = (corrch6+corrch8)/2;
    diffmem = rewmem - punmem; 
    totalmem = (corrch1+corrch3+corrch6+corrch8)/4; 
    
    rslt.totalmem = totalmem;
    rslt.rewmem = rewmem;
    rslt.punmem = punmem;

    % determine the feedback 
    if totalmem <= 7
        facescr = face1;
        feedscr = memfeedback1;
    elseif totalmem > 7 && totalmem < 20
        facescr = face2;
        feedscr = memfeedback2;
    else
        facescr = face3;
        feedscr = memfeedback3;
    end
    
    if diffmem > 0 
         feedscr2 = dfeedback1;
    elseif diffmem < 0
        feedscr2 = dfeedback2;
    elseif diffmem == 0
        feedscr2 = dfeedback3;
    end
        
    
     preparepict(feedscr,1,0,200);
     preparepict(facescr,1,0,-30);
     preparepict(feedscr2,1,0,-250);
    
    drawpict(1);
    pause(10); 
    clearpict(1,0,0,0);
    
    %% Final screen
    preparepict(finalscr,1,0);
    drawpict(1);
    waitkeydown(inf);
    clearpict(1,0,0,0);
    
    stop_cogent;

else
    
    
    data=[subject;trial;compare;checktime;choice;rt]';
    rslt.data = data;
    
    clearkeys; 
    clearpict(1,0,0,0);
     stop_cogent 
end

end


