function [rslt,aborted] = Practice_eng(subj) 
%  Counterfactual reinforcement learnig with monetary gain and loss
%  Stefano Palminteri and Dejan Draschkow: 2013

% Modified VS for patients (russian) September 2016 
% =======================================================

argindlg = inputdlg({'Session number ?'},'PRACTICE_CRL',1,{'','','','',''})

% identification
nsub=subj; 

if isempty(argindlg)
    nsession = 1; % default number of training sessions is 1 
else
    nsession = str2double(argindlg{1});
end


% cogent parameters
%config_display(1,2,[0 0 0],[1 1 1], 'Arial', 55, 1);    %easier to work on - window mode
config_display(1,3,[0 0 0],[1 1 1], 'Arial', 55, 1,0);     
config_log;
config_keyboard(100,5,'exclusive');

% generator reset
rand('state',sum(100*clock));

start_cogent;

% loading images                
% working directory same for all
cross=loadpict('Cross.bmp');

% gaincoin=loadpict('yesCoin.bmp');   
% nocoin=loadpict('grey.bmp');    
% losscoin=loadpict('lossCoin.bmp');   

testscr = loadpict('training_screen_eng.bmp'); 
framescr = loadpict('frame2_blue.png');


% condition 1 = Rew Fc: only the chosen outcome is present 
% condition 2 = Rew Cf : both chosen and unchosen 
% condition 3 = Pun Fc : only the chosen
% condition 4 = Pun Cf : both chosen and unchosen 

% Defining stimuli for the cue in a pseudo random way and loading the pics
current_taskversion=randperm(4);

nstim=[];
npair=randperm(4);              % later improve this
for i=1:4
    stim_A{i}=loadpict(strcat('tim',num2str(i),'_french.bmp'));
    stim_B{i}=loadpict(strcat('tim',num2str(i+4),'_french.bmp'));
end


% create trial vectors
% version randomized

totaltrial=16;                  
totaltrial16=totaltrial/16;     
pair(1:4)=current_taskversion(1);
pair(5:8)=current_taskversion(2);
pair(9:12)=current_taskversion(3);
pair(13:16)=current_taskversion(4);

% create feedback vectors for each trial/condition
% A = "good option"; B = "bad one"
% gain_A(x,y) == feedback_symbol(condition,trial)
% gain condition: 1=0.5€, 0=0.0€;
% loss condition: 1=0.0€, 0=-0.5€;

totaltrial4=totaltrial/4;
gain_A=zeros(4,totaltrial4);
gain_B=zeros(4,totaltrial4);

for i=1:4
    temp=[];
    temp2=[];
    for j=1:totaltrial16
        temp=[temp randperm(4)];
        temp2=[temp2 randperm(4)];
    end
    gain_A(i,:)=temp;
    gain_B(i,:)=temp2;
end
gain_A(gain_A<4)=1;
gain_A(gain_A>1)=0;
gain_B(gain_B<2)=1;
gain_B(gain_B>1)=0;

gain(1,:,:)=gain_B;
gain(2,:,:)=gain_A;

side_A=zeros(4,totaltrial4);
% create side vectors, (only for the "correct" option)
% n of rows    = types of pairs; 
% n of columns = trials of each type  
for i=1:4
    temp=[];
    for j=1:totaltrial16
        temp=[temp randperm(4)];
    end
    side_A(i,:)=temp;

end
side_A(side_A<3)=1;
side_A(side_A>1)=-1;


% data to save
subject(1:totaltrial)=nsub;
session(1:totaltrial)=nsession;
trial=[1:totaltrial];
checktime=zeros(1,totaltrial);
side=zeros(1,totaltrial);
feedback=zeros(1,totaltrial);
rt=zeros(1,totaltrial);

% parameters
fixationtime=500;
stimulitime=3000;
sidetime=500;
feedbacktime=2000;

% leftkey=60;             % left ctrl
% rightkey=90;            % right padenter: the enter key on the right small number keyboard 
leftkey=97;             % left ctrl
rightkey=98;            % right padenter: the enter key on the right small number keyboard 
keyquit=52;           % ESCAPE key to quit the session 

% ready to start
setforecolour(1,0,0);
preparestring('START',1,0,0);
drawpict(1);
waitkeydown(inf);
clearpict(1,0,0,0);

% behavioural task

setforecolour(1,0,0);
counter=zeros(1,4);
choice=zeros(1,totaltrial);         


aborted = false; 

for ntrial = 1:totaltrial           

    condition=pair(ntrial); % which pair (1 of 4: gain-complete; gain-partial; loss-complet; loss-partial)
    
    % a matrix for counting each condition, recording the n_th trial for
    % each condition.
    counter(1,condition)=counter(1,condition)+1; 
    
    % A very tricky way to get a coordination for retrieval the column position from
    % side_A: that is, for the n trials of condition i, i will retrival the
    % n column from side_A later, combined with condition, it form a
    % complete coordination to locate the position in side_A.
    position=counter(1,condition);               


    % fixation

    preparepict(cross,1,0,0);
    preparepict(framescr,1,200*side_A(condition,position),0);
    preparepict(framescr,1,200*(-side_A(condition,position)),0);
    drawpict(1);
    wait(fixationtime);

    % stimuli

    preparepict(stim_A{condition},1,200*side_A(condition,position),0);
    preparepict(stim_B{condition},1,200*(-side_A(condition,position)),0);

  
    drawpict(1);
    checktime(ntrial)=time;
  
    % response
    clearkeys;
    readkeys;
    logkeys;
  
    [keydown,timedown,numberdown] = waitkeydown(inf,[leftkey rightkey keyquit]);
       

    % create reaction times and string that remembers which key is pressed
    rt(ntrial)=timedown(end)-checktime(ntrial);
    
    if keydown(numberdown)==rightkey;
        choice(ntrial)=1;
    elseif keydown(numberdown)==leftkey;
        choice(ntrial)=-1;
    elseif keydown(numberdown) == keyquit;
        aborted = true;
        rslt = []; 
        stop_cogent;
        break
    end
    
    
    preparestring('^',1,200*choice(ntrial),-100);
    drawpict(1);
    wait(sidetime);                       
  
    % correct=choice toward the "good stim" (1 or 0)
    % HCP: here, it is clear that side_A is the position matrix of the correct
    % option. The accuracy of the current trial is determined by position
    % and choice (left or right)
    correct(ntrial)= side_A(condition,position) ==choice(ntrial);

    % feedbacks no response 0 and response 1 or 0
    if  choice(ntrial)==0;
        actua_feedback(ntrial)=0;
        count_feedback(ntrial)=0;
    else
        actua_feedback(ntrial)=gain(correct(ntrial)+1,condition,position);
        count_feedback(ntrial)=gain(2-correct(ntrial),condition,position);
    end
    
 
    switch condition
        case 1  % condition 1 = Rew Fc
            if actua_feedback(ntrial)==1;
                preparestring('+0.5£',1,200*choice(ntrial),100);
            else
                preparestring(' 0£',1,200*choice(ntrial),100);
                
            end

        case 2  % condition 2 = Rew Cf
            if actua_feedback(ntrial)==1;
                preparestring('+0.5£',1,200*choice(ntrial),100);
            else
                preparestring(' 0£',1,200*choice(ntrial),100);
                
            end
            if count_feedback(ntrial)==1;
                preparestring('+0.5£',1,200*(-choice(ntrial)),100);
            else
                preparestring(' 0£',1,200*(-choice(ntrial)),100);
            end

        case 3  % condition 3 = Pun Fc
            if actua_feedback(ntrial)==1;
                preparestring(' 0£',1,200*choice(ntrial),100);
            else
                preparestring('-0.5£',1,200*choice(ntrial),100);
            end

        case 4  % condition 4 = Pun Cf
            if actua_feedback(ntrial)==1;
                preparestring(' 0£',1,200*choice(ntrial),100);
            else
                preparestring('-0.5£',1,200*choice(ntrial),100);
            end
            if count_feedback(ntrial)==1;
                preparestring(' 0£',1,200*(-choice(ntrial)),100);
            else
                preparestring('-0.5£',1,200*(-choice(ntrial)),100);
            end

    end
  
    drawpict(1);
   
    wait(feedbacktime);
    clearpict(1,0,0,0);

end % trial loop 

preparepict(testscr,1,0,0);
drawpict(1);
pause(2); 

clearpict(1,0,0,0);

stop_cogent;


if ~aborted
    
money=((0.5*80*mean(correct))-20)/2; % min is -10 (0 correct) to 10 : all 16 responses are correct 
data=[subject;session;trial;pair;checktime;choice;correct;actua_feedback;count_feedback;rt].';
rslt.data = data; 
rslt.money = money;

if money < 0
    fprintf('You should repeat the training session\n');
else
    fprintf('Training is OK\n');
end


end

