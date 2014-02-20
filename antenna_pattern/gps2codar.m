function gps2codar(fname)
% GPS2CODAR.M
% gps2codar(gpsfname)
% Converts ususal, run of the mill gps data
% to the format requested by CODAR:
% decimal minutes from midnight lat/long in fractional degrees.
%              1801   44.689817  124.074533

% Derived from e:\data\antenna_patterns\fbk\gps2codar.m
% Brian Emery 6july01
% Version 6 compatible 21dec01
% Major improvements 2May03, 24mar05

% load in the gps data
[lon,lat,time,hdr]=gps_load(fname);

% convert the time
[Y,M,D,H,MI,S]=datevec(time);
%secs=(3600.*H)+(60.*MI)+S;
mins=(60.*H)+MI+(S./60);

% form output
%dat=[secs lat lon];
dat=[mins lat lon];

%keyboard

save([fname(1:end-4) '.txt'],'dat','-ascii');
disp(['data saved in codar''s format as ' pwd '\' fname(1:end-4) '.txt'] )

% check plots
plot(lon,lat,'.')
hold on
a=axis; sbchan_map
axis(a)
title(['Boat track in ' fname ])

return

% OSX FORMAT:
% min lat lon
[Y,M,D,H,MI,S]=datevec(time);
mins=(60.*H)+MI+(S./60);
dat=[mins lat lon];
save([fname(1:end-4) '.txt'],'dat','-ascii','-double');
disp(['data saved in codar''s format as ' pwd '\' fname(1:end-4) '.txt'] )

% Lat lon m/d/y h:m:s
%blnk=char(ones(size(lat))*double(' '));
%dat=[num2str(lat) blnk num2str(lon) blnk datestr(time,23) blnk datestr(time,13)];
%save([fname(1:end-4) '.txt'],'dat','-ascii');


return

% plotting code for the output files
plot(lon,lat,'g.')
hold on
a=axis; sbchan_map, axis(a)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CODE for editing noisy gps data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
gridd=mgs01(:,3:-1:2);
ind=[];
n=gridnum(gridd); ind=[ind n];
keep=setxor(1:length(mgs01),ind);
dat=mgs01(keep,:);
save(['C:\DATA\Antenna_Patterns\mgs\mgs01.txt'],'dat','-ascii');
% and check again ...
callstart
load C:\DATA\Antenna_Patterns\mgs\mgs01.txt
plot(mgs01(:,3),mgs01(:,2),'co')