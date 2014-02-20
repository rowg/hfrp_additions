function write_pattern_file(APM,wkdir)
% WRITE PATTERN FILE - create MeasPattern.txt from APM struct
% write_pattern_file(APM,wkdir)
%
% Create MeasPattern.txt file from standard APM structure
%
% see also: apm_struct, load_pattern_file

% Copyright (C) 2009-2010 Brian M. Emery
% verion 23 May 2010

% TO DO
% test number of bytes written
% catch errors

% NOTES
% MeasPattern.txt file:
% Bearings CCW from Header loop1 bearing (CWN)
% Contents:
%
% Bearings in the files are CCW relative to loop1 bearing, which SeaSonde
% software gets from the Header.txt file.
%
% Loop1to3 real
% Loop1to3 real std dev of measurments (quality factor)
% Loop1to3 imaginary
% Loop1to3 imaginary quality factor
%
% Loop2to3 real
% Loop2to3 real std dev of measurments (quality factor)
% Loop2to3 imaginary
% Loop2to3 imaginary quality factor
% 
% 
% blocks of .txt are DEG CCW relative to loop1 bearing
%
% SEASONDE 10 PATTERN FILE FORMATS:
% These files are text based and require a linefeed character (ASCII 10)
% as an end-of-line indicator. The SeaSonde10 processing software will not
% be able to correctly read the file if it the end-of-line is some other
% character(s) like a return or return/linefeed combination.
% 
% The pattern bearings are CCW (counter-clockwise) degrees referenced from the
% antenna bearing. The antenna bearing is found in Header.txt and is (CW) clockwise
% degrees from true North. See the File_RadialSetups guide.
% 
% The Quality factor is a standard deviation of the measurements that went into the
% pattern value. The Quality factor is currently not used by the processing software.

%% -----------------------------------------------------------------------
%  SETUP
%-------------------------------------------------------------------------

if strcmp(APM,'--t')
   test_case, return 
end

% Optional 2nd input
if nargin < 2, wkdir = pwd; end

% Compute bearing to write
APM.rel_bear = cwN2ccwE(APM.BEAR) - cwN2ccwE(APM.loop1Brg);

% Make sure bearings are in interval [-180 180]
APM.rel_bear(APM.rel_bear <= -180) = APM.rel_bear(APM.rel_bear <= -180) +360;
APM.rel_bear(APM.rel_bear >   180) = APM.rel_bear(APM.rel_bear >   180) -360;


% Define file name
fname = fullfile(wkdir,'MeasPattern.txt');


%% -----------------------------------------------------------------------
%  WRITE FILE
%-------------------------------------------------------------------------

% Open for writing
fid = fopen(fname,'w');

% line1: number of bearings CCW relative to loop 1 (APM has CWN 
ct = fprintf(fid,'%3.0f\n',length(APM.BEAR));


% Write bearings (using subfunction)
c = write_fields(fid,APM,{'rel_bear'},'%12.1f'); 
ct = ct + c;

% define other fields of APM
vars = {'A13R','A13RQ','A13I','A13IQ', ...
        'A23R','A23RQ','A23I','A23IQ'};
        
% Write other fields (using subfunction)
c = write_fields(fid,APM,vars,'%12.7f'); 
ct = ct + c;

% Write the footer
for i = 1:numel(APM.Footer.Orig)
    c = fprintf(fid,'%s\n',APM.Footer.Orig{i}); ct = ct + c;
end

% close file
ss = fclose(fid);


% if success (need a test ...)
disp(['Wrote ' fname])


end

%% ------------------------------------------------------------------------
function ct = write_fields(fid,APM,vars,fmt)
% WRITE FIELDS
% write apm files with max number of columns, and generalized
% format string

% Define number of data points
N = length(APM.(vars{1})); ct = 0;

% define where to put linefeeds
lf = 7:7:N;
    
% write loop data
for i = 1:numel(vars)
    
    % write 7 columns then \n, or \n at end of data
    for j = 1:N
        
        if ismember(j,lf) || j == N
            % put in line feed character
            c = fprintf(fid,[fmt '\n'],APM.(vars{i})(j)); 
        else
            % just write the field
            c = fprintf(fid,  fmt ,APM.(vars{i})(j)); 
        end
        
        % increment byte count
        ct = ct +c;
        
    end
end
end

%% ------------------------------------------------------------------------
function test_case

% load a MeasPattern.txt file
file = '/Volumes/codar/SOO/Data_SCI/RadialConfigs/MeasPattern.txt';
APM = load_pattern_file(file);

% now write it and try to get the same thing
write_pattern_file(APM,'/Users/codar_restore/Desktop/')


end