function TUV=cos_totals_to_hfrp(fnames)
% COS TOTALS TO HFRP - convert TOTL files to TUV structures
% TUV=cos_totals_to_hfrp(fnames)
%
% Convert codar TOTL files, in codar table format, to HFR_Progs compatible 
% TUV structures
%
% INPUT:
% fnames, a cell array list of file names (can include the directory)
%
% OUTPUT:
% TUV structure containing U,V matrices (rows = grid points, columns = times)

% Brian Emery 30 Oct 2009
% needs to output contiguous times ...

%% --------------------------------------------------------- 
% LOAD DATA
% --------------------------------------------------------- 


% Load the files into a generic stucture
DAT=ctfReader(fnames);


%% --------------------------------------------------------- 
%   CREATE/LOAD UP TUV STRUCTURE
%---------------------------------------------------------- 
% create the TUV structure and pre-allocate space. Get all the time and
% grid information.

% First need number of unique grid locations
grd=[];
for i = 1:numel(DAT)
    grd=unique([grd; DAT(i).lond DAT(i).latd],'rows');
end

% Get empty structure
TUV = TUVstruct([size(grd,1) numel(DAT)]);

% Deal with meta info
TUV.DomainName = DAT(1).SiteName;
TUV.CreationInfo = 'cos_totals_to_hfrp.m';

% LonLat grid
TUV.LonLat=grd; 

% Get fields for other matrix variables
flds = fieldnames(DAT);

% Exclude normal fields from list
xcld = {'SiteName','lond','latd','TimeStamp','velu','velv', ...
        'uqal','vqal','cqal','ProcessingSteps','FileName', ...
        'Hdr','HdrNames','HdrValues','Type','xdst','ydst'};
flds = setdiff(flds,xcld);

% Preallocate these fields
for i = 1:numel(flds)
    TUV.OtherMatrixVars.(flds{i}) = NaN(size(grd,1),numel(DAT));
end

% Preallocate x,y km 
TUV.OtherSpatialVars.X = NaN(size(TUV.LonLat(:,1)));
TUV.OtherSpatialVars.Y = NaN(size(TUV.LonLat(:,1)));
TUV.OtherSpatialVars.XUnits = 'km';
TUV.OtherSpatialVars.YUnits = 'km';


clear grd

% Place data in the TUV structure
for i = 1:numel(DAT)
    
    % TimeStamp
    TUV.TimeStamp(i)=DAT(i).TimeStamp;
    
    % get matching grid locations
    [c,iDAT,iTUV]=intersect([DAT(i).lond DAT(i).latd],TUV.LonLat,'rows');

    % put the velocities in the right places
    TUV.U(iTUV,i)=DAT(i).velu(iDAT) ;
    TUV.V(iTUV,i)=DAT(i).velv(iDAT) ;
    
    % put the 'quality' stuff in the error matrix
    TUV.ErrorEstimates.Uerr(iTUV,i)=DAT(i).uqal(iDAT) ;
    TUV.ErrorEstimates.Verr(iTUV,i)=DAT(i).vqal(iDAT) ;
    TUV.ErrorEstimates.UVCovariance(iTUV,i)=DAT(i).cqal(iDAT);
    
    % special treatment of x,ydst
    TUV.OtherSpatialVars.X(iTUV) = DAT(i).xdst(iDAT);
    TUV.OtherSpatialVars.Y(iTUV) = DAT(i).ydst(iDAT);
    
    % include the other fields
    for j = 1:numel(flds)
        TUV.OtherMatrixVars.(flds{j})(iTUV,i) = DAT(i).(flds{j})(iDAT);
    end
    
end

% Units on codar's quality are probably cm/s (standard deviations)
TUV.ErrorEstimates.UerrUnits = 'cm/s';
TUV.ErrorEstimates.VerrUnits = 'cm/s';
TUV.ProcessingSteps = {'cos_totals_to_hfrp.m'};

% Concat cell data
flds = {'FileName','Hdr','HdrNames','HdrValues','Type'};
for i = 1:numel(flds)
    TUV.OtherMetadata.(flds{i}) = {DAT.(flds{i})};
end


end