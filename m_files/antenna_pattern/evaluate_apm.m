function APM = evaluate_apm(file)
% EVALUATE APM.M
% APM = evaluate_apm(file);
% evaluate Lack of diversity (as a function of bearing) in an antenna
% pattern measurment, following the method described in:
%
% de Paolo, T.; Cook, T.; Terrill, E.; , "Properties of HF RADAR Compact
% Antenna Arrays and Their Effect on the MUSIC Algorithm," OCEANS 2007 ,
% vol., no., pp.1-10, Sept. 29 2007-Oct. 4 2007,
% doi: 10.1109/OCEANS.2007.4449265
%
% d^2 values above 10.6 seem to be 'too close'
%
% First define each antenna manifold point in signal 
% space, from section 2: 
%	Ai (theta) = amplitudei * e^(j*phasei);  where  [j is sqrt(-1)?]
% then compute the matrix of distances between points on the manifold in
% signal space. Output a plot showing bad areas.
%
% Example code:
% cd('/Data/SSD APM/20080122/PATT_ssd1_2008_01_24_0334.xlp')
% file='SEAS_ssd1_2008_01_24_0334.patt';
% evaluateAPM(file)
%
% cd('/Data/Analysis_data/codar_mfiles/studys/divergenceProblem/PATT_cop1_2003_05_08.xlp')
% evaluateAPM('SEAS_cop1_2003_05_08_1655.patt')
%
% RUN A TEST CASE
% evaluate_apm('--t')


% NOTE: His equation 5.1.1.1 calls for the complex conjugate but my numbers
% are not complex

% TO DO
% WHY do 2 bearings show up in d^2 find command? Make sure Surf is working 
% correctly, make sure bearings from APM match with radials from the time
% 1) make sure the all the bearings are right
% 2) 'evaluate it' means identify bad bearings, and how bad they are
% 3) Develope a test case that takes an ideal pattern distorts it, and
%   shows how the distortion is evaluated.
% 5) fix the use of the COS ideal pattern in the example
% 4) be able to load in any type of apm file 
% IDEA: look at plot of the real and imaginary parts, their sum, or the
% sum of loop 1 (re+im) vs loop2 ?
% ADD USE OF createdBy(pltSvDir).m

% Copyright (C) 2008-2010 Brian M. Emery
% Version 1.0 26Feb2008 based on: 
% "Properties of HF RADAR Compact Antenna Arrays and Their Effect on the
% MUSIC Algorithm, by Tony De Paolo and Eric Terrill, SIO, Nov. 9, 2007

% TEST CASE switch
if strcmp('--t',file)
    test_case, return
end


%% ---------------------------------------------------------
%  LOAD APM DATA
%---------------------------------------------------------

% load the measured pattern
APM = load_pattern_file(file);

% get an ideal version
iAPM = make_ideal_pattern(APM.loop1Brg,0:5:355);


%% ---------------------------------------------------------
%  RUN CALCS
%---------------------------------------------------------

% Measured AP
APM = calc_manifold_dists(APM);

% Ideal AP
iAPM = calc_manifold_dists(iAPM);



%% ---------------------------------------------------------
%  MAKE PLOTS
%---------------------------------------------------------

% Plots like Tony's figures
surface_plot(APM,iAPM)


% COS like plot
plot_apm_polar(APM)


end


%% ---------------------------------------------------------------------
function APM = calc_manifold_dists(APM) 
% CALC MANIFOLD DISTS - compute the dist between APM points in signal space
% 
% Compare each APM bearing with all other bearings, computing the distance
% between points in signal space.
% 
% In signal space the APM should have unique, equally spaced points for
% each bearing. This code is Tony's equation in section 5.1.1.1.
% 
% First,compute antenna manifold in signal space
% The amplitudes and phases of each antenna make up one component each of
% the antenna manifold. The antenna manifold thus has 4 dimensions (the 
% monopole is used only to normalize). I think the signal space can have 6
% dimensions, while the ideal pattern has essentially 2 dimensions because the others
% are 0 or 1. Also note that the Amplitudes and phases can be combined
% thus: A1cos(phase1), A1sin(phase1), etc which is also done below.
% 
% Am = (magnitude of amplitudes) * e^(i*phase)
% Am1=a13m.*exp(j.*(a13p.*pi./180));
% Am2=a23m.*exp(j.*(a23p.*pi./180));
% % remember, A(theta)= (Am1,Am2), with the 2 components 
% A=[Am1 Am2];

% Copyright (C) 2008-2010 Brian M. Emery

% Check for fields
flds = {'A13M','A13P','A23M','A23P'};
field_check(APM,flds)

% Assign variable names
for i = 1:length(flds)
    eval([lower(flds{i}) '= APM.(flds{i})(:);'])
end

% make sure input magnitudes are normalized (?)
a13m=a13m./max(a13m);
a23m=a23m./max(a23m);
 
% A is a matrix, each column a new bearing, each row a component
A=[a13m.*cos(radians(a13p)) a13m.*sin(radians(a13p)) a23m.*cos(radians(a23p)) a23m.*sin(radians(a23p))]';


% get the number of bearings
numBrg=size(A,2);

% preallocate space. Keep the denominator too:
d2(1:numBrg,1:numBrg) = NaN;
denom(1:numBrg,1:numBrg) = NaN;

% Nested loops to make sure it's right. Some testing code here too:
for n=1:numBrg
    a=A(:,n);
    for m=1:numBrg
        denom(n,m) =  sqrt((conj(a-A(:,m) ))'*(a-A(:,m)));
    end
    % % testing code, should give about 10.6
    % keyboard
    % n=1;m=2;
    % a=A(:,n);
    % 10*log10(1./sqrt(  (conj( a-A(:,m) ))' *(a-A(:,m))   ))
end
    
% Units (I think): the Amplitudes from the antennas are ratios. Take the
% base 10 log of these and the (dimensionless) unit becomes dB
d2keep=(1./denom); % no units
d2 = 10*log10(1./denom); % in dB

% "artificially limit max to 16 dB"
d2(d2 == Inf)=16;

% Store outputs
APM.d2 = d2;
APM.d2keep = d2keep;
APM.denom = denom;

end

%% ---------------------------------------------------------
function surface_plot(APM,iAPM)
% SURFACE PLOTS - color surface plots of d^2 between bearings

tstr = 'Inverse Distance in Signal Space (16 dB = Inf)';

figure

subplot(211)
surface_subplot(APM.d2,APM.denom,APM.BEAR)
title([APM.SiteName ' ' datestr(APM.CreateTimeStamp,'yyyymmdd') tstr],'interpreter','none')

subplot(212)
surface_subplot(iAPM.d2,iAPM.denom,iAPM.BEAR)
title(['Ideal ' tstr])

set(gcf,'units','inches','position',[1.8946    0.5737    7.3515   10.2067])
set(gcf,'PaperPosition',[1.8946    0.5737    7.3515   10.2067])

end
%% -----------------------------------------------------------------------
function surface_subplot(dSquared,denom,bear)

h = surf(bear,bear,real(dSquared)); set(h,'EdgeColor','interp')
view(2)
caxis([min(min(dSquared)) 16])
%axis([-90 90 -90 90])
axis([min(bear) max(bear) min(bear) max(bear)]) 
xlabel('Bearing (^oCWN)')
ylabel('Bearing (^oCWN)')
colorbar('EastOutside')


end

%% -----------------------------------------------------------------------
function test_case
% TEST CASE
% TEST code. Run this with the test case function uncommented:

file = '/projects/divergence_problem/data/PATT_cop1_2003_05_08.xlp/SEAS_cop1_2003_05_08_1655.patt';
APM = evaluate_apm(file);

keyboard

file = '/Data/SSD APM/PATT_ssd1_ideal_239deg.xlp/SEAS_ssd1_2008_02_26_0704.patt';
APM = evaluate_apm(file);




% %% test case 2: Distort Pattern ----------------------------------------
% function dat=distortAPM(dat,badBrg1,badBrg2);
% % Test Case 2. designed to be able to insert this into the main function,
% % this will take data at a bearing and make it the same as at another
% % bearing, showing how the output plot works.
% %
% % Only really designed to work with Ideal patterns.
% disp(['RUNNING TEST CASE: Bearing ' num2str(badBrg1) ...
%     ' now equal to ' num2str(badBrg2)])
% 
% % make two bearings the same, or close or ?
% idx=find(dat(:,1)==badBrg1);
% jdx=find(dat(:,1)==badBrg2);
% 
% dat(idx,2:end)=dat(jdx,2:end);
% 
% % try adding small tweaks to the data instead of a full on swap
% 
% % output some standard plots to see what it looks like
% 
% end

end







