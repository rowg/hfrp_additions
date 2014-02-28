function [ax,p] = cdot2d(x,y,cval,dotsize,MapColor,crange)

%CDOT2D  Draws a 2-D pseudocolor plot w/data represented as points.
%
%  CDOT2D(X,Y,CVAL) creates a 2-D plot with the elements of vector CVAL
%  represented as pseudocolored dots plotted at location X, Y.
%  The values of the elements of CVAL are mapped to one of Matlab's
%  pseudocolor tables.  A colorbar is also plotted.
% 
%  NOTE:  X, Y, and CVAL must all be row or column vectors of the same
%  length!  Matrices will not work properly.
%
%  You MUST supply the first 3 arguments, the following 4 are
%  optional and if not supplied will be set to default values.
%
%  CDOT2D(X,Y,CVAL,DOTSIZE) will plot the CVAL data as dots of size DOTSIZE.
%  The default DOTSIZE is set to 20.
%
%  CDOT2D(X,Y,CVAL,DOTSIZE,CMAP) will plot the data using the color map
%  CMAP.  The default color map is JET.  Type 'help color' for a list
%  of Matlab's color maps.  CMAP must be a string.
%
%  CDOT2D(X,Y,CVAL,DOTSIZE,CMAP,CRANGE) where CRANGE is a 2 element vector
%  [crange_min, crange_max], limits the range of the pseudocolored plot from
%  crange_min to crange_max.  CVAL data outside this range are not plotted.
%  The default is to use the min and max values of CVAL for CRANGE.
%
%	Example:
%
%	CDOT2D(randn(30,1),randn(30,1),randn(30,1),25,'copper',[-2,2]);
%	would plot 30 random points using dots with a size of 25,
%       and the copper color map with a data range from -2 to 2.
%
%  Help COLOR will give you a listing of matlab's built in color maps.

% this needs to be fixed:
% Warning: axes AspectRatio has been superseded by DataAspectRatio
% and PlotBoxAspectRatio and will not be supported in future releases.
% > In e:\m_files\Codar_mfiles\cdot2d.m at line 101


%	Mike Cook - NPS Oceanography Dept., JULY 94

%%%%%%  Default assignments and error checking section %%%%%%%
dfltdotsize =20;		% Default dot size
dfltMapColor = 'jet';		% Default colormap

if nargin < 3
   error(' You *MUST* supply at least 3 arguements');
end
if nargin < 4
   dotsize = dfltdotsize;
end

if nargin < 5
   MapColor = dfltMapColor;
else
   if isstr(MapColor) ~= 1
     error(' You *MUST* supply a string for the map color - type ''help color''')
   end
end

if nargin < 6	% If user doesn't supply max/min range - use max/min of data.
   crange(1) = min(min(cval));
   crange(2) = max(max(cval));
else
   if length(crange) ~= 2
     error(' You *MUST* supply a 2 element vector for the data range')
   end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

colormap(MapColor);
map=colormap;			% Get color scale - 64 rgb triplets.

x = x(:);
y = y(:);
cval = cval(:);

row= length(cval);

b1 = (64-1) / (crange(2)-crange(1));
b0 = ( -b1 * crange(1) ) + 1;
Clrs = round( (cval .* b1) + b0);

% % % Draw points with the value of each point represented by a color.
% % mainAX = axes('Box','on','TickDir','out','TickLength',[0.017,0.025], ...
% %              'FontWeight','bold');
              
for i = 1:row
    if Clrs(i) >= 1  &&  Clrs(i) <= 64
%         % Code to plot dots, or ...
%         line('Xdata',x(i),'Ydata',y(i),'Marker','.', ...
%             'MarkerSize',dotsize,'Color',map(Clrs(i),1:3) );

        % ... code to plot squares.
        line('Xdata',x(i),'Ydata',y(i),'Marker','s', ...
            'MarkerSize',dotsize,'Color',map(Clrs(i),1:3),'MarkerFaceColor', map(Clrs(i),1:3));

        %   else
        %     line('Xdata',x(i),'Ydata',y(i),'Marker','.', ...
        %        'MarkerSize',dotsize,'Color','w' );
    end
end

mainAX = gca;
set(mainAX,'Box','on','TickDir','out','TickLength',[0.017,0.025], ...
           'FontWeight','bold');

% resize surface object axis - preserve aspectratio if set.  If aspectratio
% is not set, the axis and scale factors are set to [NaN, NaN].
aspectfactors = get(mainAX,'DataAspectRatio');


% return % removes colorbar

% % Draw a colorbar which shows the scale of the points.
% % resize main axis so colorbar fits vertically to the left of the main axis.
% set(mainAX,'units','normal');
% opos=get(mainAX,'pos');
% dx = opos(3)/(.775/.15);
% set(mainAX,'Position',[opos(1)+dx, opos(2), opos(3)-dx, opos(4)], ...
%            'DataAspectRatio',aspectfactors);
% %%set(mainAX,'Position',[opos(1)+0.15, opos(2), opos(3)-0.15, opos(4)]);
% 
% % create new axis for colorbar
% dx = opos(3)/(.775/.01);
% dx2 = opos(3)/(.775/.05);
% ax = axes('Position',[opos(1)-dx, opos(2), dx2/2, opos(4)],'units','normal');
% %%ax = axes('Position',[opos(1)-0.01, opos(2), 0.05, opos(4)],'units','normal');
% 
% BE hack:
set(mainAX,'units','normal');
opos=get(mainAX,'pos');
dx = opos(3)/(15.5)/2;
% resize main axis so colorbar fits vertically to the left
% NOTE:  "Setting the DataAspectRatio will disable the stretch-to-fill
% behavior ..."
%set(mainAX,'DataAspectRatio',aspectfactors);
% create new axis for colorbar
%ax = axes('Position',[opos(1)-2*dx, opos(2), dx, opos(4)],'units','normal');
ax = axes('Position',[0.935 opos(2), dx, opos(4)],'units','normalized');

% draw colorbar with limits from crange(1) to crange(2).
zmin = crange(1);
zmax = crange(2);

y=linspace(zmin,zmax,100);
ColorRange=[y', y'];

p = pcolor([1,2], ColorRange(:,1), ColorRange);
set(p,'FaceColor','interp','EdgeColor','none');
caxis([zmin,zmax]);
set(ax,'Xlim',[1,2], ...
       'Ylim',[zmin,zmax],...
       'FontWeight','bold', ...
       'TickLength',[0,0],...
       'XTickLabel',[' '],...
       'YAxisLocation','right', ...
       'Box','off'); %,'YTickLabel',[' ']) %rm's colorbar labs
   
% make surface object axis default
axes(mainAX);

end
