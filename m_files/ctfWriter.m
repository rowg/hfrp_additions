function ctfWriter(S,fname)
% CTF WRITER - Write codar table format file from a structure
% 
% Requires the fields HdrNames and HdrValues, which must contain 
% 'TableColumnTypes'. These key words are used to identify fields to write
% to the file as data columns.
% 
% EXAMPLE
% % Read a loop file in
% DAT=ctfReader('LOOP_cop1_100818_192848.loop');
% 
% % Exclude low signal level points by setting flag
% DAT.FLAG(DAT.AR3D > -60) = 1;
% 
% % Re-write the loop file
% ctfWriter(DAT,'LOOP_cop1_100818_a.loop')
%
% 
% test/dev case:
% ctfWriter('--t')

% Copyright (C) 2010 Brian M. Emery

% Version 1.0, 11Oct2010

% TO DO
% - Needs more generalization, since it was basically written for loop files
% (which had been loaded with ctfReader.m, modified and re-written), so
% this assumes a lot obout what fields are present.
%
% - Needs a good default precision, and precisions for lon lat fields (this
% could cause problems).
%
% - Needs to make assumptions about which fields to write as data if
% TableColumnTypes is not found
%
% - make sure this follows Codar's standards:
% 1. The first line should be ?%CTF: 1.0?. 
% 2. The second line should typically (must be in the first ten lines) be the ?%FileType: <type> 
% <subtype>?, where <type> is a unique four character identifier of the file. The <subtype> is a four 
% character, which identifies variations in the file. A reader that recognizes the <type> should be 
% able to understand most of the content regardless of the <subtype>. 
% 3. The first table should contain row data that starts with a space. The following tables may 
% optionally start row data with ?% ? (percent space) to keep the main table compatible with Matlab 
% read. 
% 4. Tables must be preceded by ?%TableType: <type> <subtype>? so that the reader know what the 
% table is. It should also be preceded by %TableColumns: %TableRows: and %TableColumnTypes: 
% so that the reader knows what to expect. 
% 7. The last line should be a ?%End:?. While not strictly required, this marks that the file was 
% successfully written and that the software did not break in the middle or some other unforeseen 
% catastrophe. 
% 8. When creating new keywords, be verbose. This file format is about clarity not compactness.


if strcmp(S,'--t'), test_case, return, end

% Add processing info
S.ProcessingSteps{end+1} = mfilename;

% Open for writing
fid = fopen(fname,'w');



% HEADER
% Recreate header if necessary
if ~isfield(S,'Header') & isfield(S,{'HdrNames','HdrValues'})
    for i = 1:numel(S.HdrNames)
%        c = fprintf(fid,'%s\n',['%' S.HdrNames{i} ': ' S.HdrValues{i}]);
        S.Header{i} = ['%' S.HdrNames{i} ': ' S.HdrValues{i}];
    end

end

% Write header 
write_text(fid,S,'Header')



% DATA COLUMNS
% get the field names to use
% Use field names from 'TableColumnTypes'. May occur more than once
[ix,nm,val]=getNameValuePair('TableColumnTypes',S.HdrNames,S.HdrValues);
fn = cellstr(strparser(val{1}));

% write data columns
struct_write(S,fn,fid)



% FOOTER
% Re- write the last few elements of the footer. TableEnd will be the first
% line if the Footer field resulted from a ctfReader.m call.
S.ProcessingSteps = strcat(S.ProcessingSteps,'.m,');
S.Footer{end-2} = ['%ProcessedTimeStamp: ' datestr(now,'yyyy mm dd HH MM SS')];
S.Footer{end-1} = ['%ProcessingTool: ' [S.ProcessingSteps{:}]];
S.Footer{end  } = ['%End:'];

% Write Footer to file
write_text(fid,S,'Footer')

st = fclose(fid); if st<0, keyboard, end


end
%% ------------------------------------------------------------------------
function write_text(fid,S,fn)
% WRITE TEXT - write header and footer strings

if isfield(S,fn)
    for i = 1:numel(S.(fn))
        c = fprintf(fid,'%s\n',S.(fn){i});
    end
end

end
%% ------------------------------------------------------------------------
function struct_write(S,fn,fid)
% STRUCT WRITE - write struct contents in file
% 
% converts the fields to columns (must be same size?)

% Copyright (C) 2010 Brian M. Emery

% check input sizes
z =[];
for i = 1:numel(fn)
    z = [z length(S.(fn{i}))];
end
if length(unique(z)) ~= 1, keyboard, end
     
% Get prestored precision formats
P = get_precisions;

% get loop size
r = size(S.(fn{1}),1);



% concat field data into matrix M
M = NaN(r,numel(fn));
for i = 1:numel(fn)
    M(:,i) = S.(fn{i});
end

% create format string
for i = 1:numel(fn)
    try
        fmt{i} = P.(fn{i});
    catch
        fmt{i} = '%8.4f';
    end
end



for i=1:r
  fprintf(fid,[fmt{:} '\n'],M(i,:)); 
end



end
%% ------------------------------------------------------------------------
function P = get_precisions
% GET PRECISION
% a database of precision strings to use for specific fields

% digits to use: left, right of zero
% tedious ... is there any other way?

% 6.1
[P.A13P,P.A23P,P.AR3D,P.AR3P,P.A1SN,P.A2SN,P.A3SN,P.A3NF] = deal('%7.1f');

% 8.1
[P.TRGB, P.TRGD] = deal('%8.1f');

% 1.4
[P.A13M, P.A23M] = deal('%8.4f');

% 1.3
P.TRGV = '%8.3f';
       
% 5.0
[P.PKRC, P.PKDC, P.LP1B, P.FLAG ] = deal('%8.0f');

% 8.0 
P.DATE = '%9.0f';

% 6.0
[P.TIME, P.DAVE  ] = deal('%7.0f');

% 6.3
[P.CP1R, P.CP1D, P.CP2R, P.CP2D, P.CP3R, P.CP3D ] = deal('%9.3f');

% 13.0
P.MCDT  = '%14.0f';
end
%% ------------------------------------------------------------------------
function test_case


S = ctfReader('/Data/testData/ctfWriter/LOOP_cop1_100818_192848.loop');

ctfWriter(S,'/Data/testData/ctfWriter/LOOP_test.loop')

% multi-table case
%'/Data/testData/RDLm_CLHB_2007_11_01_1000.ruv'

% add this to mfile to test header recreation
%S = rmfield(S,'Header')

end