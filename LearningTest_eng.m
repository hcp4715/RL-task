function [rslt,aborted] = LearningTest_fr(subj)
%  Counterfactual reinforcement learnig learning with monetary gain and loss
%  Stefano Palminteri and Dejan Draschkow: 2013

% Modified by VS September 2016: default is 2 sessions


% identification
% argindlg = inputdlg({'Session number ?'},'TEST_CRL',1,{'','','','',''})
% nsession = str2double(argindlg{1});

% identification
nsub=subj;
numses = 2;

rslt = struct(); % result structure across two sessions


% cogent parameters
%config_display(1,2,[0 0 0],[1 1 1], 'Arial', 55, 1);    %easier to work on - window mode
config_display(1,3,[0 0 0],[1 1 1], 'Arial', 55, 1);
config_log;
config_keyboard(100,5,'exclusive');

start_cogent;

% loading images
% working directory same for all
cross=loadpict('Cross.bmp');
ses1 = loadpict('ses1_screen_eng.bmp');
ses2 = loadpict('ses2_screen_eng.bmp');

feedback1 = loadpict('feedback1_screen_eng.bmp');
feedback2 = loadpict('feedback2_screen_eng.bmp');
feedback3 = loadpict('feedback3_screen_eng.bmp');
scorescr = loadpict('result_blackscreen_eng.bmp');
framescr = loadpict('frame2_blue.png');
face1 = loadpict('neutralface.png'); % neutral
face2 = loadpict('smilingface.png'); % positive 
face3 = loadpict('smilingface2.png'); % very positive 


aborted = false;

for nsession = 1:numses % loop through the two sessions
    
    % generator reset
    rand('state',sum(100*clock));
    
    % gaincoin=loadpict('yesCoin.bmp');
    % nocoin=loadpict('grey.bmp');
    % losscoin=loadpict('lossCoin.bmp');
    
    % condition 1 = Rew Fc
    % condition 2 = Rew Cf
    % condition 3 = Pun Fc
    % condition 4 = Pun Cf
    
    % Defining stimuli for the cue in a pseudo random way and loading the pics
    current_taskversion=randperm(4);
    
    
    nstim=[];
    npair=randperm(4);             
    for i=1:4
        nstim=[nstim randperm(2)];
        stim_A{i}=loadpict(strcat('Stim',num2str(nsession),num2str(npair(i)),num2str(nstim(2*i-1)),'.bmp'));
        stim_B{i}=loadpict(strcat('Stim',num2str(nsession),num2str(npair(i)),num2str(nstim(2*i)),'.bmp'));
        
        stimuli{2*i-1}=strcat('Stim',num2str(nsession),num2str(npair(i)),num2str(nstim((2*i-1))),'.bmp');
        stimuli{2*i}=strcat('Stim',num2str(nsession),num2str(npair(i)),num2str(nstim(2*i)),'.bmp');
    end
    
    
    % create trial vectors
    % version randomized
    
    totaltrial=96;
    totaltrial16=totaltrial/16;
    pair(1:24)= current_taskversion(1);
    pair(25:48)=current_taskversion(2);
    pair(49:72)=current_taskversion(3);
    pair(73:96)=current_taskversion(4);
    
    
    
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
    % create side vectors
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
    count_feedback = NaN(1,totaltrial);
    correct = NaN(1,totaltrial);
    actua_feedback = NaN(1,totaltrial);
    
    % parameters
    fixationtime=500;
    stimulitime=3000;
    sidetime=500;
    feedbacktime=2000;
    leftkey=97;            % left ctrl
    rightkey=98;            % right padenter
%     leftkey=60;              % left ctrl
%     rightkey=90;             % right padenter
    keyquit=52;              % ESCAPE key to quit the session
    
    
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
    
    for ntrial = 1:totaltrial 
        
        condition=pair(ntrial);
        counter(1,condition)=counter(1,condition)+1;
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
        
        clearkeys;
        drawpict(1);
        checktime(ntrial)=time;
        
        
        % response
        
        readkeys;
        logkeys;
        
        [keydown,timedown,numberdown] = waitkeydown(inf,[leftkey rightkey keyquit]);
        
        
        % create reaction times and string that remembers which key is pressed
        rt(ntrial)=timedown(end)-checktime(ntrial);
        if keydown(numberdown)==rightkey;
            choice(ntrial)=1;
        elseif keydown(numberdown)==leftkey;
            choice(ntrial)=-1;
        elseif keydown(numberdown) == keyquit
            aborted = true;
            break
        end
        
        
        preparestring('^',1,200*choice(ntrial),-100);
        drawpict(1);
        wait(sidetime);
        
        % correct=choice toward the "good stim" (1 or 0)
        correct(ntrial)=side_A(condition,position)==choice(ntrial);
        
        % feedbacks no response 0 and response 1 or 0
        if  choice(ntrial)==0;
            actua_feedback(ntrial)=0;
            count_feedback(ntrial)=0;
        else
            actua_feedback(ntrial)=gain(correct(ntrial)+1,condition,position);
            count_feedback(ntrial)=gain(2-correct(ntrial),condition,position);
        end
        %  no response if loop
        %   if choice(ntrial) == 0
        %         preparestring('+0.5€',1,100*side_A(condition,position),100);
        %         preparepict(gaincoin,1,100*side_A(condition,position),0);
        %   else
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
    
    %% store the data
    
    data=[subject(1:ntrial);session(1:ntrial);trial(1:ntrial);pair(1:ntrial);checktime(1:ntrial);choice(1:ntrial);correct(1:ntrial);actua_feedback(1:ntrial);count_feedback(1:ntrial);rt(1:ntrial)].';
    
    eurowon=(sum(data(data(:,4)==1 | data(:,4)==2,8)))/2;
    
    euroloss=(40-sum(data(data(:,4)==3 | data(:,4)==2,8)))/2; % ? why taking the Rew Counterfactual? Shouldn't be punishment counterfact?
    
    money=eurowon-euroloss;
    rslt.data{nsession} = data;
    rslt.eurowon{nsession} = eurowon;
    rslt.euroloss{nsession} = euroloss;
    rslt.stimuli{nsession} = stimuli;
    rslt.money{nsession} = money;
    

    
    % decide on the result 
    if money<=0 % loss or no winning 
        facescr = face1; 
        feedscr = feedback1;
        
    elseif money > 0 && money < 10 
        facescr = face2;
        feedscr = feedback2;
        preparepict(scorescr,1,185,100);
        preparestring(strcat([num2str(money)]),1,150,90); % give a score in points
    else
        facescr = face3;
        feedscr = feedback3;
        preparepict(scorescr,1,185,100);
        preparestring(strcat([num2str(money)]),1,150,90); % give a score in points
    end
    
     preparepict(feedscr,1,0,-55);
     preparepict(facescr,1,0,-268);
     
    
    if ~aborted
        
        if nsession == 1
            preparepict(ses1,1,0,230);
            
            drawpict(1);
            waitkeydown(inf);
            clearpict(1,0,0,0);
            clearkeys; 
            
        elseif nsession == 2
            
            preparepict(ses2,1,0,230);
            drawpict(1);
            waitkeydown(inf);
            clearpict(1,0,0,0);
            stop_cogent; 
            
            
            %% compute the performance score across the 2 sessions:
%             finalscr = sum(rslt.money{1}(1) + rslt.money{2}(1));
%             finalmoney = finalscr*5;
%             
%             % If the result is negative or 0
%             if finalscr<=0 % no winning
%                 feedscr = feedback1;
%             elseif finalscr > 0 && finalscr <= 16
%                 feedscr = feedback2;
%                 preparepict(scorescr,1,0,100);
%                 preparestring(strcat([num2str(finalmoney)]),1,150,90); % give a score in points
%                 % preparestring(strcat([num2str(finalmoney),' P']),1,180,100); % give a score in points
%             else
%                 feedscr = feedback3;
%                 preparepict(scorescr,1,0,100);
%                 preparestring(strcat([num2str(finalmoney)]),1,150,90); % give a score in points
%                 % preparestring(strcat([num2str(finalmoney),' P']),1,180,100); % give a score in points
%             end
%             
%             preparepict(feedscr,1,0,-95);
%             drawpict(1);
%             waitkeydown(inf);
%             
%             clearpict(1,0,0,0);
%             clearkeys;
%             stop_cogent;
        end
    else
        data=[subject(1:ntrial);session(1:ntrial);trial(1:ntrial);pair(1:ntrial);checktime(1:ntrial);choice(1:ntrial);correct(1:ntrial);actua_feedback(1:ntrial);count_feedback(1:ntrial);rt(1:ntrial)].'; % CHQGE HERE
        rslt.data{nsession} = data;
        rslt.stimuli{nsession} = stimuli;
        break
    end % aborted
    
    
end % session loop


if aborted
    clearpict(1,0,0,0);
    clearkeys;
    stop_cogent;
end
end % function

