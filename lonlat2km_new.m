function [x,y] = lonlat2km(lon_o,lat_o,lon,lat) 
% LONLAT2KM - Km East and North relative to origin using Vincenty's
% [east, north] = lonlat2km(lon_origin,lat_origin,lon,lat)
%
% INPUT
% decimal lon, lat of origin (scalar)
% decimal lon, lat (vectors)
% 
% OUTPUT
% km east and north of origin
% 
% Basically an attempt to reproduce the output of Codar's total gridding
% program. Difference with theirs is ~25 cm over 30 km (mostly in x 
% direction) at high latitudes (~60 N in test case).
%
% uses the M_Map tools m_idist.m and m_fdist.m, which use the WGS84 earth
% model and Vincenty's algorithm.
%
% See also test_km2lonlat_method, km2lonlat.m, lonlatstr2num.m

% Copyright (C) 2010 Brian M. Emery
% Version 2.0, 1 Oct 2010: Vectorized

% Optional test case
if strcmp(lon_o,'--t')
    test_case, [x,y] = deal(NaN); return
end

% remove nan's and reshape lon lat
[lon,lat,r,c,i] = reform_inputs(lon,lat);

% Expand origin input into matrix 
lon_o = lon_o.*ones(size(lat));
lat_o = lat_o.*ones(size(lat));


% X POSITIONS
% The origin longitude acts as y ordinate (similar to cos's).
x = m_idist(lon_o,lat,lon,lat);

% special case for x == 0
x(lon == lon_o) = 0;


% Y POSITIONS
% define the x direction bearings
brg = NaN.*lon;
brg(lon < lon_o) = 270;
brg(lon > lon_o) =  90;

% compute lon lat of due east/west intermediate point
[lon2,lat2] = m_fdist(lon_o,lat_o,brg,x);

% deal with lon == lon_o case. For all input points along the origin
% longitude, the y dist is from the origin lat along the origin long
lon2(lon == lon_o) = lon_o(lon == lon_o); 
lat2(lon == lon_o) = lat_o(lon == lon_o);

% find the y distances
[y,a12,a21] = m_idist(lon2,lat2,lon,lat);


% y at Origin set to zero
y(lon == lon_o & lat == lat_o) = 0;


% DETAILS
% Convert to km
x = x./1000;
y = y./1000;

% Make west, south negative
x(lon < lon_o) = -x(lon < lon_o);
y(lat < lat_o) = -y(lat < lat_o);

% % Force Y < 1 m to zero (this makes the grid test look good, but can be a
% % problem for converting drifter data
% ii = find(abs(y) < 0.001); if ~isempty(ii), keyboard, end
% y(abs(y) < 0.001) = 0;

% reinsert nan and reshape output
[x,y] = reform_outputs(x,y,r,c,i);

end
%% ----------------------------------------------------------------
function [x,y,r,c,i] = reform_inputs(x,y)
% REFORMAT INPUTS
% reshape to columns, remove nans

% reshape to columns, keep r,c
[r,c] = size(x+y);
x = x(:);
y = y(:);

% remove nans, reinsert them in the output
i = ~isnan(x+y);
x = x(i);
y = y(i);

end
%% ----------------------------------------------------------------
function [ln,lt] = reform_outputs(lon,lat,r,c,i)
% REFORM OUTPUTS

% % Potential matlab bug where this sometimes generates zeros
% % reinsert Nan's
% lon(~i) = NaN;
% lat(~i) = NaN;

% work around:
[ln,lt] = deal(NaN(r*c,1));
ln(i) = lon;
lt(i) = lat;

% reshape outputs
ln = reshape(ln,r,c);
lt = reshape(lt,r,c);

end

%% --------------------------------------------------------------------
function test_case
% TEST CASE for the development of this lonlat2km version
%
% Compute XY in km given lon lats of a grid, and compare this with the XY
% from Codar's gridding program
%
% Based on testing, it appears that the remaining difference with the COS
% grid are due to differences in the distance calculation method (COS is
% not Vincenty's?) rather than any difference in how the distance calc
% methods are used.

% LonLat_grid uses m_map tools to construct a grid. This results in a grid
% that is very similar to eg a grid found in Codar's total files. An
% example can be found here:
load /projects/drifter_simulation/pws/data/totals/tot_pws.mat

% the above contains lon lats from the Prince William Sound, which provides a pretty
% robust test, and XY from the Codar total vector gridding program.


% the origin is here:
ii = find(TUV.OtherSpatialVars.X ==0 & TUV.OtherSpatialVars.Y ==0);

[x,y] = lonlat2km(TUV.LonLat(ii,1),TUV.LonLat(ii,2),TUV.LonLat(:,1),TUV.LonLat(:,2));

% check plot
plot(x,y,'r.')
hold on
plot(TUV.OtherSpatialVars.X,TUV.OtherSpatialVars.Y,'bo')

% plot the differences
figure
cdot2d(x,y,sqrt((TUV.OtherSpatialVars.X-x).^2 + (TUV.OtherSpatialVars.Y-y).^2).*1000)
title('COS vs lonlat2km\_dev total differences in Meters')

% plot the differences
figure
cdot2d(x,y,sqrt((TUV.OtherSpatialVars.X-x).^2 ).*1000)
title('COS vs lonlat2km\_dev X differences in Meters')

% plot the differences
figure
cdot2d(x,y,sqrt((TUV.OtherSpatialVars.Y-y).^2).*1000)
title('COS vs lonlat2km\_dev Y differences in Meters')

keyboard

end