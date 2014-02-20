function dBm = vSq2dBm(v2)
%
disp('renamed to volts2dbm.m'), keyboard
% VOLTS SQUARED TO DBM - convert seasonde signal to dBm
% 
% See File_CrossSpectra.pdf from the COS documentation

% Copyright (C) 2011 Brian M. Emery
% 14 Oct 2010
%  6 May 2011 - rechecked and renamed

% Verified vs SpectraPlotterMap (see test_case to compute_apm_from_csq.m)

% From File_CrossSpectra.pdf:
% Note to convert Antenna1,2,3 to dBm use: 
% 10*log10(abs(voltagesquared)) + (40.0 ? 5.8) 
% The 40.0 is an adjustment to conversion loss in the receiver. 
% The 5.8 is an adjustment to processing gain in SeaSondeAcquisition.
%
% It seems teh the above is in error, this checks out with
% SpectraPlotterMap:
dBm = 10*log10(abs(v2)) - 40 + 5.8;

end