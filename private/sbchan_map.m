function H = sbchan_map(cstr,cstr2,stime)
% SBCHAN_MAP.M - Map of So Cal with bathymetry
% sbchan_map 
% Plots a map of the Santa Barbara Channel and so Cal bight with
% positions of scripps moorings. The default is a blue coastline,
% however any line style can be passed as an input arguement, such
% as:
% 	 sbchan_map('k.')
%
% for a black coast line. Add 'nobathy' to the function
% call to remove bathymetry data.
%
% Add a serial date as the last argument in the
% function call to plot the temporally correct mooring
% locations. For example, this will plot all of the
% moorings:
% sbchan_map(datenum(1998,05,21,0,0,00))
%
%
% EXAMPLE USAGE
% gets the layering right and lable positions right
% figure
% axis([-120.3751 -119.0017   33.4712   34.5012])
% cbh = radial_display(RDL,v);
% sbchan_map
%
%
% NOTE
% the order stuff happens is important:
% 1) set axes
% 2) Bathymetry
% 3) Labels (first font size, then position proportional to the axes settings)
% 
% BIGHT WIDE AXES: axis([-120.7754 -118.1109   33.1030   34.6309])



% Copyright (C) 1999-2010 Brian M. Emery
% improved 18Feb99, 2 Dec 2009

% TO DO:
% plot everything, simply, keep all handles in an output
%   structure (H.Bathy.d100 for example?), modify accordingly
% mmap switchable
% publication standards
% switch bathy labels, land labels, cities, islands, on and off ... maybe 
%   make a LABS input structure with this info?
%
% edit codar_range_map
% edit plotBasemap
% edit sbchan_map.m
% edit landColor.m
% edit sbc_mmap.m

% NOTES:
% HFRP:
% plotBasemap([-122 -116],[31 36.5],'/Data/Mapping/COAST4_123_31.mat','lambert');
% see: codar_range_map.m
% Make it a program which uses tools such as plotBaseMap. I dont think it
% needs to strictly be a tool, more like a shortcut.
%
% ALL the handles should be listed in a structure and outputted
%
% See: sccoos_gap_analysis.m - all things added to plot would have
% to use m_plot, etc in order to work, so make sure it's clear how to use
% m_map!
% ALSO SEE: sbc_mmap.m
%

%% ----------------------------------------------------------------------
% DEFAULT SETTINGS
% ---------------------------------------------------------------------
% coastline color
ccolor = 'k';
cls = 2; % line width

% Axes and labels font size (from pub standards)
fontsize = 14;

%% ----------------------------------------------------------------------
% SORT INPUTS
% ---------------------------------------------------------------------

% when toggle is 1, bathymetry is plotted
toggle=1;

% case 1, defalt to blue line, bathy, no extra moorings
if nargin==0
    cstr=ccolor; stime=now;

    % one input argument,
elseif nargin==1
    if strcmp(cstr,'nobathy')
        cstr=ccolor; toggle=0; stime=now;
    elseif ~isstr(cstr)
        stime=cstr; cstr=ccolor;
    else isstr(cstr)
        stime=now;
    end

    % case 3, 2 input argumetns.
elseif nargin==2
    if strcmp(cstr2,'nobathy')
        toggle=0; stime=now;
    elseif ~isstr(cstr2) % this is the date as 2nd arguments case
        toggle=1; stime=cstr2;
    elseif strcmp(cstr,'nobathy')
        toggle=0; stime=now;
    end

    %
elseif nargin==3
    toggle=0;
end


%% ----------------------------------------------------------------------
% PLOTTING AND LABELLING
% ----------------------------------------------------------------------

% AXES
% if existing axes are present, use them. Otherwise, define axis
a=axis;
if a==[0 1 0 1]
    % axis([-121.5000 -119.0000   33.5000   35.5000]);
    axis([-121.5 -118.1744   33.0633   35.5]);
end
hold on


% -------------------
% COASTLINE 
% TURN OFF coastline for zoomed out plots, to leave out a lot of detail

% load /Data/Mapping/sbcoast.mat
% plot(sbcoast_lon2,sbcoast_lat2,cstr,'LineWidth',cls);
% 
% % South of Oxnard
% load('/Data/Mapping/coast.dat')
% plot(coast,coast,cstr,'LineWidth',cls); 
% 
% % Gets past mex border
% load('/Data/Mapping/coast2.dat')
% plot(coast2(:,1),coast2(:,2),cstr,'LineWidth',1.5); 

% load /Data/Mapping/COAST4_124_29.mat
% plot(ncst(:,1),ncst(:,2),cstr,'LineWidth',cls)

% -------------------
% ANCILLARY DATA AND LABELS
% Add SIO Moorings based on deployment times
plt=0; % switch for sio mooring plotting
if plt
    plot_moorings(stime);
end 

% Labelling plot switch (1 on, 0 off)
labs=1;
if labs
    
    % BATHYMETRY
    if toggle~=0
        sbchan_bathy;
    end
    
    % -------------------
    % LAND PATCHES
    land_color([.75 .75 .75]);


    % HF SITES
    H.sites = add_codar_sites(stime,fontsize);

    % PLATFORM LOCATIONS
    % Add platform locations with labels
    platform_loc(0); % set input to 1 to get platform names,0 otherwise
    
    % LAND MARKS and AXES
    add_labels(fontsize);
    % hpl=draw_placenames(14);
    
%     % SHIPPING LANES
%     shipping_lanes

end 

% -------------------
% SCALING
% Get mercator scaling factor the area and scale the map and area
% (thanks to Mike Cook)
limits = axis;
[ax,sc]=mercat(limits(1:2),limits(3:4));
set(gca, 'DataAspectRatio', [1,sc,1],'PlotBoxAspectRatio',[1,1/ax,1]);

% -------------------
% AXES, LABELS FIXED
publicationStandards

% Axes on top 
set(gca,'box','on','Layer','top')


% --------------------------------------
end



%% -----------------------------------------------------------------------
% LOCAL FUNCTIONS
%
function land_color(rgb)
% LAND COLOR.M
% landColor(rgb)
% Colors the land in sbchan_map.m plot
% Input rgb is either 'r' or [1 1 1] type inputs

% 10Oct03 Brian Emery


% OLDER CODE SUITABLE FOR CHANNEL ONLY PLOTS

load /Data/Mapping/patchIslands.mat
% MainLand
hm=patch(mainLon2,mainLat2,rgb);%,.0010*ones(size(mainLat)),rgb); 
% return
% hm=patch(mainLon,mainLat,-.0010*ones(size(mainLat)),rgb);

% Islands
h1=patch(anaLon,anaLat,rgb);%,.0010*ones(size(anaLat)),rgb);
h2=patch(scruzLon,scruzLat,rgb);%,.0010*ones(size(scruzLat)),rgb);
h3=patch(smigLon,smigLat,rgb);%,.0010*ones(size(smigLat)),rgb);
h4=patch(srosLon,srosLat,rgb);%,.0010*ones(size(srosLat)),rgb);
set([h1 h2 h3 h4 hm],'Clipping','on','FaceAlpha',1) %,'LineStyle','none')


% CODE BASED ON MMAP DATA
% Get other islands from mmap data
load /Data/Mapping/COAST4_124_29.mat

% use only a selection of k's (gives indecies of islands (patches))

h = cell(length(k)-1,1);

for i = [4 6 12 17]; %1:numel(k)-1
    h{i} = patch(ncst(k(i)+1:k(i+1)-2,1),ncst(k(i)+1:k(i+1)-2,2),rgb);
    set([h{i}],'Clipping','on','FaceAlpha',1)
end


return

% HOW TO GET PATCH DATA
% from mmap data base
load /Data/Mapping/COAST4_124_29.mat

ncst = ncst(k(1):k(2),:);

n = find(ncst(:,1) > -122 &  ncst(:,1) <-117 & ncst(:,2) < 37 & ncst(:,2) > 32);

ncst = [ncst(n,:); -117 37];

mainLat2 = ncst(:,2);
mainLon2 = ncst(:,1);

save /Data/Mapping/patchIslands.mat mainLon2 mainLat2 -append

% Useful 
for i = 1:20, plot(ncst(k(i)+1:k(i+1),1),ncst(k(i)+1:k(i+1),2),'-r.'), hold on, title(num2str(i)), pause, end
 

end
%% -----------------------------------------------------------------------
function plot_moorings(stime)

sio_loc;
st='ko';
% plot long term sio moorings
plot(smin_loc(1),smin_loc(2),st)
plot(sami_loc(1),sami_loc(2),st)
plot(smof_loc(1),smof_loc(2),st)
plot(anmi_loc(1),anmi_loc(2),st)

% plot if the dates are correct (these dates are rounded off)
if stime>datenum(1996,03,01) && stime<datenum(1999,11,15)

    plot(arin_loc(1),arin_loc(2),st)
    plot(armi_loc(1),armi_loc(2),st)
    plot(arof_loc(1),arof_loc(2),st)
    plot(abmi_loc(1),abmi_loc(2),st)
    plot(abof_loc(1),abof_loc(2),st)
    plot(sain_loc(1),sain_loc(2),st)
    plot(saof_loc(1),saof_loc(2),st)

end
clear ar*_loc ab*_loc sa*_loc sm*_loc

% UCSB MOORING ??
% plot UCSB mooring location if the date is correct
if stime>datenum(1998,05,20,0,0,00) && stime<datenum(2000,05,05,00,48,59)
    s4lon=-119.9096; s4lat=34.2501;
    % s4lon=-119.9084; s4lat=34.2501;
    % OLD POSTION: s4lon=-119.9134; s4lat=34.2554;
    plot(s4lon,s4lat,'ko')
    % text((s4lon+.02), s4lat,'ucsb M')
end

end
%% -----------------------------------------------------------------------
function publicationStandards(lbwh)
% PUBLICATION STANDARDS.M
% publicationStandards(lbwh)
% A comprehensive list of things to change 
% to make pub quality figs.
%
% Optionally input figure position (inches) 

% Copyright (C) 2000-2010 Brian Emery

% set(hfig,'DefaultAxesFontSize',14)
% set(hfig,'DefaultAxesLineWidth',1.5) 

% keep handle of current axes
htop = gca;

% Get all axes handles
haxes = findobj(get(gcf,'Children'),'type','axes'); 

% get rid of colorbars and legends
haxes = haxes(~strcmp('Colorbar',(get(haxes,'Tag'))));
haxes = haxes(~strcmp('legend',(get(haxes,'Tag'))));


% Loop over each axes and change settings
for j=1:length(haxes)
    
    % Removing this keeps all the layers in the right order
    % axes(haxes(j))
    
    % set(    findobj('LineWidth',.5) ,'LineWidth',1.5) % <-- only difference with publicationStandards.m
    set(    findobj('FontSize',10)  ,'FontSize',14)
    set(    get(haxes(j),'XLabel')  ,'FontSize',14)   %,'FontWeight','bold')
    set(    get(haxes(j),'YLabel')  ,'FontSize',14)   %,'FontWeight','bold')
    set(    get(haxes(j),'title')   ,'FontSize',14)    %,'FontWeight','bold')
    set(    haxes(j)                ,'FontSize',14)
    set(    haxes(j)                ,'LineWidth',1.5)

end

if nargin < 1
    % these are kind of arbitrary, but easy to change
    lbwh = [0.5871    2.7218    9.8198    7.9919];
end

set(gcf,'PaperOrientation','Portrait')
set(gcf,'Units','Inches')         
set(gcf,'Position',lbwh)
set(gcf,'PaperPosition',lbwh)

axes(htop)


end



%% -----------------------------------------------------------------------
% SITES AND SITE LABELS
function H = add_codar_sites(stime,fontsize)
% ADD CODAR SITES

H = struct([]);

% set plotting params:
LS.Color = 'k';
LS.Marker = '^';
LS.MarkerSize = 9;
LS.MarkerFaceColor = 'y';
LS.Clipping = 'on';

% sm='k^';
% mfc='y';
% mSize=9; % MarkerSize (default is 6)
fontsize = 9;

% Create a structure of site info
INFO = get_site_info;

% plot existing sites:
loc=codar_sites;
sites={'cop','rfg','ssd','mgs','ptm','sci','sni','fbk','ptc','arg'};

for i=1:numel(sites)
    
    % plot location and info if the date is correct
    if stime > INFO.(sites{i}).stime

        % SITE MARKERS
        H(1).(sites{i}) = plot(loc.(sites{i})(1),loc.(sites{i})(2),LS);
%         set(h,'Clipping','on','MarkerFaceColor',mfc,'MarkerEdgeColor','k', ...
%             'MarkerSize',mSize);

        % SITE LABELS
        %         place_text(loc.(sites{i})(1) + INFO.(sites{i}).x , loc.(sites{i})(2) + INFO.(sites{i}).y, ...
        %             INFO.(sites{i}).str,'fontsize',fontsize)
        H.text.(sites{i}) = place_text(loc.(sites{i})(1), loc.(sites{i})(2),upper(sites{i}), ... '
            'fontsize',fontsize,'fontweight','bold'); % INFO.(sites{i}).str

    end
end

% % CUSTOM CODE FOR SSD
% if stime>datenum(2005,3,1,0,0,00)
%     h=text((loc.ssd(1)+.02),(loc.ssd(2))+.03,'Summerland Sanitary','fontsize',fntsz); set(h,'Clipping','on')
%     h=text((loc.ssd(1)+.06),(loc.ssd(2)),'District','fontsize',fntsz); set(h,'Clipping','on')
% end

end
%% -----------------------------------------------------------------------
function INFO = get_site_info
% GET SITE INFO
% Create a structure of site info containing plotting particulars
INFO(1).cop.stime = datenum(1997,06,13,0,0,00);
INFO.cop.x = 0;
INFO.cop.y = .03;
INFO.cop.str = 'Coal Oil Pt.';

INFO.rfg.stime = datenum(1997,12,9,0,0,00);
INFO.rfg.x = 0;
INFO.rfg.y = .02;
INFO.rfg.str = 'Refugio St. Beach';

INFO.ptc.stime = [datenum(1997,08,25,0,0,00) ]; %datenum(2002,11,13)];
INFO.ptc.x = 0;
INFO.ptc.y = .04;
INFO.ptc.str = 'Pt. Conception';

INFO.arg.stime = [datenum(1998,11,10,0,0,00)  datenum(2002,11,20)];
INFO.arg.x = .02;
INFO.arg.y = 0;
INFO.arg.str = 'Pt. Arguello';

INFO.fbk.stime = datenum(1998,11,17,0,0,00);
INFO.fbk.x = .02;
INFO.fbk.y = 0;
INFO.fbk.str = 'Fallback 22';

INFO.mgs.stime = datenum(2003,3,20,0,0,00);
INFO.mgs.x = 0;
INFO.mgs.y = .02;
INFO.mgs.str = 'Mandalay \newlineGenerating \newlineStation';

INFO.ssd.stime = [datenum(2004,5,1,0,0,00)  datenum(2004,9,1)];
INFO.ssd.x = .02;
INFO.ssd.y = 0;
INFO.ssd.str = 'Summerland \newlineSanitary Dist.';

INFO.sci.stime = [datenum(2007,9,18,0,0,00)  datenum(2008,4,14)];
INFO.sci.x = .02;
INFO.sci.y = 0;
INFO.sci.str = 'SCI';

INFO.ptm.stime = datenum(2008,6,18,0,0,00); % <-probably not the date of earliest data
INFO.ptm.x = .02;
INFO.ptm.y = 0;
INFO.ptm.str = 'Point Mugu';

INFO.sni.stime = datenum(2008,12,17,0,0,00);
INFO.sni.x = .02;
INFO.sni.y = 0;
INFO.sni.str = 'San Nicolas Island';

end
%% -----------------------------------------------------------------------
function add_labels(fontsize)

% % label the islands
% scruz=[-119.8545   34.02];
% h=text(scruz(1),scruz(2),'Santa Cruz Isl.','fontsize',8); set(h,'Clipping','on');
% srosa=[-120.2029   34.04];
% h=text(srosa(1),srosa(2),'Santa Rosa Isl.','fontsize',8); set(h,'Clipping','on');
% smig=[-120.4559   34.09];
% h=text(smig(1),smig(2),'San Miguel Isl.','fontsize',8); set(h,'Clipping','on');


%equal_axis
xlabel('longitude');
ylabel('latitude');
hold on



end
%% -------------------------------------------------------------------- %%
function  ht = place_text(lon,lat,str,varargin)
% PLACE TEXT
% add the site names with the offset from the site (or island) scaled by
% the axes so that it looks good no matter the size of the plot

% define the percent offsets that look good:
x = 0.0130;
y = 0.016;
m = 1;

% Get delta lon, lat
a = axis;
dlon = a(2) - a(1);
dlat = a(4) - a(3);

% convert offset %'s to lon lat [INSERT SITE MULTIPLIER HERE]
olon = x * dlon;
olat = y * dlat;

% HACK for SCI
if strcmp(str,'SCI')
    m = -1;
end

ht=text(lon+olon,lat+olat*m,str,varargin{:});
set(ht,'Clipping','on');

% ADD A LINE from name to site location
% pos = get(ht,'position');
% plot([lon pos(1)],[lat pos(2)],'-k')


end



%% -----------------------------------------------------------------------
function remove_gaps_in_coastline_file

% this is how the coastline file was modified to remove gaps
[r,bf,br]=dist(sbcoast_lat,sbcoast_lon);
sbcoast_lon2=[];
sbcoast_lat2=[];
for i=1:length(r)
    sbcoast_lon2=[sbcoast_lon2 sbcoast_lon(i)];
    sbcoast_lat2=[sbcoast_lat2 sbcoast_lat(i)];

    if r(i)>1200
        sbcoast_lon2=[sbcoast_lon2 NaN];
        sbcoast_lat2=[sbcoast_lat2 NaN];
    end

    if i==length(r)
        sbcoast_lon2=[sbcoast_lon2 sbcoast_lon(i+1)];
        sbcoast_lat2=[sbcoast_lat2 sbcoast_lat(i+1)];
    end
end


% this removes some nans near avila
i=find(sbcoast_lat2>34.9706 & sbcoast_lat2<35.1323 &  ...
    sbcoast_lon2>-120.6515  & sbcoast_lon2<-120.6276);
sbcoast_lat3=[sbcoast_lat2(1:(i(1)-1)) sbcoast_lat2(i) ...
    sbcoast_lat2(i(length(i))+1:length(sbcoast_lat2))];
sbcoast_lon3=[sbcoast_lon2(1:(i(1)-1)) sbcoast_lon2(i) ...
    sbcoast_lon2(i(length(i))+1:length(sbcoast_lon2))];
sbcoast_lat2=sbcoast_lat3; clear sbcoast_lat3
sbcoast_lon2=sbcoast_lon3; clear sbcoast_lon3

end
%% -----------------------------------------------------------------------
function shipping_lanes
% SHIPPING LANES - plots the shipping lanes in the Santa Barbara Channel

% Libe Washburn, from charts

st='-m';
x(1)=-120.500167; y(1)=34.364167;
x(2)=-119.255   ; y(2)=34.08;
x(3)=-119.175   ; y(3)=34.04167;
plot(x,y,st)

x(1)=-120.5067; y(1)=34.3483;
x(2)=-119.2683; y(2)=34.0665;
x(3)=-119.175 ; y(3)=34.02167;
plot(x,y,st)

x(1)=-120.5167; y(1)=34.315;
x(2)=-119.2967; y(2)=34.0375;
x(3)= -119.175; y(3)=33.98;
plot(x,y,st)

x(1)=-120.524167; y(1)=34.3;
x(2)=-119.3067; y(2)=34.0225;
x(3)= -119.175; y(3)=33.9583;
plot(x,y,st)

end
%% -------------------------------------------------------------------- %%
function hpl=draw_placenames(fontsize)
% DRAW_PLACENAMES 

%------------------------------
if nargin<1
    fontsize = 7;
end

sites(1).name = 'Santa Cruz.';
sites(1).abbv = 'SCI';
sites(1).lat = 34.01;
sites(1).lon = -119.76;

sites(end+1).name = 'Santa Rosa';
sites(end).abbv = 'SRI';
sites(end).lat = 33.96;
sites(end).lon = -120.11;

sites(end+1).name = 'San Miguel';
sites(end).abbv = 'SMI';
sites(end).lat = 34.03;
sites(end).lon = -120.37;

sites(end+1).name = 'San Nicolas';
sites(end).abbv = 'SNI';
sites(end).lat = 33.2370;
sites(end).lon = -119.4953;

sites(end+1).name = 'Santa Barbara Isl.';
sites(end).abbv = 'SBI';
sites(end).lat = 33.4698;
sites(end).lon = -119.0287;

sites(end+1).name = 'Santa Catalina';
sites(end).abbv = 'Catalina';
sites(end).lat = 33.3686;
sites(end).lon = -118.4209;

for i = 1:length(sites)
    hpl(i) = text(sites(i).lon,sites(i).lat,sites(i).name);
    set(hpl(i),'fontsize',fontsize,'Clipping','on','HorizontalAlignment', ...
        'Center','VerticalAlignment','Top','fontweight','bold');
end
 
end
%% -------------------------------------------------------------------- %%
function notes_overlapping_text

% NOTES ON AUTOMATING LABELING WITHOUT OVERLAP
% see:
% text property extent:
% 
% IDEA:
% set the labels, check if the text boxes overlap, if they do, move them
% somehow, then recheck until they dont ...
% 
% Extent
%     
% position rectangle (read only)
% 
% Position and size of text. A four-element read-only vector that defines 
% the size and position of the text string
% [left,bottom,width,height]
% 
% 
% 
% If the Units property is set to data (the default), left and bottom are
% the x- and y-coordinates of the lower left corner of the text Extent. 
% 
% For all other values of Units, left and bottom are the distance from the 
% lower left corner of the axes position rectangle to the lower left corner
% of the text Extent. width and height are the dimensions of the Extent
% rectangle. All measurements are in units specified by the Units property
% 
% see:
% help rectint
%  RECTINT Rectangle intersection area.
%     AREA = RECTINT(A,B) returns the area of intersection of the
%     rectangles specified by position vectors A and B.  
%  
%     If A and B each specify one rectangle, the output AREA is a scalar.
%  
%     A and B can also be matrices, where each row is a position vector.
%     AREA is then a matrix giving the intersection of all rectangles
%     specified by A with all the rectangles specified by B.  That is, if A
%     is M-by-4 and B is N-by-4, then AREA is an M-by-N matrix where
%     AREA(P,Q) is the intersection area of the rectangles specified by the
%     Pth row of A and the Qth row of B.
%  
%     Note:  A position vector is a four-element vector [X,Y,WIDTH,HEIGHT],
%     where the point defined by X and Y specifies one corner of the
%     rectangle, and WIDTH and HEIGHT define the size in units along the x-
%     and y-axes respectively.
%  
%     Class support for inputs A,B: 
%        float: double, single
% 
%     Reference page in Help browser
%        doc rectint

% then need code to place the re-place the lables when the do overlap

end
