function GPS = gps_load_etrex(fname,s)
% GPS LOAD ETREX - load oddly formated ascii output from garmin etrex
% GPS = gps_load_etrex(fname)
%
% The input data file looks like this:
%
% @100625200437N3424587W11952901G005+00000E0000N0000U0000
% @100625200438N3424587W11952901G005+00000E0000N0000U0000
% @100625200439N3424587W11952901G005+00000E0000N0000U0000
%
% ... which is formatted:
% @YYMMDDHHMMSS Ndeg Min, W deg min,
%
% Though in practice it's a lot messier:
%
% @100625195524N3424560W11952873G004+00000W0007N0009U0001
% @100625195525N3424561W11952873G004+00000W0008N0008U0001
% ??N3424561W11952874G004+00000W0008N0009U000?@10062519?N3424562W11952874G004+00000W0007N0009U0001
% N3424562W11952875G005+00000W0007N0008U0001
% @1006251955290000W0007N0009U0001
% @100625195530?@100625195531N34245?08U0001
% @100625195532N3424·U0001
% @1006251955330001W0007N0009U0001
% @100625195534N3424565W11952878G005+?@100625195535N3424565W11952878G005+00001W0007N000¯@100625195536N3424566W11952879G005+00001W0006N0009U0001
% @100625195537N3424566W11952879G005+00001W0005N0010U0001
% @100625195538N3424567W11952880G005+00001W0007N0009U0001
% @100625195539N3424567W11952880G005+00001W0008N0009U0002
% @100625195540N3424568W11952881G005?@100625195541N3424568W11952881G005+00001W0008N0008U0002
% @100625195542N3424568W11952882G005+00001W0008N0008U0002
%
%
% EXAMPLE
% cd /Users/codar_restore/Desktop/
% fname = 'mgs100813';
% GPS = gps_load_etrex(fname);
%
% Optionally, include a second input to disable saving to an ascii file
% (saves min lat lon columns)

% TO DO
% combine all these gps loading functions into a one stop shopping
% experience.


% Subfunctions are somewhat generic and could be adopted to other tasks
% with minor tweaks

% Copyright (C) 2010 Brian Emery
% Version: 4Aug2010
%   from process_met_text_files.m which is a better
%   starting point for generic file readers. The use of regexprep with
%   tokens here is pretty sweet though.


% OPTIONS
if strcmp(fname,'--t')

    % run test of file reading
    test_case
    return

end


% READ/LOAD DATA USING SUBFUNCTION
% A is a Cell of strings, hdr contains the header
A = read_txt(fname,3);



% CONVERT TEXT

%    '100625195544'    '3424569'    '11952883'
% sbc
% plot(-119-(52.872/60), 34+(24.559/60),'r*')
GPS.TimeStamp = datenum(datevec(A(:,1),'yymmddHHMMSS'));


% Stuff between parans is captured in tokens (denoted with $1, $2, etch) and reused
latStr = regexprep(A(:,2), '(\d{2})(\d{2})(\d+)', '$1° $2.$3N');
lonStr = regexprep(A(:,3), '(\d{3})(\d{2})(\d+)', '-$1° $2.$3W');

% convert strings to numbers
GPS.Lat = lonlatstr2num(latStr);
GPS.Lon = lonlatstr2num(lonStr);


% SAVE AS CODAR FORMAT FILE
if nargin ==1

    [pathstr,fname,ext,vrsn] = fileparts(fname);
    gps2codar(GPS,fullfile(pathstr,fname))

end

% Make check plot
test_plot(GPS)



end



%% ---------------------------------------------------------------------
% FILE READING/DATA CONVERSION
function A = read_txt(fname,nCol)
% READ TXT - read oddly format text files
%
% from loadAISdata.m
% Custom part is the regexp which converts *, ** and ***, etc to NaN, and
% other stuff in FIX BAD TEXT section.
%
% NEED TO COLLECT THESE SOMEWHERE!

% Copyright 2010 Brian Emery
% Version 4aug2010: uses regexp and tokens, doenst use textscan


% Set the counter, verbosity
ct = 1;
vb = 0;

% PREALLOCATE SPACE
% max 1 day of data in seconds
A = cell(86400,nCol);

% field names of 'n'
fn = {'date','lat','lon'};


%[n.date,n.lat,n.lon] = deal(

% Open the file
fid = fopen(fname);
if fid < 0
    disp(['Error opening ' fname])
    keyboard,
else
    disp(['LOADING ' fname])
end


% LOAD DATA
% % get the header line
% hdr = textscan(fid,'%s',nCol);

% loop through file
while 1

    % get line
    tline = fgetl(fid);

    if ~ischar(tline)
        break

    elseif ~isempty(tline)


        % ACCEPT ONLY GOOD LINES
        % match the format @ -date- N -lat- W -lon- G -junk
        % and use token names (date, lat, lon) to capture the numbers
        % inbetween and keep them
        n = regexp(tline, '@(?<date>\d{12})[NS](?<lat>\d{7})[WE](?<lon>\d{8})G','names');

        if ~isempty(n) && sum(isfield(n,{'date','lat','lon'}))==3

            A{ct,1} = n.date;
            A{ct,2} = n.lat;
            A{ct,3} = n.lon;

            % increment counter only if we're here
            ct = ct+1;
        end

    end
end


fclose(fid);

% get rid of empties
A = A(1:ct-1,:);


end
%% ---------------------------------------------------------------------
function gps2codar(GPS,fname)
% GPS 2 CODAR - saves min lat lon data to file
%
% input structure GPS requires fields:
%     TimeStamp
%           Lat
%           Lon

% [Y,M,D,H,MI,S]=datevec(GPS.TimeStamp);
% 
% % Compute decimal minutes from midnight
% mins=(60.*H)+MI+(S./60);
% ... needs to wrap if we go past 0000GMT
mins = (GPS.TimeStamp - floor(GPS.TimeStamp(1))) *1440;

% form output
dat = [mins(:) GPS.Lat(:) GPS.Lon(:)];

save([fname '_min_lat_lon.txt'],'dat','-ascii','-double');
disp(['data saved in ' fname '_min_lat_lon.txt'])


return
plot(lon,lat,'.')
hold on
a=axis; sbchan_map
axis(a)

end


%% ---------------------------------------------------
function test_case
% TEST CASE - test code for process_met_data.m
%
% % get this by running at the command line:
% process_met_data(1)

% % This is just the first 11 lines of one of the files on disk
% test_file = '/Users/codar_restore/Desktop/cop100625a';

GPS = gps_load_etrex('gps_load_etrex.txt',0);


% should be near COP
test_plot(GPS)
axis([-119.9397 -119.7899   34.3471   34.4569])

keyboard

tline ={'@100625200931N3424648W11952950G005+00004W0005N0008D0001'; ...
    'ÇÇ?í?íÇÇ öí?N3424649W11952950G005+00004W0004N0008D0001'; ...
    '@100625200933@100625200934@100625200936N3424651W11952952G006+00004W0006N0007D?@100625200937N3424651W1195?@100625200938N3424652W11952953G006+00004W0006N0008D0001'};




end

%% ---------------------------------------------------
function test_plot(GPS)

plot(GPS.Lon,GPS.Lat,'r*')
a = axis;
sbc

axis(a)





end


