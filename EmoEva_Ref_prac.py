#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
This is an the script for the pilot study.

Author      Date           log of changes
=========   =============  ======================
C-P. Hu     Jun 27, 2019.  adopted from EmoReg project

Input:
     Participant ID, age, gender, session

Output:
    ERdopa_Pilot_d1_block_sX_2018_XXXX.txt   # the log file for each participant's choice.
    
@author: Chuan-Peng Hu, PhD, Neuroimaging Center, Mainz
@email: hcp4715 at gmail dot com
"""
# from __future__ import absolute_import, division
# import psychopy

# import os
# import time
# import sys
# import csv

# from psychopy import parallel, gui, visual, core, data, event    # ,  logging, clock locale_setup, sound,

# from psychopy.constants import (NOT_STARTED, STARTED, PLAYING, PAUSED,
#                                 STOPPED, FINISHED, PRESSED, RELEASED, FOREVER)
# from psychopy.iohub.client import launchHubServer, EventConstants

# from numpy import (sin, cos, tan, log, log10, pi, average,
#                   sqrt, std, deg2rad, rad2deg, linspace, asarray)
# from numpy.random import random, randint, normal, shuffle  # Note here that we used the numpy.random module
from itertools import groupby
import random
import os
import wx

from psychopy import gui, visual, core, data, event    # ,  logging, clock locale_setup, sound,
import numpy as np  # whole numpy lib is available, prepend 'np.'

# ------------------------------------ Define functions  ---------------------------------------------------------------


# define a function to get the ESCAPE key
def get_keypress():
    keys = event.getKeys(keyList=['escape'])
    if keys:
        return keys[0]
    else:
        return None


# define a function to exit
def shutdown():
    win.close()
    core.quit()


# ------------------------------------ Presenting Stimulus -------------------------------------------------------------
# define a function for presenting message
def text_msg(msg, loc, fontheight):
    """ display a short text message
    """
    msgCon = visual.TextStim(win,
                             text=msg,
                             font='Arial',
                             height=fontheight,
                             pos=loc,
                             color=black,
                             colorSpace='rgb',
                             opacity=1,
                             depth=0.0,
                             units='pix')
    msgCon.draw()
    # win.flip()


# ---------------------------------------- Define global variables -----------------------------------------------------

# get the current directory and change the cd
# thisDir = os.path.dirname(os.path.realpath(__file__))
_thisDir = os.getcwd()
os.chdir(_thisDir)

# get subject information before open windows
expName = 'EmoRef_pilot_prac'  # This name will be part of the output file names.
expInfo = {'session': '01', 'participantID': 's1', 'gender': '', 'age': ''}
dlg = gui.DlgFromDict(dictionary=expInfo, title=expName)

if not dlg.OK:
    core.quit()                         # user pressed cancel

expInfo['date'] = data.getDateStr()     # add a simple timestamp
expInfo['expName'] = expName

# ---------------------------------------- Setup the Window ------------------------------------------------------------
app = wx.App(False)

display_width = 800      # when debugging, use this
display_height = 600     # when debugging, use this
# display_width = wx.GetDisplaySize()[0]      # get the width of the display, strange, it is 1536, instead of 1920
# display_height = wx.GetDisplaySize()[1]     # get the height of the display
win = visual.Window(size=[display_width, display_height],        # size of the window, better not full screen when debuggging
                    fullscr=False,          # better False when debugging
                    screen=0,               # chose the default monitor
                    allowGUI=True,
                    allowStencil=False,
                    monitor='testMonitor',
                    color=[0, 0, 0],        # mind the colorSpace
                    colorSpace='rgb',       # chose the colorSpace and change accordingly
                    blendMode='avg',
                    useFBO=True,
                    units='pix')            # important about the units, change the value for defining it accordingly

win.mouseVisible = False                    # hide the mouse

# ---------------------------------------- define constants ------------------------------------------------------------
black = [-1, -1, -1]
white = [1, 1, 1]
grey = [0, 0, 0]

# ---------------------------------------- Define the data file --------------------------------------------------------
# create a folder called "data" if not exits, and change directory to the folder
# if not os.path.exists('data'):
#    os.mkdir('data')

# Data file name stem = absolute path + name; later add .psyexp, .csv, .log, etc
# define the file name for recording each trial.
# pracFilename = _thisDir + os.sep + u'data/%s_%s_%s_%s%s' % (expInfo['expName'], 'd1_trial', expInfo['participantID'], expInfo['date'], '.txt')

# Write the header for the trial file.
# initLine = open(pracFilename, 'w')
# curLine = ','.join(map(str, ['Session', 'Block', 'blockType', 'trialOrd', 'shape', 'stimType', 'trig', 'waitTime', 'startTime', 'endTime', 'ITI']))
# initLine.write(curLine)
# initLine.write('\n')
# initLine.close()


# data to save
# subject(1:totaltrial)=nsub;
# session(1:totaltrial)=nsession;
# trial=[1:totaltrial];
# checktime=zeros(1,totaltrial);
# side=zeros(1,totaltrial);
# feedback=zeros(1,totaltrial);
# rt=zeros(1, totaltrial);

# ---------------------------------------- Define parameters of presenting stimuli -------------------------------------
# parameters (in second)
fixationTime = 0.5
stimuliTime = 3
sideTime = 0.5
feedbackTime = 2

# Define the file name for logging for block.
# blockFilename = _thisDir + os.sep + u'data/%s_%s_%s_%s%s' % (expInfo['expName'], 'd1_block',expInfo['participantID'],expInfo['date'],'.txt')

# Write the header for the block file
# initLine = open(blockFilename,'w')
# curLine = ','.join(map(str,['Session','Block','ratingType', 'blockType', 'CSType','Ratings', 'Rating_time']))
# initLine.write(curLine)
# initLine.write('\n')
# initLine.close()

# ---------------------------------------- Prepare the pseudo-random list of stimuli between participants --------------
# condition 1 = Rew Fc: only the chosen outcome is present
# condition 2 = Rew Cf : both chosen and unchosen
# condition 3 = Pun Fc : only the chosen
# condition 4 = Pun Cf : both chosen and unchosen

# Defining stimulus-pair for the cue in a pseudo random way for later loading the pics

currentTaskVersion = np.random.permutation(4)  # generate a array [0 1 2 3] with random order
totalTrial = 16                                # total number of trials
totalTrial16 = int(totalTrial/16)              # how many times is total trials number as 16?
stimPair = np.zeros(shape=(16, 1))             # generate an array (size is [16, 1]) with zero
stimPair[0:4] = currentTaskVersion[0]          # get the first pair
stimPair[4:8] = currentTaskVersion[1]          # get the second pair
stimPair[8:12] = currentTaskVersion[2]
stimPair[12:16] = currentTaskVersion[3]

for stimType in currentTaskVersion:
    pairType = stimType
    
    totalTrial4 = int(totalTrial/4)                 # how many times is total trials number as 4?
    gain_A = np.zeros(shape=(1, totalTrial4))       # generate a gain matrix for A, size is [4, totalTrial4]
    gain_B = np.zeros(shape=(1, totalTrial4))       # generate a gain matrix for B, size is [4, totalTrial4]
    
    # Define gain matrices for two cues, A for high reward stimulus, B for low reward stimulus
    #  row: 4 rows, corresponding to 4 types of pairs
    #  column: random index
    # gain_A works with side_A, counter, position, pairType to determine the location of high reward stimuli
    gain_A = np.array([np.random.permutation(4)])   #
    gain_B = np.array([np.random.permutation(4)])   #
    gain_A = np.where(gain_A < 3, 1, gain_A)       # make the 3/4 of the number as 1 (gain)
    gain_A = np.where(gain_A >= 3, 0, gain_A)      # make the rest 1/4 of the number as 0 (no gain)
    
    gain_B = np.where(gain_B >= 1, 1, gain_B)      # make the 1/4 of the number as 1 (gain)
    gain_B = np.where(gain_B < 1, 0, gain_B)       # make the rest 3/4 of the number as 0 (no gain)
    gain_B = (gain_B - 1) * (-1)
    
    # define a matrix for the location index of the correct option (75% gain or no loss)
    side_A = np.array([np.random.permutation(4)])   # generate an array with random order [0 1 2 3]
    # for i in range(0, 3):                           # append more row to position matrix
    #    a = np.random.permutation(4)
    #    side_A = np.append(side_A, [a], axis=0)
    
    side_A = np.where(side_A < 2, 1, side_A)        # half of the trials will be on the right [1], half on the left [-1]
    side_A = np.where(side_A >= 2, -1, side_A)
    side_B = side_A * -1
    
    trial_params = [side_A, gain_A, gain_B]         # create a matrix for trial parameters
    
    val_left = []
    val_right = []
    # define a value for left and right side
    for ii in range(0, 4):
        if side_A[0, ii] == 1:                     # if the high prob stimuli appear on the right
            tmp_gain_right = gain_A[0, ii]
            tmp_gain_left = gain_B[0, ii]
            val_right.append(tmp_gain_right)
            val_left.append(tmp_gain_left)
        else:                                      # if the high prob stimuli appear on the left
            tmp_gain_right = gain_B[0, ii]
            tmp_gain_left = gain_A[0, ii]
            val_right.append(tmp_gain_right)
            val_left.append(tmp_gain_left)
    
    # define a counter array, with size[1, number of trial type], This counter is used for count how many times of each type
    # of trial has been presented. For example, if the 3rd type of trial presented for the first time, then, the 3rd column
    # will add 1. if the 3rd type of trials was presented for the second time, the 3rd column of the counter will add 1 again
    # to 2.
    counter = np.zeros(shape=[1, 4])
    choice = np.zeros(shape=[1, totalTrial])
    accuracy_list = []
    
    for ntrial in range(0, totalTrial4):
        position = side_A[0, ntrial]
        
        print('Pair type:', pairType, 'trial No:', ntrial + 1)
        
        # get the image for the current trial based on the trial type.
        # here side_A is used to determine the position of high reward stimulus.
        if pairType == 0:
            current_image_1_name = _thisDir + os.sep + 'stim' + os.sep + 'tim1_french.bmp'                    # get the file name
            current_image_1 = visual.ImageStim(win, image=current_image_1_name, pos=[side_A[0, position] * display_width/4, 0])    # read the image
            current_image_2_name = _thisDir + os.sep + 'stim' + os.sep + 'tim5_french.bmp'                    # get the file name
            current_image_2 = visual.ImageStim(win, image=current_image_2_name, pos=[side_A[0, position] * -display_width/4, 0])     # read the image
        elif pairType == 1:
            current_image_1_name = _thisDir + os.sep + 'stim' + os.sep + 'tim2_french.bmp'                    # get the file name
            current_image_1 = visual.ImageStim(win, image=current_image_1_name, pos=[side_A[0, position] * display_width/4, 0])    # read the image
            current_image_2_name = _thisDir + os.sep + 'stim' + os.sep + 'tim6_french.bmp'                    # get the file name
            current_image_2 = visual.ImageStim(win, image=current_image_2_name, pos=[side_A[0, position] * -display_width/4, 0])     # read the image
        elif pairType == 2:
            current_image_1_name = _thisDir + os.sep + 'stim' + os.sep + 'tim3_french.bmp'                    # get the file name
            current_image_1 = visual.ImageStim(win, image=current_image_1_name, pos=[side_A[0, position] * display_width/4, 0])    # read the image
            current_image_2_name = _thisDir + os.sep + 'stim' + os.sep + 'tim7_french.bmp'                    # get the file name
            current_image_2 = visual.ImageStim(win, image=current_image_2_name, pos=[side_A[0, position] * -display_width/4, 0])     # read the image
        elif pairType == 3:
            current_image_1_name = _thisDir + os.sep + 'stim' + os.sep + 'tim4_french.bmp'                    # get the file name
            current_image_1 = visual.ImageStim(win, image=current_image_1_name, pos=[side_A[0, position] * display_width/4, 0])    # read the image
            current_image_2_name = _thisDir + os.sep + 'stim' + os.sep + 'tim8_french.bmp'                    # get the file name
            current_image_2 = visual.ImageStim(win, image=current_image_2_name, pos=[side_A[0, position] * -display_width/4, 0])     # read the image
        
        # prepare for the frame
        frame_name_l = _thisDir + os.sep + 'stim' + os.sep + 'frame_blue.png'                   # get the file name
        frame_image_l = visual.ImageStim(win, image=frame_name_l, pos=[-display_width/4, 0])    # read the image
        
        frame_name_2 = _thisDir + os.sep + 'stim' + os.sep + 'frame_blue2.png'
        frame_image_2 = visual.ImageStim(win, image=frame_name_l, pos=[display_width/4, 0])
        
        # prepare image for arrow
        arrow_image_name = _thisDir + os.sep + 'stim' + os.sep + 'arrow.bmp'
        arrow_image_left = visual.ImageStim(win, image=arrow_image_name, pos=[-display_width/4, -85])
        arrow_image_right = visual.ImageStim(win, image=arrow_image_name, pos=[display_width/4, -85])
        
        # present a fixation for fixationTime.
        timer = core.Clock()
        timer.add(fixationTime)
        escDown = None
        
        while timer.getTime() < 0 and escDown is None:
            escDown = get_keypress()
            if escDown is not None:
                shutdown()
            text_msg('+', (0, 0), 50)
            frame_image_l.draw()
            frame_image_2.draw()
            win.flip()
        
        win.flip()   # flip the screen (fixation disappear)
        
        # present a picture and wait for response.
        # timer = core.Clock()
        # timer.add(fixationTime)
        escDown = None
        end_trial = None
        # resp_key = event.getKeys(keyList=['f', 'j'], timeStamped=True)
        resp_key = []
        while escDown is None and end_trial is None:
            escDown = get_keypress()
            if escDown is not None:
                shutdown()
            frame_image_l.draw()                                                                    # draw the image
            frame_image_2.draw()
            current_image_1.draw()
            current_image_2.draw()
    #        text_msg('+', (-position*display_width/4, 0), 50)    # the number here should be 1/4 of the width of the screen.
    #        text_msg('++', (position*display_width/4, 0), 50)
            win.flip()                                                                         # present the image
            
            while not resp_key:
                resp_key = event.getKeys(keyList=['f', 'j'], timeStamped=True)
            
            if resp_key[0][0] == 'j':    # if the key press is right key
                # show the arrow at the right
                choice[0, ntrial] = 1    # right key, 1
                current_arrow = arrow_image_right
                feed_pos = 1             # feedback position
            elif resp_key[0][0] == 'f':
                choice[0, ntrial] = -1   # left key, -1
                current_arrow = arrow_image_left
                feed_pos = -1            # feedback position
            # timer = core.Clock()
            timer.add(1.5)
            while timer.getTime() < 0:
                escDown = get_keypress()
                if escDown is not None:
                    shutdown()
                frame_image_l.draw()                                                                    # draw the image
                frame_image_2.draw()
                current_image_1.draw()
                current_image_2.draw()
                current_arrow.draw()
                win.flip()
                
            end_trial = True  # end the trial 1.5 sec after the response
            # win.flip()        # flip the screen (fixation disappear)
        win.flip()
        
        if side_A[0, position] == choice[0, ntrial]:
            accuracy_list.append(1)
        else:
            accuracy_list.append(0)
        
        # define the feedback
        reward_image_name = _thisDir + os.sep + 'stim' + os.sep + 'pos.jpg'
        punish_image_name = _thisDir + os.sep + 'stim' + os.sep + 'neg.jpg'
        
        timer = core.Clock()
        timer.add(2)
        while timer.getTime() < 0 and escDown is None:
            escDown = get_keypress()
            if escDown is not None:
                shutdown()
#         [side_A[0, position] * display_width/4, 0]
            if pairType == 0:   # condition 1: reward, partial feedback
                if feed_pos == 1 and val_right[ntrial] == 1:
                    text_msg('+0.5 Euro', [feed_pos * display_width/4, 0], 28)
                    # current_feed_l = reward_image_name
                    
                elif feed_pos == 1 and val_right[ntrial] == 0:
                    text_msg('+0.0 Euro', [feed_pos * display_width/4, 0], 28)
                    # current_feed_l = punish_image_name
                    
                elif feed_pos == -1 and val_left[ntrial] == 1:
                    text_msg('+0.5 Euro', [feed_pos * display_width/4, 0], 28)
                elif feed_pos == -1 and val_left[ntrial] == 0:
                    text_msg('+0.0 Euro', [feed_pos * display_width/4, 0], 28)
                    
            elif pairType == 1:   # condition 2: reward, complete feedback
                
                # if feed_pos == 1:
                if val_right[ntrial] == 1 and val_left[ntrial] == 1:
                    text_msg('+0.5 Euro', [feed_pos * display_width/4, 0], 28)
                    text_msg('+0.5 Euro', [-feed_pos * display_width/4, 0], 28)
                elif val_right[ntrial] == 1 and val_left[ntrial] == 0:
                    text_msg('+0.5 Euro', [feed_pos * display_width/4, 0], 28)
                    text_msg('+0.0 Euro', [-feed_pos * display_width/4, 0], 28)
                elif val_right[ntrial] == 0 and val_left[ntrial] == 1:
                    text_msg('+0.0 Euro', [feed_pos * display_width/4, 0], 28)
                    text_msg('+0.5 Euro', [-feed_pos * display_width/4, 0], 28)
                elif val_right[ntrial] == 0 and val_left[ntrial] == 0:
                    text_msg('+0.0 Euro', [feed_pos * display_width/4, 0], 28)
                    text_msg('+0.0 Euro', [-feed_pos * display_width/4, 0], 28)

            elif pairType == 2:  # condition 1: reward, partial feedback
                
                if feed_pos == 1 and val_right[ntrial] == 1:
                    text_msg('-0.5 Euro', [feed_pos * display_width/4, 0], 28)
                    # current_feed_l = reward_image_name
                    # preparestring('+0.5£', 1, 200*choice(ntrial),100);
                elif feed_pos == 1 and val_right[ntrial] == 0:
                    text_msg('-0.0 Euro', [feed_pos * display_width/4, 0], 28)
                    # current_feed_l = punish_image_name
                    # preparestring(' 0£',1,200*choice(ntrial),100);
                elif feed_pos == -1 and val_left[ntrial] == 1:
                    text_msg('-0.5 Euro', [feed_pos * display_width/4, 0], 28)
                elif feed_pos == -1 and val_left[ntrial] == 0:
                    text_msg('-0.0 Euro', [feed_pos * display_width/4, 0], 28)
                    
            elif pairType == 3:  # condition 1: reward, complete feedback
                if val_right[ntrial] == 1 and val_left[ntrial] == 1:
                    text_msg('-0.5 Euro', [feed_pos * display_width/4, 0], 28)
                    text_msg('-0.5 Euro', [-feed_pos * display_width/4, 0], 28)
                elif val_right[ntrial] == 1 and val_left[ntrial] == 0:
                    text_msg('-0.5 Euro', [feed_pos * display_width/4, 0], 28)
                    text_msg('-0.0 Euro', [-feed_pos * display_width/4, 0], 28)
                elif val_right[ntrial] == 0 and val_left[ntrial] == 1:
                    text_msg('-0.0 Euro', [feed_pos * display_width/4, 0], 28)
                    text_msg('-0.5 Euro', [-feed_pos * display_width/4, 0], 28)
                elif val_right[ntrial] == 0 and val_left[ntrial] == 0:
                    text_msg('-0.0 Euro', [feed_pos * display_width/4, 0], 28)
                    text_msg('-0.0 Euro', [-feed_pos * display_width/4, 0], 28)
            win.flip()
            # print('present feedback')
        win.flip()
        core.wait(0.5)  # wait for 0.5 second
        
shutdown()
