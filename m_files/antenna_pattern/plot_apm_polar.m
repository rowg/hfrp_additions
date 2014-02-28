function h = plot_apm_polar(APM,tf)
% PLOT APM POLAR - polar antenna patter plot
% h = plot_apm_polar(APM)
% Make Plots like Cross Loop Patterner
%
% INPUT
% Standard APM structure (minimum required fields are BEAR A13M A23M, see
% apm_struct.m)
%
% Optionally include boolean false as second input to prevent second plot
% of phases (useful for adding APMs to existing figures).

% Copyright (C) 2009-2010 Brian M. Emery
% June 2009

if nargin ==1, tf=1; figure, end

h{1}=polar(APM.BEAR*pi/180,APM.A13M,'-r.'); hold on
h{2}=polar(APM.BEAR*pi/180,APM.A23M,'-b.');

try
    polar([APM.loop1Brg APM.loop1Brg]*pi/180,[0 max([APM.A23M(:)' APM.A13M(:)'])],'y')
catch
end
view(90,-90)

if ~tf

    figure
    plot(APM.BEAR,APM.A13P,'-r.'), hold on
    plot(APM.BEAR,APM.A23P,'-b.')
    xlabel('BEARing CWN')
    ylabel('Phase (deg)')

end
end
