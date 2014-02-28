%CALLSTART  Clears ALL variables and ALL figures.
%
% 	This m-file clears *ALL* variables from memory and *ALL* figure
% 	windows.  This is useful to call at the beginning of an m-file.
%
% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%	** BEWARE ** using callstart will remove ALL globally defined
%	variables, ALL variable in matlab memory, ALL figure windows.
%	Be sure all the matlab variables you want have been saved before
%	you use CALLSTART.
% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%
%	Usage:
%		Place CALLSTART as the 1st non-comment line in an m-file
%		to clear matlab memory.
%       

% 	Mike Cook - NPS Oceanography Dept. - Oct 93
%	MOD. AUG 94 - use to close only current figure, now closes
%                     ALL figure windows.

clear global
clear all
close all

% clc
