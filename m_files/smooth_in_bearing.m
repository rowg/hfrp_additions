function Rs = smooth_in_bearing(R)
% SMOOTH IN BEARING - smooth radials in bearing
%
% INPUT
% R, standard radial structure, temporally concatenated
%
% OUTPUT
% Rs, R with radials smoothed in bearing (defaults to 15 deg)

% Copyright (C) 2010 Brian M. Emery
% June 21st 2010


%% -------------------------------------------
%  DEFINITIONS  
% --------------------------------------------

% get other matrix variable fields
omv = fieldnames(R.OtherMatrixVars);

% Define fields to average
fn = cat(1,{'RadComp';'Error'},omv);

% Set moving average widow half width in degrees
wd = 7.5; 


%% -------------------------------------------
%  GET OUTPUTS  
% --------------------------------------------

% un-pack other matrix variables
R = substruct_unpack(R,'OtherMatrixVars');

% create outputs
Rs = R;

% Meta
Rs.ProcessingSteps{end+1} = 'smooth_in_bearing';


% Blank value that will be filled
for i = 1:numel(fn)
   Rs.(fn{i}) = Rs.(fn{i})*NaN;
end
    


%% -------------------------------------------
%  COMPUTE MEANS  
% --------------------------------------------

for r = 1:size(R.RangeBearHead,1)

    % FIND ROWS
    % find rows to average together
    rows = find(R.RangeBearHead(:,1) == R.RangeBearHead(r,1) & ...
                R.RangeBearHead(:,2) <= R.RangeBearHead(r,2) + wd & ...
                R.RangeBearHead(:,2) >= R.RangeBearHead(r,2) - wd );

    % special cases near 0 and 360
    if (R.RangeBearHead(r,2) + wd) > 360
        rows = [rows; find(R.RangeBearHead(:,2) <= (R.RangeBearHead(r,2) + wd) - 360)];

    elseif (R.RangeBearHead(r,2) - wd) < 0
        rows = [rows; find(R.RangeBearHead(:,2) >= (R.RangeBearHead(r,2) - wd) - 360)];       
    end
    
    
    % COMPUTE MEAN
    for i = 1:numel(fn)
       [Rs.(fn{i})(r,:),Rs.RadCount(r,:)] = nanmean(R.(fn{i})(rows,:),1); 
       
       %if length(rows) == 3, keyboard, end
       
    end
        
end


%% -------------------------------------------
%  FINALIZE 
% --------------------------------------------

% Require at least 2 radials in the mean
for i = 1:numel(fn)
   Rs.(fn{i})(Rs.RadCount <=1) = NaN;
end

% re - pack other matrix variables
Rs = substruct_pack(Rs,'OtherMatrixVars',omv);

end



