% APM Toolbox
% Version 1.0 
% Brian Emery 22 May 2011
% 
% CONTENTS.M - contents of the APM tools directory
% 
% FILE READ, WRITE, INITIALIZING
%   load_pattern_file    - load several kinds of APM file (txt, SEAS, loop)
%   apm_struct           - Initialize a standard APM structure
%   make_ideal_pattern   - create an ideal pattern 
%   write_pattern_file   - WRITE PATTERN FILE - create MeasPattern.txt from APM struct
% 
% 
% PLOTTING
%   plot_apm_polar       - PLOT APM POLAR - polar antenna patter plot
%   plot_loop_file       - PLOT LOOP FILE
% 
% 
% CALCULATIONS
%   distortion_parameter - As in Laws et al. 2010 JTech
%   evaluate_apm         - As in de Paolo et al 2007 IEEE
%   magPhase2RealImag    - MAG PHASE 2 REAL IMAG - APM real and imaginary from mag and phase
%   realImag2MagPhase    - REAL IMAG 2 MAG PHASE - APM mag phase from real and imag components
%   volts2dbm            - VOLTS SQUARED TO DBM - convert seasonde signal to dBm
% 
%
% TOOLS FOR TRANSPONDERING
%   cruiseplan_apm       - CRUISEPLAN.M
%   gps_load_etrex       - GPS LOAD ETREX - load oddly formated ascii output from garmin etrex
%   gps2codar            - GPS2CODAR.M - older, possibly obsolete
%   gps2codar_new        - gps2codar_new.m  - older, possibly obsolete


