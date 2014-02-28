function RDL = temporalConcatRadials_exact(RADIAL,vars)
% TEMPORAL CONCAT RADIALS EXACT.M - like HFRP, with actual radial locations
% RDL = temporalConcatRadials_exact(RADIAL);
%
% Takes multi-element RADIAL structures, such as output from loadRDLFile,
% and concatenates them into HFRP compatible position-time matricies.
%
% Differs from temporalConcatRadials.m in that the unique ranges and
% bearings are used to specify each row of the output position matrix.
% Small differences in position will end up as additional rows. Radial
% matrix variables stored in OtherMatrixVars substructure are also
% concatenated.
%
% This function is also generalized such that the elements of RADIAL may
% contain matricies indexing columnwise in time, for concatenating multiple 
% outputs of temporalConcatRadials.m, for example. The input structure is
% only required to have the following fields:
%
% {'RangeBearHead','TimeStamp','LonLat'}
%
% Thus, the function can operate on radially binned drifter data (from 
% bin_drifters_like_radials.m and for examples). In this case a second
% input naming the fields to operate on is required (see example below).
% 
%
% EXAMPLE:
%
% % Load data into radial struct:
% cd /Data/projects/pws_comparison/radials/5deg/KNOW
% flist = dir([pwd '/RDL*']);
% RADIAL = loadRDLFile({flist.name});
%
% % Use this function:
% RADIAL = temporalConcatRadials_exact(RADIAL)
%
% % And on a radially binned drifter component structure:
% flds = {'RadComp','N','Stdev',','Median'};
% DRFT = temporalConcatRadials_exact(DRFT,flds);

% 01Apr98 Brian Emery
% reWrit 5mar04  
% v6 for ctf files jun07
% v6.1 usable for multiple directories
% 24 Feb '10, renamed, improved HFRP compatibilty
% 10 Mar '10, expanded capabilities 

% TO DO
% full hfrp meta data (other matrix vars, etc), spatial temporal errors ...
% test case? 
% - deal with multi-site inputs (oops)

%% ---------------------------------------------------------- 
%  CHECK INPUTS
% ----------------------------------------------------------- 
OMV = 0;

% define required fields
qf = {'RangeBearHead','TimeStamp','LonLat'};

% check input structure
field_check(RADIAL,qf)

% set default fields (in typical RADIAL structure)
if nargin < 2
    vars = RADIALmatvars; %{'RadComp','Error','Flag','U','V'};
end


% check for presence of data in OtherMatrixVars
if isfield(RADIAL,'OtherMatrixVars') && ~isempty([RADIAL.OtherMatrixVars])
   
    OMV = true;
    
    % get field names 
    ov = fieldnames([RADIAL.OtherMatrixVars]);
    
    % add OtherMatrixVars to qf so meta_concat skips it
    qf = cat(2,qf,'OtherMatrixVars');
    
end

% QAD catch multi-site Radial structs (fix later)
if length(unique({RADIAL.SiteCode})) > 1, keyboard, end


%% ---------------------------------------------------------- 
%  INITIALIZE OUTPUT STRUCT
% ----------------------------------------------------------- 
% based on the input. This allows generalized use with similarly formated
% data (e.g. drifters, etc)

% RDL =  RADIALstruct(1);
flds = fieldnames(RADIAL(1));
for i = 1:numel(flds)
    RDL(1).(flds{i}) = [];
end

% CREATE MATRIX OF UNIQUE RANGES AND BEARINGS
rbh = cat(1,RADIAL.RangeBearHead);
rng = unique(rbh(:,1));
brg = unique(rbh(:,2)); clear rbh

dim=(length(rng)*length(brg));
[b,r]=meshgrid(brg,rng);
RDL.RangeBearHead = [reshape(r,dim,1) reshape(b,dim,1) NaN(dim,1)]; clear brg rng b r


% CREATE THE OUTPUT TIME ARRAY
% Get time array
t = sort([RADIAL.TimeStamp]);

% Compute time step, round to nearest min (?)
dt = round(mode(diff(t))*1440)/1440;

% Warn if odd timestep 
if ~ismember(dt,[10/1440 1/24 3/24])
    disp(['Unusual time step in ' mfilename ': ' num2str(dt*24) ' hrs'])
end

% Create output time array
RDL.TimeStamp = min(t):dt:max(t);



% Create empty data matricies
for i = 1:numel(vars)
    RDL.(vars{i}) = NaN(dim,numel(RDL.TimeStamp));
end
RDL.LonLat = NaN(dim,2);

% Create emptys if OtherMatrixVars
if OMV
    for i = 1:numel(ov)
        RDL.OtherMatrixVars.(ov{i}) = NaN(dim,numel(RDL.TimeStamp));
    end
end


%% ---------------------------------------------------------- 
%  CONCATENATION  
% ----------------------------------------------------------- 
% put radial data into position/time matricies

% loop through struct arrays and paste data in 
for j=1:numel(RADIAL) ;
    
        % spatial intersect
        [c,iRDL,iRad]=intersect(RDL.RangeBearHead(:,1:2),RADIAL(j).RangeBearHead(:,1:2),'rows');

        % temporal intersect
        [c,tRDL,tRad]=intersect(RDL.TimeStamp,RADIAL(j).TimeStamp);%(t));
        
        % loop over fields
        for i = 1:numel(vars)
            RDL.(vars{i})(iRDL,tRDL) = RADIAL(j).(vars{i})(iRad,tRad);
        end

        % keep LonLat
        RDL.LonLat(iRDL,:) = RADIAL(j).LonLat(iRad,:);
        
        % deal with OtherMatrixVars
        if OMV && ~isempty(RADIAL(j).OtherMatrixVars)
            for i = 1:numel(ov)
                RDL.OtherMatrixVars.(ov{i})(iRDL,tRDL) = ...
                    RADIAL(j).OtherMatrixVars.(ov{i})(iRad,tRad);
            end
        end

        
end

%% ---------------------------------------------------------- 
%  KEEP META DATA  
% ----------------------------------------------------------- 

% STANDARD FIELDS
% try to concatenate, cell or string array:
sf = {'Type','SiteName','SiteOrigin','ProcessingSteps','FileName'};
RDL = meta_concat(RDL,RADIAL,sf);


% NON-STANDARD FIELDS
% find the non-standard fields which haven't already been used   
rf = setdiff(flds,cat(2,vars,sf,qf));
RDL = meta_concat(RDL,RADIAL,rf);


% append procesing info
RDL.ProcessingSteps{end+1} = mfilename;


end

%% ---------------------------------------------------------- 
function RDL = meta_concat(RDL,RADIAL,sf)
% META CONCAT
% get unique meta data from fields in RADIAL and place into RDL

for i = 1:numel(sf)
    if isfield(RADIAL,sf{i})
        try
            % This works on char and cell arrays
            RDL.(sf{i}) = unique(cat(1,RADIAL.(sf{i})),'rows');
        catch
            % this should get the FileName fields if the above doesn't
            RDL.(sf{i}) = ({RADIAL.(sf{i})});
        end
    end
end
end