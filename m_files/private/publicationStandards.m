function publicationStandards(lbwh)
% PUBLICATION STANDARDS.M
% publicationStandards(lbwh)
% A comprehensive list of things to change 
% to make pub quality figs.
%
% Optionally input figure position (inches) 

% Copyright (C) 2000-2010 Brian Emery

% set(hfig,'DefaultAxesFontSize',14)
% set(hfig,'DefaultAxesLineWidth',1.5) 

% keep handle of current axes
htop = gca;

% Get all axes handles
haxes = findobj(get(gcf,'Children'),'type','axes'); 

% get rid of colorbars and legends
haxes = haxes(~strcmp('Colorbar',(get(haxes,'Tag'))));
haxes = haxes(~strcmp('legend',(get(haxes,'Tag'))));

% Loop over each axes and change settings
for j=1:length(haxes)
    
    % Removing this keeps all the layers in the right order
    % axes(haxes(j))
    
    set(    findobj('LineWidth',.5) ,'LineWidth',1.5)
    set(    findobj('FontSize',10)  ,'FontSize',14)
    set(    get(haxes(j),'XLabel')  ,'FontSize',14)   %,'FontWeight','bold')
    set(    get(haxes(j),'YLabel')  ,'FontSize',14)   %,'FontWeight','bold')
    set(    get(haxes(j),'title')   ,'FontSize',14)    %,'FontWeight','bold')
    set(    haxes(j)                ,'FontSize',14)
    set(    haxes(j)                ,'LineWidth',1.5)

end

if nargin < 1
    % these are kind of arbitrary, but easy to change
    lbwh = [0.5871    2.7218    9.8198    7.9919];
end

%set(gcf,'PaperOrientation','Portrait')
set(gcf,'Units','Inches')         
set(gcf,'Position',lbwh)
set(gcf,'PaperPosition',lbwh)

axes(htop)


end