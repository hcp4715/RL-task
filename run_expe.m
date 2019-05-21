function [expe,aborted,errmsg] = run_expe(subj,pract)

% Function to run the COUNTERFACTUAL learning TASK (Stefano Palminteri) 
% Practice for phase 1 
% Phase 1 

% ===============================
% September 2016 VS 
% ===============================

% check input arguments
if nargin < 2
    practt = 1; 
else
    practt = pract; 
end

if nargin < 1
    error('Missing subject number!');
end

% create header
hdr = [];
hdr.subj = subj;
hdr.date = datestr(now,'yyyymmdd-HHMM');


expe = struct(); 
expe(1).hdr = hdr;  

% define output arguments
aborted = false; % aborted prematurely?
errmsg = []; % error message

%% run the full task or the practice 
switch practt
    case 1
       % [rslt,aborted] = Practice_rus(subj);
         [rslt,aborted] = Practice_eng(subj);
        
    case 0 
        % [rslt,aborted] = LearningTest_rus(subj); % run the main test 
          [rslt,aborted] = LearningTest_eng(subj); % run the main test 

end

expe.rslt = rslt; 

saverslt(expe,aborted,practt); 

%% RUN A SURPRISE POST TEST 

if ~aborted && practt == 0 % only after the phase 1 of the main task 
    
    practt = -1; 
    
    nses = expe.rslt.data(1,2); % should be 1 for all subjects 
     [rslt,aborted] = PostTest_eng(subj,expe);
    
    expe_post = struct();
    expe_post(1).hdr = hdr;
    expe_post.rslt = rslt;
    saverslt(expe_post,aborted,practt); 

end





%% subfunctions 
    function saverslt(expe,aborted,practt)
        if ~aborted
            % save data to disk
            if practt == 1
                filename = sprintf('./Data/S%02d/PRACTICE_CRL_S%02d_%s.mat',expe(1).hdr.subj,expe(1).hdr.subj,expe(1).hdr.date); 
                save(filename,'expe');
            elseif practt ==0
                filename = sprintf('./Data/S%02d/CRL_S%02d_%s.mat',expe(1).hdr.subj,expe(1).hdr.subj,expe(1).hdr.date);
                save(filename,'expe');
            elseif practt == -1 % PHASE 2 POST-TEST 
                filename = sprintf('./Data/S%02d/CRL_POST_S%02d_%s.mat',expe(1).hdr.subj,expe(1).hdr.subj,expe(1).hdr.date);
                save(filename,'expe');
            end
        else % save the unfinished data still for the main parts of the experiment 
            if practt == 0  
                filename = sprintf('./Data/S%02d/CRL_aborted_S%02d_%s.mat',expe(1).hdr.subj,expe(1).hdr.subj,expe(1).hdr.date);
                save(filename,'expe');
            elseif practt == -1 
                filename = sprintf('./Data/S%02d/CRL_POST_aborted_S%02d_%s.mat',expe(1).hdr.subj,expe(1).hdr.subj,expe(1).hdr.date);
                save(filename,'expe');
            end
            
        end
    end





end 