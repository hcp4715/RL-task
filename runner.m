%% Script to run the COUNTERFACTUAL TASK 

% September 2016 VS 

% ===================================
clear all java
close all hidden
clc
% ====================================
% add path to the task files 
addpath '.\task_COUNTRL\'
% add toolboxes
addpath(genpath('.\task_COUNTRL\Cogent2000v1.32\')); 

%%

% get participant and task information information
argindlg = inputdlg({'Subject number','Practice Session? 1=Yes/0=No'},'CRL',1,{'','','','',''})

if isempty(argindlg) || isempty(argindlg{1}) || isempty(argindlg{2})
    error('experiment cancelled!');
end

subj = str2num(argindlg{1});

% create the subject directory 
if ~exist(sprintf('./Data/S%02d/',subj))
    mkdir(sprintf('./Data/S%02d/',subj));
end


if isempty(argindlg{2}) || isequal(argindlg{2},'1')
    pract = 1; % default is practice session
    fprintf('running the training session\n'); 
else
    pract = 0; 
    fprintf('running the real task\n'); 
end

% run experiment
[expe,aborted] = run_expe(subj,pract); 


