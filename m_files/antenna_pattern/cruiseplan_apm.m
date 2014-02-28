function cruisplan_APM
% CRUISEPLAN.M
% Plots a map of the SB Channel, prompts for
% waypoint inputs via the mouse, outputs the
% final cruise track, the lat/lons, and the time
% assuming 6 knot cruising speed

% Calls sbchan_map.m, dist.m, mercat.m
% sbchan_map.m Calls: codar_sites.m, sio_loc.m, 
% e:\data\sbcoast.mat, mercat.m
% e:\data\bathymetry\sbcsmb_quick.mat,


% Brian Emery 6feb01

% Define the cruising speed in knots
spd=9;

% plot the channel
sbchan_map
soCalBight_map
axis([-122.4532 -116.9656   32.4580   35.6048])
hold on

% size the figure
set(gcf,'PaperOrientation','Portrait')
set(gcf,'Units','Inches')         
set(gcf,'Position',[1 .5 7.5 6.5])
%This sets the x,y,width, and height of the plot on the paper (in inches..)
set(gcf,'PaperPosition',[0.25,0.25,7.5,6.5])


% prompt for waypoints, plot the track as you go
Lon=[];Lat=[];
lab=['A';'B';'C';'D';'E';'F';'G';'H';'I';'J';'K';'L';'M';'N';'O';'P';];
n=input('How many waypoints?');
for i=1:n
   [lon,lat]=ginput(1);
   text(lon,lat,num2str(i))
   Lon=[Lon lon]; Lat=[Lat lat];
   if i~=1
      plot([Lon(i-1) lon],[Lat(i-1) lat],'k')
      text([(Lon(i-1)+lon)/2],[(Lat(i-1)+lat)/2],lab(i-1))
   end
end

% compute the distances in km
[dm,af,ar]=dist(Lat,Lon); 
dkm=dm/1000;  clear af ar dm i lat lon

% convert distances to times
spdkmph=spd*(111/60);
legtimes=dkm/spdkmph;

% output to screen
disp('Waypoints:')
disp('No. Lon 	Lat')
for j=1:n
   disp([num2str(j) ' ' num2str(Lon(j)) ' ' num2str(Lat(j))])
end

disp('Transects:')
disp('Leg Dist(km) Time(hrs)')
for k=1:n-1
   disp([lab(k) ' ' num2str(dkm(k)) ' ' num2str(legtimes(k))])
end


