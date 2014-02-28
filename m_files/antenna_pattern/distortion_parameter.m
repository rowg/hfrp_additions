function adp = distortion_parameter(APM)
% DISTORTION PARAMETER - compute distortion parameter for an APM
% adp = distortion_parameter(APM)
%
% Compute the distortion parameter as defined in:
%
% Laws, Kenneth, Jeffrey D. Paduan, John Vesecky, 2010: "Estimation and
% Assessment of Errors Related to Antenna Pattern Distortion in CODAR
% SeaSonde High-Frequency Radar Ocean Current Measurements". J. Atmos.
% Oceanic Technol., 27, 1029?1043. doi: 10.1175/2009JTECHO658.1
%
% Typical values are 0.14 to 0.81. For values above 1, expect RMS errors
% near about 7 cm/s.
%
% EXAMPLE:
% % Load APM:
% APM = load_pattern_file('MeasPattern.txt');
%
% % Compute distortion parameter:
% adp = distortion_parameter(APM)

% Adapted from Kip Law's antDistParam.m
% 5 Nov 2010 by Brian Emery
%   - modifications to comply with my APM tools

adp = antDistParam(APM.BEAR,APM.A13R,APM.A13I,APM.A23R,APM.A23I);

end
%% ------------------------------------------------------------
function patDistParam  = antDistParam(lookDirs,realAmp1,imagAmp1,realAmp2,imagAmp2)
% This fit allows the real and imaginary components to have different
% phases DC offsets and amplitudes.  This technique usualy does a very
% good job of placing the fit where it would be placed by eye.

%fit loop 1
[amp1,amp2,phase11,phase12,off11,off12] = csensfit(lookDirs,realAmp1,imagAmp1);
fitRealAmp1 = off11 + amp1*cos(lookDirs*pi/180 + phase11);
fitImagAmp1 = off12 + amp2*cos(lookDirs*pi/180 + phase12);
%fit1 = [amp1,amp2,phase11,phase12,off11,off12];

%fit loop 2
[amp1,amp2,phase21,phase22,off21,off22] = csensfit(lookDirs,realAmp2,imagAmp2);
fitRealAmp2 = off21 + amp1*cos(lookDirs*pi/180 + phase21);
fitImagAmp2 = off22 + amp2*cos(lookDirs*pi/180 + phase22);
%fit2 = [amp1,amp2,phase21,phase22,off21,off22];


% %this time as magnitude and phase
% fitAmp1 = abs(fitRealAmp1 + i*fitImagAmp1);
% fitAmp2 = abs(fitRealAmp2 + i*fitImagAmp2);
% fitphase1 = atan2(fitImagAmp1,fitRealAmp1);
% fitphase2 = atan2(fitImagAmp2,fitRealAmp2);
% amp1 = abs(realAmp1 + i*imagAmp1);
% amp2 = abs(realAmp2 + i*imagAmp2);
% phase1 = atan2(imagAmp1,realAmp1);
% phase2 = atan2(imagAmp2,realAmp2);


%compute the difference between the fits and the signals
%combine the real and imaginary parts to form complex vectors
loopFit1 = fitRealAmp1 + i*fitImagAmp1;
loopFit2 = fitRealAmp2 + i*fitImagAmp2;
loop1 = realAmp1 + i*imagAmp1;
loop2 = realAmp2 + i*imagAmp2;

%do a normalization
m1 = max(abs(loopFit1));
m2 = max(abs(loopFit2));
mmax = max([m1 m2 ]);

%scale everything so that the maximum fit amplitude is equal to one
loopFit1n = loopFit1/mmax;
loopFit2n = loopFit2/mmax;
loop1n = loop1/mmax;
loop2n = loop2/mmax;

%normalize the difference by the amplitude of the loop fit
snrdiff1 = (loopFit1n - loop1n)/mean(abs(loopFit1n));
snrdiff2 = (loopFit2n - loop2n)/mean(abs(loopFit2n));


%     errStdn(n) = std(abs([dif1n dif2n]));
%     errRmsn(n) = sqrt(mean((   abs([dif1n dif2n]).^2     )));
concatSnr = [snrdiff1 snrdiff2];
maxSnr = max([snrdiff1; snrdiff2;]);
meanSnr = mean(abs([snrdiff1; snrdiff2;]));

%snrRms(n) = sqrt(mean((   abs(concatSnr).^2     )));
snrRms = sqrt( mean(meanSnr.^2) );
%snrRms(n) = sqrt(mean((   abs(maxSnr).^2     )));

patDistParam = snrRms;

% %analyze the spectrum of the difference
% real1dif = fitRealAmp1 - realAmp1;
% imag1dif = fitImagAmp1 - imagAmp1;
% real2dif = fitRealAmp2 - realAmp2;
% imag2dif = fitImagAmp2 - imagAmp2;


end
%% ------------------------------------------------------------
function [amp1,amp2,phase1,phase2,off1,off2] = csensfit(theta,yreal,yimag)
% complex antenna sensitivity fitting
% fit a sinusoidal function to the real and imaginary components of the antenna
% sensitivity measurements
% allow different amplitudes, offsets and phases for the real and imaginary
% parts.  Uses a simplex method to minimize the difference between the
% measured antenna sensitivity and the fit


global measSens THETA

THETA = theta;

diagPlot = 0;

if diagPlot
    figure(1), clf, hold on
end

THETA = THETA*pi/180;
Ao = 1; %initial guess at amplitude
phio = 0; %initial guess at phase
offo = 0;   %initial guess at offset


%fit the real part
measSens = yreal;
[x,fval] = fminsearch(@minfunc,[offo, Ao, phio]);
off1 = x(1);
amp1 = x(2);
phase1 = x(3);
fitreal = x(1) + x(2)*cos(theta + x(3));

%fit the imaginary part
measSens = yimag;
[x,fval] = fminsearch(@minfunc,[offo, Ao, phio]);
off2 = x(1);
amp2 = x(2);
phase2 = x(3);
fitimag = x(1) + x(2)*cos(theta + x(3));


if diagPlot
    %plot the fits
    figure(1)
    plot(theta,yreal,'b')
    plot(theta,yimag,'g')
    plot(theta,fitreal,'b--')
    plot(theta,fitimag,'g--')
end


end
%% ------------------------------------------------------------
function obj = minfunc(x)%,THETA,measSens)
% function to be minimized
% this is the difference between the fit and the measured antenna pattern.
% The fit assumes an ideal loop pattern but does not assume ideal values for
% amplitude of the real and imaginary parts, allows for a DC offset and
% fits the phase

global measSens THETA

loopSens = x(1) + x(2)*cos(THETA + x(3));
obj = sum((loopSens- measSens).^2);

end


%% ------------------------------------------------------------
% PLOTTING
function plotting

figure(1), clf   %, hold off
subplot(2,1,1), hold on
plot(lookDirs,realAmp1,'b') %, hold on
plot(lookDirs,imagAmp1,'g')
%     plot(theta,ra1,'b--')
%     plot(theta,ia1,'g--')
%

subplot(2,1,2)
plot(lookDirs,realAmp2,'b'), hold on
plot(lookDirs,imagAmp2,'g')


%plot the fits over the signals
subplot(2,1,1)
plot(lookDirs,fitRealAmp1,'b--')
plot(lookDirs,fitImagAmp1,'g--')
xlabel('radar look angle (deg)')
ylabel('loop 1 sensitivity')
title(fname,'interpreter','none')
subplot(2,1,2)
plot(lookDirs,fitRealAmp2,'b--')
plot(lookDirs,fitImagAmp2,'g--')
xlabel('radar look angle (deg)')
ylabel('loop 2 sensitivity')
legend('real','imaginary')
%set(gcf,'paperposition',[0,0,7,3])
%print -djpeg -r400 sensWithFit


figure(2), clf
subplot(2,1,1), hold on
plot(lookDirs,amp1,'b-')
plot(lookDirs,amp2,'g-')
plot(lookDirs,fitAmp1,'b--')
plot(lookDirs,fitAmp2,'g--')
xlabel('radar look angle (deg)')
ylabel('magnitude')
title(fname,'interpreter','none')
legend('loop 1','loop 2')
subplot(2,1,2), hold on
plot(lookDirs,phase1,'b-')
plot(lookDirs,phase2,'g-')
plot(lookDirs,fitphase1,'b--')
plot(lookDirs,fitphase2,'g--')
xlabel('radar look angle (deg)')
ylabel('phase (rad)')
legend('loop 1','loop 2')
%set(gcf,'paperposition',[0,0,7,3])

end