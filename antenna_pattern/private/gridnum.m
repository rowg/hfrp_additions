function n=gridnum(gridd)
% GRIDNUM.M
% n=gridnum(gridd)
% Click on a grid point and get its index number . Designed
% to be used with CODAR tot_*.mat files.
%
% Useful code:
% sbchan_map
% hold on
% [gridd]=sbgrid2(2);
% plot(gridd(:,1),gridd(:,2),'.')
% sbchan_map(datenum(1998,05,21,0,0,00))
% codar_axis
% n=gridnum(gridd);
% 
% From codar_zoom.m, requires codar_sites.m, lonlat2km.m and the variable 'gridd'

% 24Mar98 Brian Emery
% ... due for improvements (see below) June 2009

disp('click on a gridpoint with the mouse')
[x,y]=ginput(1);

 %  Define the locations of the radar sites, and the central lat/lon
 %  to convert all the radial files and total grid data to.

 % define central location of the gridd
 central_loc = [x y];                                  

 %  Convert all data/total gridpoints to EAST/NORTH rel. to origin.
 % 1st col: longitude, 2nd col: latitude
  [gridEast,gridNorth] = lonlat2km(central_loc(1), central_loc(2), ...
                                 gridd(:,1), gridd(:,2));

 % convert x, y to km east and north
 [xyEast,xyNorth] = lonlat2km(central_loc(1), central_loc(2), x, y);
 
 % find the nearest grid point
    %%%%%%
    % compute the distance between all the grid points and xy 
    east_dist  = gridEast-xyEast; 
    north_dist = gridNorth-xyNorth; 

    % dist from xy to a gridpoint.
    dist = sqrt(east_dist .^2 + north_dist .^2);
  
    % Keep only the nearest grid pt. (i is the index of the grid pt.)
    [val,i] = min(dist);        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% plot the output to make sure it is correct
 hold on                     
 plot(gridd(i,1),gridd(i,2),'ro')
n=i;
disp(['grid point index is ' num2str(i)])

clear ans arg_loc central_loc cop_loc dist east_dist f22_loc gridEast gridN  
clear i north_dist ptc_loc rfg_loc x xyEast xyNorth y  fbk_loc gridNorth

end
%% -----------------------------------------------------------------------
function idx=getNearestGrid(x,y,Lon,Lat)
% GET NEAREST GRID
% idx=getNearestGrid(x,y,Lon,Lat)
% given a lat lon and a grid Lat Lon, finds the index of the grid point
% nearest the lat lon

% from gridnum.m
% Brian Emery

keyboard

%  Convert all data/total gridpoints to EAST/NORTH rel. to origin.
% 1st col: longitude, 2nd col: latitude
[gridEast,gridNorth] = lonlat2km(x,y,Lon,Lat);

% dist from xy to a gridpoint.
distKm = sqrt(gridEast .^2 + gridNorth .^2);
  
minDist=min(min(distKm)); disp(['Nearest Point is ' num2str(minDist) 'km away'])

idx=find(distKm==minDist);


end
