function [rsqrd,n,rxy,val,tf] = rsquared(a,b,opt)
% RSQUARED.M - sample correlation coefficient squared
% [rsqrd,n,rxy,val,tf] = rsquared(a,b,opt)
% 
% Compute the sample correlation coefficient squared based on Geog 276b
% notes (p 4-12) and Bendat and Piersol's RANDOM DATA, p30.
%
% INPUTS
% a and b, timeseries, must be the same size, accept matricies with time
%   incrementing columnwise
% opt, decorrlation scale (non-dimensional index), defaults to 1. This 
%   is equivalent to assuming the number of degrees of freedom is equal to
%   the number of data points (probably not true for  most oceanographic
%   timeseries)
%
% OUTPUTS
% r^2, the sample correlation coefficient squared
% n, the number of data points
% rxy, the sample correlation coefficient
% val, the test statistic
% tf, boolean, true if rsqrd is significant at 95% level
%
% EXAMPLE
% % Run the optional test case:
% [rsqrd,n,rxy,val,tf] = rsquared('--t');
%
% NOTES
% The decorrelation scale is used to estimate the degrees of freedom in the
% significance calculation. The decorrelation scale is estimated from the
% autocorrlation function, usually the e-folding time.
% 
% Try for example:
% Rxx = autocorrelfxn3(a,length(a)/2);
% 
% For p-values, see matlab's corrcoef.m, for example:
% [r,pval]=corrcoef(a,b); pvalue = pval(1,2);

% Copyright (C) 1996-2010 Brian Emery
%
% Expanded to include matricies         20 Mar 1999
% Improved logic of significance output 17 Jun 2010


%% --------------------------------------- 
%  INPUT OPTIONS
%--------------------------------------- 

% RUN TEST CASE?
if strcmp(a,'--t')
    [rsqrd,n,rxy,val,tf]= test_case; return
end

% set default option
if nargin==2, opt=1; end

% check inputs
if size(a)~=size(b)
    disp('Error (input data must be the same size)')
    keyboard
end


%% --------------------------------------- 
%  COMPUTE R^2
%--------------------------------------- 


% detects col vectors and arranges them as rows
[row,col]=size(a);
if col==1
    a=a'; b=b'; row = 1;
end

% initialize output variables
[n,val,rxy] = deal(NaN(row,1));


% COMPUTE ith RXY IGNORING NANS
% run a loop one row at a time
for i=1:row

    % get rid of NaN's, j is the column index
    j = find(~isnan(a(i,:)+b(i,:)));

    % remove means
    x=a(i,j)-mean(a(i,j));
    y=b(i,j)-mean(b(i,j));

    rxy(i)=-((mean(x.*y))/(sqrt(mean(x.^2).*mean(y.^2))));
    n(i)=length(j);
    clear x y
      
end

% compute r^2
rsqrd= rxy.^2;


%% --------------------------------------- 
%  COMPUTE SIGNIFICANCE
%--------------------------------------- 

% Define zeta 
% from Bendat and Piersol table A.2
zeta=1.96;

% define logical tf
tf = false(size(n));
    
% estimate degrees of freedom
N = n/opt;

% compute val (test statistic)
val = sqrt(N-3).*0.5.*log((1+rxy)./(1-rxy));

% statistically significant at the 95% level
tf(val < -zeta | val > zeta) = true;
    

end

%% -----------------------------------------------------------------------
function [rsqrd,n,rxy,val,tf] =  test_case

% FROM rms_vs_r2.m

% Notes documenting the different meanings of r2 and
% rms difference stats when they are used with HF radial
% and CM data to determine the angle offset dtheta

% MAKE UP A MATRIX OF TIMESERIES
x=1:1000;
a=25;
y=a.*sin(2*pi*x/100);

% magnitude diffs
y(2,:) = 2*y;
% phase shifts
y(3,:) = a.*sin(2*pi*x/100 + pi/2);
y(4,:) = a.*sin(2*pi*x/100 + pi  );
y(5,:) = a.*sin(2*pi*x/100 + pi/4);
y(6,:) = a.*sin(2*pi*x/100 + pi/8);

% 2nd ts
y2 = ones(6,1)*y(1,:);



% COMPUTE R2's

% should give this:
% rsqrd =
%     1.0000
%     1.0000
%     0.0000
%     1.0000
%     0.5000
%     0.8536
[rsqrd,n,rxy,val,tf] = rsquared(y,y2);

keyboard

% Result:
% using y and y2 shows r2=1 (r2 unrelated to magnitude)
% and rmsdiff gives zero bias and 17.6777 as the rmsdiff
% which is the difference of the standard deviations of the
% two timeseries's

% TEST PHASE SHIFT
% Phase shift=[pi/2 pi pi/4 pi/8]
% rms diff   =[25 35 13.5 6.9]
% r2         =[0 1 0.5 .85]


% test decorrelation scale
[rsqrd,n,rxy,val,dcorr] = rsquared(y,y2,5);

 keyboard
 end