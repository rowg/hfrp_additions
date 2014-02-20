function xtickd(opt)
% XTICKD.M
% xtickd(opt)
% This mfile converts serial dates on the x
% axes into ticks showing the begining of each DAY.
% 'opt' sets the labeling option:
%   1 for labeling days and months
%   2 for labeling days and months on bottom axis only.
% xtickd with no input arguments sets the tick marks only.
%
% NOTE: when working with SUBPLOTS, this mfile doesnt assume
% subplots have same x axis, so it runs a loop over each axis. Thus, run
% this outside of loops using subplot.
%
% Impractical for plots of more than about 3 months. Converts the x axis on
% each of the subplots as well.
%
% EXAMPLE:
% plot([now-37 now],[2 2])
% xtickd(2)

% originally contrived 21July02 by Brian Emery
% fully remodelled 4dec04
% added option of large ticks 22 Jan 2010

if nargin<1, opt=0; end

% GET AXES HANDLES
hFig=gcf;
figure(hFig)
chil=get(hFig,'Children');
hAllAxes=findobj(chil,'type','axes'); clear chil

% colorbars have a tag, others dont - use this to get to real axes
i=strmatch('',get(hAllAxes,'Tag'),'exact');
hAllAxes=hAllAxes(i); 

% Make sure bottom axis is last
hAllAxes = sort_axes(hAllAxes);

% LOOP OVER AXES
% Dont assume subplots have same x axis, so run a loop for each set of axes
for j=1:length(hAllAxes)
    
    axes(hAllAxes(j))

    % get the end points, create the vector of serialtimes for the x label,
    % and get the date lables
    a=axis;
    xpos=a(1):a(2);
    [yr mo days h mi s]=datevec(a(1):a(2)); clear h mi s

    % optionally make some large ticks?
    set_xticks(gca,xpos,a,0)

     % get rid of any xlabel, but keep it's position
    hlab=xlabel('');
    xLabPos=get(hlab,'Position'); % this seems to be in data units??

    % USE INPUTS TO LABEL AXES
    % Ticks only, no labels
    if opt==0 || (opt==2 & j~=length(hAllAxes))
        set(gca,'XTickLabel','')
       
    % Ticks and labels
    elseif opt==1 || (opt==2 & j==length(hAllAxes))
                
        % 2 options: month label in middle of plot, or month label under
        % it's appropriate dates
        
        if length(unique(mo))==1

            % ONE MONTH
            % create a cell array of labs and label the axes
            xlabs=cellstr(num2str(days'));
            set(gca,'XTickLabel',xlabs)

            % put label in middle of plot
            xlabel([datestr((a(1)+a(2))/2,3) ' ' datestr((a(1)+a(2))/2,10)])

        else

            % MORE THAN ONE MONTH
            % create a cell array of labs and label the axes
            % This will cause the number of xtick labels to max at ~30
            xlabs=cellstr(num2str(days'));
            if round(length(xlabs)/30) >= 2
                xlabs(2:round(length(xlabs)/30):end) = deal({' '});
            end 
            set(gca,'XTickLabel',xlabs)

            % put labels under middle of monthly dates shown on the axes
            % find the midpoints of each visible month shown
            b=unique(mo);
            iMid=[];
            for k=1:length(b)
                imo=find(mo==b(k)); % indecies of mo
                iMid=[iMid round(mean(imo))]; % index of mid point
            end
            % put the month labels at xpos(iMid)
            text(xpos(iMid),xLabPos(2)*ones(1,length(iMid)),datestr(xpos(iMid),3))
        end
    end
end

end


%% ----------------------------------------------------------------------
function hAllAxes = sort_axes(hAllAxes)

for i = 1:length(hAllAxes)
    p(i,:) = [get(hAllAxes(i),'Position')]; 
end
[x,j]=sort(p(:,2),1,'descend');
hAllAxes=hAllAxes(j);
end
%% ----------------------------------------------------------------------
function  set_xticks(gca,xpos,a,tf)
% SET TICKS
% allow the option of major ticks for a given day of the week
% NEEDS WORK ... tick sizes change too much 

% normal case
set(gca,'XTick',xpos)

if tf
    
    % large ticks on sundays
    [d,w]=weekday(a(1):a(2));
    sun = find(d==1);
    
    % get normalized length
    l = get(gca,'TickLength');
    a = axis;

    dy = l(1)*(max([a(4)-a(3) a(2)-a(1)]));
    
    hold on
    plot([xpos(sun); xpos(sun)],[a(3) a(3)+(5*dy)],'-k','LineWidth',1.5)
    keyboard
end

end
