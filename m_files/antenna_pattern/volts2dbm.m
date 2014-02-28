function [dBm,deg] = volts2dbm(v2)
% VOLTS SQUARED TO DBM - convert seasonde signal to dBm
% [dBm,deg] = volts2dbm(v2)
%
% Also outputs phase in degrees if the input is complex.
% 
% See File_CrossSpectra.pdf from the COS documentation
%
% See also cs_volts2dbm.m for converting units on a 
% whole cross spectra file.


% Copyright (C) 2011 Brian M. Emery
% 14 Oct 2010 - Verified vs SpectraPlotterMap 
%  6 May 2011 - rechecked and renamed, added test case and
%               output of phase angle
% 
if strcmp('--t',v2), test_case, return, end

% From File_CrossSpectra.pdf:
% Note to convert Antenna1,2,3 to dBm use: 
% 10*log10(abs(voltagesquared)) + (40.0 ? 5.8) 
% The 40.0 is an adjustment to conversion loss in the receiver. 
% The 5.8 is an adjustment to processing gain in SeaSondeAcquisition.
%
% It seems the above is in error, this checks out with
% SpectraPlotterMap (see test below):
dBm = 10*log10(abs(v2)) - 40 + 5.8;

% Output phase in degrees
deg = atand(imag(v2)./real(v2));

end

% --------------------------------------------------------
function test_case
% TEST CASE

% FROM SPECTRA PLOTTER
% Some numbers from CSQ_cop1_08_12_06_202548.cs, range 14, doppler 269
% A1, A2, A2 (shows volts??), 

v2 = [7.6137e-9 9.8172e-9 7.8471e-8];
dB = [-115.4 -114.3 -105.3];

run_check(dB,round(volts2dbm(v2).*10)./10)

% A13, A23, A12 (complex numbers)
v2 = [4.216e-9 - 2.408e-8i; 2.769e-8 + 1.846e-9i; 9.214e-10 - 8.596e-9i ];
dB = [-110.3; -109.8; -114.8 ];
ph = [-80.1; 3.8; -83.9];

[dBm,deg] = volts2dbm(v2);

run_check(dB,round(dBm.*10)./10)
run_check(ph,round(deg.*10)./10)

keyboard
end

% --------------------------------------------------------
function run_check(db,v2)

if isequal(db,v2)
    disp('test passed')
else
    disp('test not passed'), keyboard
end


end