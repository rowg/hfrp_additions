function plot_loop_file 
% PLOT LOOP FILE
% potential future function ....
% 
% plots contents of loop file vs bearing and time 

cd /Volumes/CodarData-1/AntennaPatternData/COP/20100818

DAT=ctfReader('LOOP_cop1_100818_192848.loop');

% Get necessary fields
DAT.BEAR = DAT.TRGB;

% Convert time
DAT.TimeStamp = datenum([num2str(DAT.DATE) num2str(DAT.TIME)],'yyyymmddHHMMSS');



% PLOT VS BEARING
% subplotting function 
plot_vs('BEAR',DAT)

% PLOT VS TIME
% subplotting function 
plot_vs('TimeStamp',DAT)



% POLAR PLOT
figure
h = plot_apm_polar(DAT,1); hold on

% exclude low signal level points
j = find(DAT.AR3D > -60 & abs(DAT.TRGV) < .75);
APM = subsref_struct(DAT,j,2093,1);
h = plot_apm_polar(APM,1);
set(h{1},'Color','g')
set(h{2},'Color','m')

ctfWriter(APM,'LOOP_cop1_100818_a.loop')


end
%% -------------------------------------------------------------------
function plot_vs(x,DAT)

figure
haxes=makesubplots(5,1,.05,.05);
  
plot_ax(DAT.(x),DAT.A13M,'-r.',haxes(1),'Magnitudes')
plot_ax(DAT.(x),DAT.A23M,'-b.',haxes(1),'Magnitudes')


plot_ax(DAT.(x),DAT.A13P,'-r.',haxes(2),'Phases')
plot_ax(DAT.(x),DAT.A23P,'-b.',haxes(2),'Phases')


plot_ax(DAT.(x),DAT.A1SN,'-r.',haxes(3),'SNR')
plot_ax(DAT.(x),DAT.A2SN,'-b.',haxes(3),'SNR')
plot_ax(DAT.(x),DAT.A3SN,'-g.',haxes(3),'SNR')


plot_ax(DAT.(x),DAT.AR3D,'-b.',haxes(4),'AR3D')


plot_ax(DAT.(x),DAT.TRGD,'-b.',haxes(5),'Dist(m)',0)

xlabel(x)


end
%% -------------------------------------------------------------------
function plot_ax(x,y,ls,hax,ylab,tf)

if nargin<6, tf = 1; end

axes(hax)
plot(x,y,ls), hold on
ylabel(ylab)

if tf, set(gca,'XTickLabel',''), end

end



