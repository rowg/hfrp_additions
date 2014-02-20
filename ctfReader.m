function DAT=ctfReader(file)
% CTFREADER.M - Read Codar Table Format files (CTF) into a structure
%  DAT = ctfReader(file);
%
% Uses column names given in header field 'TableColumnTypes' as the
% field names in the structure. Works on multiple files at a time 
% (putting them into an indexed structure). Mimics some of the fields
% in a typical HFR_Progs stucture.
%
% See also ctfWriter.m, load_pattern_file.m, loadRDLFile.m


% Copyright (C) 2007-2010 Brian Emery 
% Version 1.0, 25jun07
%         2.0  30jun08 with some borrowing from getRDLHeader.m
%         2.1  11Oct10 Clean up and details for compatibility with new
%                      ctfWriter.m. Now outputs footer.

% To do:
% - read addtional tables (using TableStart)

DAT=struct();

if iscell(file)
    file=char(file);
end

% loop over file names
for i=1:size(file,1)
    
    % get some info from the file name
    NM = cosFileNameParts(file(i,:));      

    % Add standard fields to top of structure
    DAT(i).Type = NM.Type;
    DAT(i).SiteName = NM.SiteName;
    DAT(i).TimeStamp = datestr(NM.TimeStamp);
    DAT(i).CreateTimeStamp = datestr(now);
    DAT(i).FileName = file(i,:);
    
    
    % READ DATA
    dat = textread(file(i,:),'%[^\n]',-1);
    
    % Get the header and footer
    % find text fields
    isTxt = strncmp('%',dat,1);  
    idx   = [1:numel(dat)]'; 
    
    % Find footer if it exists
    ft = strmatch('%TableEnd:',dat);
    if isempty(ft), ft = numel(dat); end
    
    % Apply indexing 
    DAT(i).Header = dat(isTxt & idx < ft);
    DAT(i).Footer = dat(isTxt & idx >= ft);
    
    
    % David's code to get variable key words 'names' and 'values' from header
    [DAT(i).HdrNames,DAT(i).HdrValues] = get_names_values(DAT(i).Header);

% keyboard
% 
%     % detect significant digits ... relies on use of space
%     s = isspace(char(dat(~isTxt)));
%     mode(double(~s))
% 
    % PUT DATA IN STRUCTURE
        
    % Put remaining data into a matrix
    % this is slow but robust
    dat = str2num(char(dat(~isTxt))); 
    
    % Use field names from 'TableColumnTypes'. Note that it may occur more than
    % once, which is the case with radial files.
    % example of val = 'BEAR A13R A13I A23R A23I FLAG A13M A13P A23M A23P'
    [ix,nm,val]=getNameValuePair('TableColumnTypes',DAT(i).HdrNames,DAT(i).HdrValues);
    fn = cellstr(strparser(val{1}));
    
    for ii = 1:numel(fn)
        % Catch error, put in empty field and if data not found
        eval('DAT(i).(fn{ii}) = dat(:,ii);','DAT(i).fn{ii} = [];')
        
    end

    % Add meta info to bottom of struct
    DAT(i).ProcessingSteps = {mfilename};
    
end



end
%% --------------------------------------------------------------------
function [names,values] = get_names_values(hdr)
% GET NAMES VALUES - get name and value pairs from CTF format header
%
% EXAMPLE
% Some name, value pairs:
% %ReceiverLocation:  34.4078333 -119.8783333
% %RangeCells: 88
% %DopplerCells: 32
% %DopplerUpdateRate: 4
%
% 
% From David Kaplans code to get variable 'names' and 'values' from header
% Next split lines if desired.
%
% from getNameValuePair.m

[names, values] = deal(cell(length(hdr),1));
 
for k = 1:length(hdr)
    % This way is considerably more efficient than using strtok
    ii = min( [ find( hdr{k} == ':' ), length(hdr{k})+1 ] );
    names{k,1} = strtrim(hdr{k}(2:ii-1)); % Remove initial %
    values{k,1} = strtrim(hdr{k}(ii+1:end)); % Removie initial :
    
end

end


