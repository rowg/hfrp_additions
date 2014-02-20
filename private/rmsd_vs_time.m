function [rmsd,trd,N,bias]=rmsd_vs_time(x,y,t,w)

% R2VSTIME2.M
% [rmsd,t]=rmsdvstime(x,y,t,w)
% Computes the unbiased root-mean-square difference
% between 2 timeseries as a function of time, using
% rmsdiff.m
%
% Input arrays x,y,t must be vectors of the same size. 
% 'w' is the window length (# data points). The window is time centered,
% and the output array will be length(x)-w long.
% 
% based on r2vstime.m

% Copyright (C) 2002-2010 Brian Emery
% 5june2002

% make cols
x=x(:);
y=y(:);

% check sizes
[r,c]=size(x); 
if r~=size(y,1) || c~=size(y,2)
   disp('Input arrays x,y,t must be vectors of the same size!')
   return
end

% create the indexing of the points within the window
w1=1:r-w;
w2=w:r-1;

% init outputs
[rmsd,trd,N,bias] =deal(NaN(length(w1),1));

% Run a loop the length of w1
for i=1:length(w1)
	% Use the rmsdiff function, requires row vectors 
	[rmsd(i),bias(i),N(i)] = rmsdiff(x(w1(i):w2(i))',y(w1(i):w2(i))');
    trd(i) = t(w1(i)+round(w/2));   
end

% Blank results with low N
rmsd(N < (w/3)) = NaN;


return


% Now plot
figure
subplot(3,1,2)
plot(t,x,'b'), hold on, plot(t,y,'r')
legend(inputname(1),inputname(2))
datetick('x',6)
a=axis;

subplot(3,1,1)
plot(trd,rmsd), hold on
title([inputname(1) ' - ' inputname(2) ' r^2 vs. time ' num2str(w) ' point moving window'])
axis([a(1:2) 0 1])
datetick('x',6)


subplot(3,1,3)
plot(trd,n), hold on, plot([trd(1) trd(length(trd))],[w w],'k:')
legend('#pts used',['of ' num2str(w) ' possible'])
b=axis;
axis([a(1:2) b(3:4)])
datetick('x',6)
xlabel(['month/day ' datestr(trd(1),10) ' (' datestr(trd(1),1) ' to ' datestr(trd(length(trd)),1) ')'])

plotsize

 i=find(n>84);
 subplot(3,1,3)
 plot(trd(i),n(i),'b.')
 axis([a(1:2) b(3:4)])
 subplot(3,1,1)
 plot(trd(i),rmsd(i),'b.')
 axis([a(1:2) 0 1])
 
% Check plots can be made using the code below
% keyboard
% i=1000; [rd,num,val]=rsquared(x(w1(i):w2(i))',y(w1(i):w2(i))');
% subplot(3,1,1), plot(t(w1(i)+round(w/2)), rd,'r*')

end