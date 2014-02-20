function [lon,lat,time,hdr]=gps_load(fname)

% GPS_LOAD.M
% [lon,lat,time,hdr]=gps_load(fname)
% Reads garmin gps *.trk data files. Must
% have this format (11 header lines):
% 
% H  SOFTWARE NAME & VERSION
% I  PCX5 2.09
%
% H  R DATUM                IDX DA            DF            DX            DY            DZ
% M  G WGS 84               121 +0.000000e+00 +0.000000e+00 +0.000000e+00 +0.000000e+00 +0.000000e+00
%
% H  COORDINATE SYSTEM
% U  LAT LON DM
%
% H  LATITUDE    LONGITUDE    DATE      TIME     ALT    ;track
% T  N3426.91998 W12004.56095 29-APR-03 17:28:09 00035 
% ...

% Brian Emery 2may03

fid=fopen(fname,'r');
if fid==-1, disp('unable to open file - check file name?'), return , end

% get the header %%%%%%%% Change the '11' to the # of header lines if changes ...
hdr=cell(11,1);
for i=1:11
   line=fgetl(fid);
   hdr{i,1}=line;
end

% read the data 
lon=[]; lat=[]; time=[];
while 1
   % read a line of text into tmp
   tmp = fgetl(fid);
   	if ~isstr(tmp), break;, end
   % seperate out each segment of data 
   tokens=strparser(tmp);  
   time=[time; datenum([tokens(4,:) tokens(5,:)]);];
   
   % for lat,lon, find the decimal point's index and work backwards
   ilat=strmatch('.',tokens(2,:)');
   lat=[lat; str2num(tokens(2,2:ilat-3))+(str2num(tokens(2,ilat-2:end)))./60;];
   
   % if longitude is west, make it negative
   ilon=strmatch('.',tokens(3,:)');
       if tokens(3,1)=='W',
           lon=[lon; -str2num(tokens(3,2:ilon-3))-(str2num(tokens(3,ilon-2:end)))./60;];
       elseif  tokens(3,1)=='E',
           lon=[lon; str2num(tokens(3,2:ilon-3))+(str2num(tokens(3,ilon-2:end)))./60;];
       else
           disp('longitude format not recognized ...')
       end

end

fclose(fid);
fclose('all');
return

%   % Save the data in a big matrix block
%   position=[position; words(1)+(words(2)./60) -words(3)-(words(4)./60);];
%   secs=[secs; ((3600*words(5))+(60*words(6))+words(7)) ];

 