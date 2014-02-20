function ll = lonlatstr2num(str)
% LONLATSTR2NUM - convert lon lat strings to decimal lon lat
% ll = lonlatstr2num(str)
%
% INPUTS
% cell or character arrays, eg:
% str = {'123°30''00"S', ...
%        '00° 27'' N', ...
%        '33° 41.67'' E'};
%
% Fields must be in deg, min, sec order even if there are no seconds
%
% OUTPUTS
% decimal degrees, negative west longitude
% 
% EXAMPLE
% ll = lonlatstr2num({'119°30.6705''W','33°16.818''N',}); 
%
% produces:
% ll = 
%   -119.5112
%     33.2803
%
% Run the optional test case to check function:
% lonlatstr2num('--t')

% TO DO
% Needs some checking for char inputs for example

% Copyright (C) 2010 Brian M. Emery
% inspired by str2angle which doesn't seem to work 

if strcmp(str,'--t')
    test_case, ll = []; return
end

% this works on cell and string arrays
s = regexprep(str,{'°','''','"','[A-Z]','-'},' ');


% Define a number container
N = zeros(numel(s),3);

for i = 1:numel(s), 
    
    % scan
    n = textscan(s{i},'%n');
    
    % fill N with numbers
    N(i,1:length(n{:})) = n{:};
        
end

% convert to decimal
ll = N(:,1) + N(:,2)/60 + N(:,3)/3600;



% CONVERT WEST AND SOUTH TO NEGATIVE

% convert to char
cstr = char(str);


% find W's and S's
k = regexp(cstr(:)',{'W','S'});

if ~isempty(k)
    [r,c] = ind2sub(size(cstr),[k{:}]);
    ll(r) = -ll(r);
end

end
%% ---------------------------------------------------------------------
function test_case
%        % future cases:
%            '123°30''S', ...
%            '123-30-00S', ...
%            '123d30m00sS' , ...

% CASE 1
sni=[-119.511175 33.2803];
ll = lonlatstr2num({'119°30.6705''W','33°16.818''N',});

if isequal(sni,ll(:)')
    disp('CASE 1 PASSED')
else
    disp('test failed'), keyboard
end

% CASE 2
strings = {'123°30''00"W', ...
           '00° 27'' N', ...
           '120° 27'' W', ...
           '33° 41.67'' S'};

ll = lonlatstr2num(strings);

% 


keyboard
    

end

