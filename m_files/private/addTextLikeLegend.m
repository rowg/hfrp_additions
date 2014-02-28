function legh=addTextLikeLegend(cellArray,opt)
% legh=addTextLikeLegend(cellArray)
% Tricks the legend function into adding text to the plot in a nice and
% neat way. Input is a cell array of strings.
%
% if opt=1, the text will be added to the top of the legend (rather than
% appending it to the end
%
% code at end to add or ?

% TO DO
% use the annotation function with all the right settings to accomplish
% this in a more precise manor ...

% Copyright (C) 2009-2010 Brian M. Emery

if nargin<2, opt=0; end

% get info if there is a pre-existing legend: (outm is cell)
[legh,objh,outh,outm] = legend;

a=axis; hold on
h=plot(a(1),a(3),'w.','MarkerSize',.01); % plot invisible dots, use handls

if opt
    inh=[h*ones(numel(cellArray),1); outh];
    inArray=[cellArray outm];
else
    inh=[outh; h*ones(numel(cellArray),1)];
    inArray=[outm cellArray];
end

legh=legend(inh,inArray{:});

end
%% -----------------------------------------------------------------------
function test_case

% more notes really ...

h = plot(1:10); legend(h,'stuff')
legh=addTextLikeLegend('details',1)

% SET THE LEGEND TITLE
% title is outside the box which could be good with box colored white?
t = get(legh,'Title')
set(t,'String','More Stuff')

set(legh,'EdgeColor','w')

end

%% -----------------------------------------------------------------------
function legh = legend_append(h,cel,opt)
% LEGEND APPEND - append to existing legend

% based on addTextLikeLegend
% 4Feb2010 Brian Emery

if nargin<3, opt=0; end

% get info if there is a pre-existing legend: (outm is cell)
[legh,objh,outh,outm] = legend;

if opt
    hh=[h(:); outh];
    inArray=[cel outm];
else
    hh=[outh; h(:)];
    inArray=[outm cel];
end

legh=legend(hh,inArray{:});


end