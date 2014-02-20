function cbh = radial_display(RDL,v)
% RADIAL DISPLAY - make plots like Codar's Radial Display
% cbh = radial_display(RDL,v);
% 
% INPUT
% RADIAL concatenated radial structure (RangeBearHead, SiteOrigin are the
% required fields), and a varible (v) containing the 'z' data at each range and
% bearing.
%
% adds to existing map plot
%
%
% % EXAMPLE
% % MAKE A PERCENT COVERAGE MAP
% % Get RDL structure
% cd([wkdir 'mgs1/RDLm/2010_08/'])
% flist = dir([pwd '/RDL*']);
% RDL = loadRDLFile({flist.name});
% 
% % Concat into a matrix 
% RDL = temporalConcatRadials_exact(RDL);
% 
% % Compute percent coverage (for example)
% v = sum(~isnan(RDL.RadComp),2);
% v = v./max(v) * 100;  v(v<2) = NaN;
% 
% % Create the figure
% figure
% axis([-120.3751 -119.0017   33.4712   34.5012])
% cbh = radial_display(RDL,v);
% sbchan_map


% Copyright (C) 2010 Brian M. Emery

% version 1.0  - 4March2010
%   updates 24Sept2010

% To do ...
% test ...? m_map compatible... add colormap stuff like cdot2d, varargin
% stuff ...%
% use lonlat2km or something more precise to convert range and bearing to
% km in circle subfunction (need to check this) (geodetic toolbox!)
% vectorize loop in radial cell? ... work with plotData?
%
%
% make radial_display.m, called by coverage map (HFRP tool) ... see
% cover_map_libe_row10.m

% Get range and bearing increments
rng     = mode(diff(RDL.RangeBearHead(:,1)));
dtheta  = diff(RDL.RangeBearHead(:,2));
brg     = mode(dtheta(dtheta > 0));

% % compute percent coverage
% p = 100 * sum( ~isnan(RDL.RadComp), 2 ) / size(RDL.RadComp,2);

% get patches
[x,y] = radialcell(RDL.RangeBearHead(:,1:2),RDL.SiteOrigin,rng,brg);

% plot
h = patch(x,y,v(:)');
set(h,'EdgeColor','none') %[.7 .7 .7]) %
cbh = colorbar;

end
%% ---------------------------------------------------------- 
function [x,y]=radialcell(position,site_loc,rng,brg)

% RADIALCELL.M
% radialcell(position,site_loc,cellwidthkm)
% Plots HF range/bearing cells with the lines on the plot defining
% the outsides of the range cells (ie, the center of the box is the
% range and angle quoted by codar), assumes 1.489km range cells, unless give
% input 'cellwidthkm', which is the range cell witdth in km.
% 'position' contains bearing and range information, and site_loc
% provides the remote site location
% From plot_rad_compare.m
%

% Customized local version
% Brian Emery 5 March 2010

x =[]; y=[];

for b=1:size(position,1)
    r=position(b,1);
    ang=position(b,2);
    [xx yy]   = subCircle(site_loc(1),site_loc(2),(r-(rng./2)),(ang-(brg/2)),(ang+(brg/2)));
    [xx2 yy2] = subCircle(site_loc(1),site_loc(2),(r+(rng./2)),(ang-(brg/2)),(ang+(brg/2)));
    
    % output box coords for each to enable patching    
    x = [x [xx([1 end]) xx2([end 1]) xx(1)]'];
    y = [y [yy([1 end]) yy2([end 1]) yy(1)]'];
    
end


end
%% ---------------------------------------------------------- 
function [x,y]= subCircle(lon,lat,r,amin,amax)
% CIRCLE.M
% [x,y]= circle(lon,lat,r,amin,amax);
% Plots a sector of a circle with radius r (in km), defined by
% the angles amax and amin (degrees where 0 deg = 
% east, 90 deg = north) centered on lat,lon (degrees). 
%
% For faint, thin lines, use 
% ln='''LineWidth'', 0.4,''Color'',[.85 .85 .85]';

% written by Libe Washburn aug 96 
% updates 29feb00 Brian Emery
% 
% Customized local version
% Brian Emery 5 March 2010

a=(amin:.1:amax)*pi/180.;

x = lon + r*cos(a)/(111*cos(lat*pi/180));
y = lat + r*sin(a)/111;


end