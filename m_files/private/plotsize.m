% PLOTSIZE.M
% Standardize the sizing and plotting of
% all these frickin figures.

% 10Jan00 Brian Emery

set(gcf,'PaperOrientation','Portrait')
 set(gcf,'Units','Inches')         
 set(gcf,'Position',[2.6 1.5 7.5 5.625])
%This sets the x,y,width, and height of the plot on the paper (in inches..)
 set(gcf,'PaperPosition',[0.25,0.25,7.5,5.625])
%set(gcf,'Position',[1 1 10.2 7])
%set(gcf,'PaperPosition',[0.25,0.25,10.2,7])

 return
 % notes on using pita to print figures:
 set(gcf,'PaperOrientation','Landscape')
 set(gcf,'Units','Inches')
 set(gcf,'PaperPosition',[0.25,0.25,36,15])
 
 %  with page setup settings: top=0.0 left=.71, width 35, height 23.5 (inches)
 %          use manual settings
 % paper settings: custom paper size, orientation portrait
 %
 % with these settings pita prints with the right side of the
 % figure as the first to come out of the printer