function S = subsref_struct(S,i,n,rc)
% SUBSREF STRUCT - apply indexing to fields in a structure
% S = subsref_struct(S,i,n,rc)
%
% Applies the indexing given in i, of the fields in S that have the 
% matching number of columns (n). Given a 4th input will apply the
% indexing to the rows (1). Defaults to columns (rc = 2). Cell arrays
% are now included.
%
% Recurses into substructures looking for fields of the same size to apply
% the indexing to as well. 
%
% Example:
% % Create a structure with mixed fields, array and structure
% d.lon = ones(5,1)*[1:10]; 
% d.lat = ones(5,1)*[1:10]; 
% d.time = 1:10;
% d.strct = d; 
% 
% % Change the column indexing
% d = subsref_struct(d,2:5,size(d,2),2)
% 
% % Change the row indexing
% d = subsref_struct(d,1:2,size(d,1),1)
%
% See also: work_fields

% Copyright (C) Brian M. Emery
% Brian Emery 12 Jan 2010
% from subsrefTUV.m

% TO DO
% - maybe a special case when indexing applies to whole matrix ...?
% - should apply to cells also
% - recursion?

if strcmp(S,'--t'), test_case, return, end

if nargin < 4 
    rc = 2;  
end

if rc == 2;
    k = i; i = ':';
elseif rc == 1 
    k =':';
% elseif rc == 0
%     [i,k] = ind2sub(size(),i); % <----
else
    disp('un-understood option'), keyboard
end

nm = fieldnames(S);

for j = 1:numel(nm)
    if  isnumeric(S.(nm{j})) && size(S.(nm{j}),rc) == n  % isnumeric(S.(nm{j})) | iscell?
        S.(nm{j}) = S.(nm{j})(i,k);
        
    elseif isstruct(S.(nm{j}))
        
        % Try to recurse into sub structures
        try
            S.(nm{j}) = subsref_struct(S.(nm{j}),i,n,rc);
        catch
        end
        
    end
end


% Optionally add documentation
if isfield(S,'ProcessingSteps')
    S.ProcessingSteps{end+1} = mfilename;
end


end
%%  ------------------------
function test_case

% Example:
% Create a structure with mixed fields, array and structure
d.lon = ones(7,1)*(1:10); 
d.lat = ones(7,1)*(1:10); 
d.time = 1:10;
d.strct = d; 
d.ProcessingSteps = {'blahblah'};

disp(' Change the column indexing')
f = subsref_struct(d,2:5,10,2)

disp(' Change the column indexing')
f = subsref_struct(d,2:5,10)

disp(' Change the row indexing')
f = subsref_struct(d,1:2,7,1)

keyboard

end

%% ----------------------------------------------------------
% Additionally ...
function B = subsref_local(B,r,c,flds)
% SUBSREF LOCAL - local version of subscript reference
% Add this as a subfunction to clean up all the loops over fields. This
% applies the indexing in r, c to all fields listed in flds cell.
%
% at 181:
% % RDL = subsref_local(RDL,cat(2,sflds,flds),r,c);
%
% Note r or c can be ':' for all rows or columns.

if nargin < 4
    flds = fieldnames(B);
end

for i = 1:numel(flds)
    B.(flds{i}) = B.(flds{i})(r,c);
end

end

