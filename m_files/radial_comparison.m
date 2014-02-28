function radial_comparison(R1,R2)
% RADIAL COMPARISON - compare radials along and near baseline
% radial_comparison(R1,R2)
%
% Given 2 temporally concatenated radial structures, 
% produces plots of baseline comparisons, spatial maps of r^2 and rms
% difference, and other comparison stats.
%
% EXAMPLE
%
%   % Load data into radial struct:
%   wkdir = '/projects/drifter_simulation/pws/data/radials/5deg/KNOW/';
%   flist = dir([wkdir 'RDL*']);
%   R1 = loadRDLFile(strcat(wkdir,{flist.name}));
%
%   wkdir = '/projects/drifter_simulation/pws/data/radials/5deg/SHEL/';
%   flist = dir([wkdir 'RDL*']);
%   R2 = loadRDLFile(strcat(wkdir,{flist.name}));
%  
%   % Temporal Concat:
%   R1 = temporalConcatRadials_exact(R1);
%   R2 = temporalConcatRadials_exact(R2);
% 
%   % Run the comparison
%   radial_comparison(R1,R2)

% Copyright (C) 2010 Brian Emery
% re-write, May 2010

% TO DO
% test on 1 deg radials too
% spatial autocorrlation functions along baseline?
% histograms of mid points, scatterplots?

% NOTE
% r2 significance based on 6 hr decorrelation time might not be valid
% r2 vs time plots use 1 hr decorr time


%% ----------------------------------------------------------
%  FIND OVERLAPPING DATA
%------------------------------------------------------------

% Optionally run test
if strcmp(R1,'--t')
   test_case 
end


% GET COINCIDENT TIMES ONLY
% Limit the input radial structures to overlapping times only 
% (include NaNs to show gaps)
[c,ia,ib] = intersect(round(R1.TimeStamp*24),round(R2.TimeStamp*24));

if isempty(c)
    disp('no overlapping times'), keyboard
end

% Apply indexing to radial structs
R1 = subsrefRADIAL(R1,':',ia);
R2 = subsrefRADIAL(R2,':',ib);



% FIND COMPARISON POINTS
% Get the baseline, mid point, and patch location indecies. 
R1 = find_baseline(R1,R2.SiteOrigin);
R2 = find_baseline(R2,R1.SiteOrigin);



%% ----------------------------------------------------------
%  PLOTS
%------------------------------------------------------------

% ALONG BASELINE
% plots vs range between sites
plots_along_baseline(R1,R2)


% PLOTS FOR ONE VS OTHER
% plot mid point and cloud of r2, rms, then timeseries of midpoint and 
% best agreement (3 subplots, rms and r2 vs time)
plot_maps_and_timeseries(R1,R2)




end


%% ------------------------------------------------------------------------
function R1 = find_baseline(R1,SiteOrigin)
% FIND BASELINE INDEX
% [rdx,min_diff] = find_baseline(R1,SiteOrigin)
% input: radial struct and lonlat of 2nd site
%
% output: row index of points from one (!) HFR site which are along the 
% bearing pointing at the 2nd site.  
%
% Note that it's possible that 2 sites have a baseline and also share the
% same look direction (such as if one site is on an island). This gets all
% the possible overlaping points



% GET BASELINE BEARING
% dist.m outputs forward and reverse bearings cwN, distance in meters
[r,af,ar] = dist([R1.SiteOrigin(2) SiteOrigin(2)],[R1.SiteOrigin(1) SiteOrigin(1)]);

% convert to ccwE
af = cwN2ccwE(af);



% FIND NEAREST BEARING 
% find bearing in radial structures nearest the true bearing
% get unique bearings
ub = unique(R1.RangeBearHead(:,2));

% get index of bearing nearest baseline
[min_diff,j]= min(abs(ub - af));



% GET BASELINE AND CENTER POINT INDICIES
% get row indecies (maximal possible overlap)
rdx = find(R1.RangeBearHead(:,2) == ub(j) | R1.RangeBearHead(:,2) == (ub(j) - 180));

% output mid point absolute index also
[m,k] = min(abs(r/2000 - R1.RangeBearHead(rdx,1)));
mpi = rdx(k);



% GET PATCH INDEX
% get range, bearing of midpoing
rb = R1.RangeBearHead(mpi,1:2);

% find radials near center
pdx = find(R1.RangeBearHead(:,1) < rb(1)+10 & ...
           R1.RangeBearHead(:,1) > rb(1)-10 & ...
           R1.RangeBearHead(:,2) < rb(2)+30 & ...
           R1.RangeBearHead(:,2) > rb(2)-30); 



% ASSIGN TO OUTPUT STRUCTURE
R1.baselineIndex = rdx;
R1.midPtIndex = mpi;
R1.patchIndex = pdx;

end
%% ------------------------------------------------------------------------
function [R1,R2] = get_coincident_locations(R1,R2)
% GET COINCIDENT LOCATIONS
% This will find the range/bearing 'grid' points that are within some
% tolerance of eachother. Keep the actuall locations in LonLat, but
% otherwise organize R2 to have same size, directly comparable fields to R1.

% Get range bin with
bw = mode(diff(unique(R1.RangeBearHead(:,1))));

% compute xy km relative to R1.SiteOrigin
[x1,y1] = lonlat2km(R1.SiteOrigin(1),R1.SiteOrigin(2), ...
                                            R1.LonLat(:,1),R1.LonLat(:,2));
[x2,y2] = lonlat2km(R1.SiteOrigin(1),R1.SiteOrigin(2), ...
                                            R2.LonLat(:,1),R2.LonLat(:,2));
  
% COMPUTE DISTANCES
% cartesian should be ok

% expand into matricies 
x1 = repmat(x1(:),1,length(x2));
y1 = repmat(y1(:),1,length(x2));
x2 = repmat(x2(:)',size(x1,1),1);
y2 = repmat(y2(:)',size(x1,1),1);

% compute dist
d = sqrt( (x2-x1).^2 + (y2-y1).^2);


% GET INDEXING
% For example, the first column of d is the dist between each point in R1
% with the first point in R2 ... 
[mn,r1] = min(d);
r2 = find(mn < bw);
r1 = r1(r2); 
                                        
% apply indexing
R1 = subsrefRADIAL(R1,r1,':');
R2 = subsrefRADIAL(R2,r2,':');



return
% test plotting
figure
plot(R2.LonLat(:,1),R2.LonLat(:,2),'c.'), hold on
plot(R1.LonLat(:,1),R1.LonLat(:,2),'go')

figure
plot(R2.LonLat(:,2),R1.LonLat(:,2),'.')
plot(R2.LonLat(:,1),R1.LonLat(:,1),'.')

end
%% ------------------------------------------------------------------------
function [rsqrd,n,tr2,tf] = r2_vs_time(x,y,t,w)
% R2 VS TIME.M - here, no figure making
% [rsqrd,n,t]=r2_vs_time(x,y,t,w)
% sample correlation coefficient squared vs. time based on rsquared.m,
% which is from Geog 276 notes (p 4-12) and Bendat and Piersol's
% RANDOM DATA, p30.
%
% Input arrays x,y,t must be vectors of the same size.
% 'w' is the window length. The window is time centered,
% and the output array will be length(x)-w long.
%
% Version 2 uses the brute force method to compute r2vstime

% Copyright (C) 2001-2010 Brian Emery
% 17Sep2001

% Make a matrix out of the vector to drop into rsquared.m, with each
% row offset by one so that rsquared.m is tricked into computing a
% moving window r2.

warning off

% make columns
x=x(:);
y=y(:);

% get sizes
[r,c]=size(x);
if r~=size(y,1) | c~=size(y,2)
    disp('Input arrays x,y,t must be vectors of the same size!')
    return
end

% create the indexing of the points within the window
w1=1:r-w;
w2=w:r-1;

% init outputs
[rsqrd,n,tr2,tf] =deal(NaN(length(w1),1));

% Run a loop the length of w1
for i=1:length(w1)

    % Use the rsquared function 
	[rsqrd(i),n(i),rxy,val,tf(i)]=rsquared(x(w1(i):w2(i)),y(w1(i):w2(i)));
    tr2(i) = t(w1(i)+round(w/2));
    
end

% Blank results with low N
rsqrd(n< (w/3)) = NaN;

end
%% ------------------------------------------------------------------------
function LABS = get_labels
% GET LABELS - get labels from a 'database'
% LABS = get_labels(fn)
% 
% Given a field name such as 'ERTC', produces a LABS structure
% such as:
% 
% LABS.ERTC = 


flds = {'LOND'; 'LATD'; 'VELU'; 'VELV'; 'VFLG'; 'ESPC'; 'ETMP'; ...
        'MAXV'; 'MINV'; 'EDVC'; 'ERTC'; 'XDST'; 'YDST'; 'RNGE'; ...
        'BEAR'; 'VELO'; 'HEAD'; 'SPRC'};

c = {'Longitude (deg)'; 'Latitude (deg)'; 'U (cm/s)'; 'V (cm/s)'; ...
    'VectorFlag'; 'Spatial Quality'; 'Temporal Quality'; ...
    'Velocity Maximum'; 'Velocity Minimum'; 'Quality DVCount'; ...
    'Quality RTCount'; 'X Distance (km)'; 'Y Distance (km)'; ...
    'Range (km)'; 'Bearing (deg cwN)'; 'Velocity (cm/s)'; ...
    'Direction (deg cwN)'; 'Spectra Range Cell'};   

LABS = cell2struct(c,flds,1);



end
%% ------------------------------------------------------------------------
function test_case

% need a test data repository
load /Users/codar_restore/Desktop/radial_comparison.mat

% run it ...
radial_comparison(R1,R2), keyboard
radial_comparison(R2,R1)

keyboard

plot(R2.LonLat(:,1),R2.LonLat(:,2),'c.')
hold on
pws_map
plot(R1.LonLat(:,1),R1.LonLat(:,2),'g.')

end



%% ------------------------------------------------------------------------
% BASELINE PLOT FUNCTIONS
function plots_along_baseline(R1,R2)
% PLOTS ALONG BASELINE
% generalize by field name
% plot correlations, rms along baseline
% have some spatial/temporal stats too
%


%% ----------------------------------------------------------
%  FIND BASELINE RADIALS
%------------------------------------------------------------

% Limit radials structs locations along baseline only
R1 = subsrefRADIAL(R1,R1.baselineIndex,':');
R2 = subsrefRADIAL(R2,R2.baselineIndex,':');

% Now limit these to points that are close to eachother only
% (within the radial range increment)
[R1,R2] = get_coincident_locations(R1,R2);



%% ----------------------------------------------------------
%  CALCS FOR PLOTS
%------------------------------------------------------------

[rmsd,bias,N] = rmsdiff(R1.RadComp,R2.RadComp);

[r2,n,rxy,val,tf] = rsquared(R1.RadComp,R2.RadComp,6);


%% ----------------------------------------------------------
%  PLOTS
%------------------------------------------------------------


% PLOT R SQUARED and RMS DIFFERENCE

figure

%  create the subplot axes
haxes=makesubplots(2,1,.05,.05);

axes(haxes(1))

h1 = plot_signif(R1.RangeBearHead(:,1),rmsd,tf,'b','o');
h2 = plot_signif(R1.RangeBearHead(:,1),abs(bias),tf,'g','o');
legend([h1 h2],{'RMS Diff','|Bias|'})
set(gca,'XtickLabel',''),ylabel('cm/s')
title(['Comparison Stats ' R1.SiteName ' and ' R2.SiteName])

axes(haxes(2))

h1 = plot_signif(R1.RangeBearHead(:,1),r2,tf,'b','o');
h2 = plot_signif(R1.RangeBearHead(:,1),N/max(N),tf,'g','o');
legend([h1 h2],{'r^2',['N/' num2str(max(N))]})
xlabel(['Range from ' R1.SiteName ' (km)'])

publicationStandards




% PLOT OTHER MATRIX VARIABLES
% ESPC, ETMP, Min/Max V, EDVC and ERTC

% define colors
c1 = 'b'; c2 = 'g';

figure

%  create the subplot axes
haxes=makesubplots(4,1,.05,.05);

axes(haxes(1))
h1 = plot_otm_mean_stdev(R1,'ESPC',c1);
h2 = plot_otm_mean_stdev(R2,'ESPC',c2);
legend([h1 h2],R1.SiteName,R2.SiteName)

title('Means with Standard Deviations')

axes(haxes(2))
h1 = plot_otm_mean_stdev(R1,'ETMP',c1);
h2 = plot_otm_mean_stdev(R2,'ETMP',c2);

axes(haxes(3))
h1 = plot_otm_mean_stdev(R1,'MAXV',c1);
h2 = plot_otm_mean_stdev(R2,'MAXV',c2);
h1 = plot_otm_mean_stdev(R1,'MINV',c1);
h2 = plot_otm_mean_stdev(R2,'MINV',c2);

axes(haxes(4))
h1 = plot_otm_mean_stdev(R1,'EDVC',c1,1); %<- keep xlabels
h2 = plot_otm_mean_stdev(R2,'EDVC',c2,1);  
h1 = plot_otm_mean_stdev(R1,'ERTC',c1,1);  
h2 = plot_otm_mean_stdev(R2,'ERTC',c2,1);  

xlabel(['Range from ' R1.SiteName ' (km)'])

publicationStandards



end
%% ------------------------------------------------------------------------
function h1 = plot_otm_mean_stdev(R1,otm,clr,t)
% PLOT MEAN and STDEV
% compute and plot mean and standard deviation of field in
% OtherMatrixVars given by otm (such as 'EDVC'). Plot vs range.

% Rename range
rng = R1.RangeBearHead(:,1);

% compute mean, stdev
[xbar,stdev,hi,lo,median,n] = stats_noNaN(R1.OtherMatrixVars.(otm));

% add to current axes
h1 = plot(rng,xbar,'-b.'); hold on
h2 = plot(rng,xbar+stdev,'--b');
h3 = plot(rng,xbar-stdev,'--b');

% set color
set([h1 h2 h3],'Color',clr)

% set stdev lines thinner 
set(h1,'LineWidth',1.5)
set([h2 h3],'LineWidth',0.7)


% set y label, make it additive if previous labels exists
LABS = get_labels;
str = get(get(gca,'ylabel'),'String');
if ~iscell(str), str = {str}; end

if isempty(str{1})
    ylabel(LABS.(otm))
else
    str{end+1} = LABS.(otm); str = unique(str);
    ylabel(str)
end



% set xlabels
if nargin < 4, set(gca,'XTickLabel',''), end

end
%% ------------------------------------------------------------------------
function h2 = plot_signif(rng,y1,tf,clr,ls)
% PLOT SIGNIF
% plot data twice, showing insignificant data more lightly

% plot all data
h1 = plot(rng,y1,['--' ls]); hold on

% apply significance. NaN's allow gaps in plot
y1(~tf) = NaN;

% replot significant data
h2 = plot(rng,y1,['-' ls]); hold on

set(h1,'Color',clr,'MarkerFaceColor','w','LineWidth',0.6)
set(h2,'Color',clr,'MarkerFaceColor',clr)

end


%% ------------------------------------------------------------------------
% MAP AND TIMESERIES PLOT FUNCTIONS
function plot_maps_and_timeseries(R1,R2)
% PLOTS MAPS AND TIMESERIES
% plot_maps_and_timeseries(R1,R2)
%
% Compares selection of points in R2 with the baseline midpoint in R1.


% plot mid point and cloud of r2, rms, then timeseries of midpoint and 
% best agreement (3 subplots, rms and r2 vs time)


%% ------------------------------------------
%  CALCULATIONS
%------------------------------------------

% Get Radial Velocities
v1 = ones(length(R2.patchIndex),1)* -R1.RadComp(R1.midPtIndex,:);
R2 = subsrefRADIAL(R2,R2.patchIndex,':');

% Compute stats
[rsqrd,n,rxy,val,tf] = rsquared(v1,R2.RadComp,6);
[rmsd,bias,N] = rmsdiff(v1,R2.RadComp);

% Find best locations for timeseries plots
% best numbers will have highest index
[y,i] = sort(rsqrd);
[y,j] = sort(rmsd,1,'descend');
[y,k] = sort(N(:));

% % weight rms, r2 more than N (not sure this is right ...)
% [mx,best] = max(mean([1.2*i 1.2*j 0.6*k],2)); R2.best = best;
[mx,best] = max(mean([i j k],2)); R2.best = best;

% compute r2, rms vs time, 36 point window
window = 72;
[rsqrd_t,n_t,t,tf_t]  = r2_vs_time(-R1.RadComp(R1.midPtIndex,:),R2.RadComp(best,:),R1.TimeStamp,window);
[rmsd_t,t_rms] = rmsd_vs_time(-R1.RadComp(R1.midPtIndex,:),R2.RadComp(best,:),R1.TimeStamp,window);


%% ------------------------------------------
%  SPATIAL PLOT
%------------------------------------------

figure
haxes=makesubplots(2,2,.05,.05);
 
radial_map(haxes(1),R2,rsqrd,'r^2',R1)

ht = title([R2.SiteName ' compared with ' R1.SiteName ...
    ' baseline midpoint (white squares show best and mdpt)']);
set(ht,'HorizontalAlignment','left')

radial_map(haxes(2),R2,n,'N',R1)
radial_map(haxes(3),R2,rmsd,'RMS Diff',R1)
radial_map(haxes(4),R2,bias,'Bias',R1)

publicationStandards


%% ------------------------------------------
%  TIMESERIES PLOT
%------------------------------------------
figure
haxes=makesubplots(3,1,.05,.05);
  
axes(haxes(1))

plot_timeseries(-R1.RadComp(R1.midPtIndex,:),R2.RadComp(best,:), ...
    R1.TimeStamp,'-b.','-g.',{R1.SiteName,R2.SiteName})

% h1 = plot(R1.TimeStamp,-R1.RadComp(R1.midPtIndex,:),'-b.'); hold on
% h2 = plot(R1.TimeStamp,R2.RadComp(best,:),'-g.');
ylabel('cm/s')
set(gca,'XtickLabel','')
%legend([h1 h2],R1.SiteName,R2.SiteName)

ht = title([R2.SiteName ' compared with ' R1.SiteName ' baseline midpoint']);


axes(haxes(2))

h1 = plot_signif(t,rsqrd_t,tf_t,'b','.');
h2 = plot_signif(t,n_t/window,tf_t,'g','.');
% h1 = plot(t,rsqrd_t,'-b.');
% h2 = plot(t,n_t/max(n_t),'-g.');
ylabel(['r^2 (' num2str(window) 'hr)'])
set(gca,'XtickLabel','')
legend([h1 h2],'r^2',['N/' num2str(window)])


axes(haxes(3))

h1 = plot_signif(t,rmsd_t,tf_t,'b','.');
% h1 = plot(t,rmsd_t,'-b.');
ylabel('RMS diff (36hr)')


xtickd(2)
publicationStandards


return
% test plot
plot(R1.LonLat(:,1),R1.LonLat(:,2),'go'), hold on
pws_map
plot(R1.LonLat(rdx,1),R1.LonLat(rdx,2),'b.')

end
%% ------------------------------------------------------------------------
function radial_map(haxes,R2,rsqrd,clab,R1)
% RADIAL MAP
% use of radial_display.m with some details
% 
% the last input (R1) is used to add the location of the midpoint radial
% from site 1.

% set axes
axes(haxes)

% plot color map
cbh = radial_display(R2,rsqrd); hold on

% set colorbar string
set(get(cbh,'Ylabel'),'String',clab,'FontSize',14)

% add midpoint location
hm = plot(R1.LonLat(R1.midPtIndex,1),R1.LonLat(R1.midPtIndex,2),'ws');

% add 'best' location
hb = plot(R2.LonLat(R2.best,1),R2.LonLat(R2.best,2),'ws');

% keep them small
set([hm hb],'LineWidth',.6)

% add baseline line
plot([R1.SiteOrigin(1) R2.SiteOrigin(1)],[R1.SiteOrigin(2) R2.SiteOrigin(2)],'--k')

% add basemap
add_map

end
%% ------------------------------------------------------------------------
function add_map
% ADD MAP
% add basemap to spatial figure, does scaling also

limits = axis;
pws_map; % Prince William Sound map
axis(limits);

xlabel('Longitude'), ylabel('Latitude')

% Scaling needed when there is no map:
[ax,sc]=mercat(limits(1:2),limits(3:4));
set(gca, 'DataAspectRatio', [1,sc,1],'PlotBoxAspectRatio',[1,1/ax,1]);

end
%% ------------------------------------------------------------------------
function plot_timeseries(x,y,t,cx,cy,leg_cell)
% PLOT TIMESEREIS
% from the function of the same name, customized here

h1 = plot(t,x,cx); hold on
h2 = plot(t,y,cy);

% now compute r squared and rmsdiff
[r2,n]=rsquared(x,y);
i=find(~isnan(x+y));
[r,pval]=corrcoef(x(i),y(i));
rmsd = rmsdiff(x,y);

% create legend
legend([h1 h2],leg_cell)

% add to legend
legh=addTextLikeLegend({ ...
    ['r^2 = ' num2str(r2,2)], ...
    ['N = ' num2str(n,5)], ... 
    ['p =' num2str(pval(1,2),3)], ...
    ['rmsd = ' num2str(rmsd,2) ' cm/s'] ...
    });

set(legh,'Location','SouthWest','FontSize',9)

end


