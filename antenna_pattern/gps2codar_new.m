function gps2codar_new(fname)
%gps2codar_new.m
% gps2codar_new(fname)
% lots of parsing and 'text to columns' done in excell to get to this point
% xls file with this format:
% lat lon Hr Min Sec 
%[num,txt,raw]=xlsread('patternGPS18aug05_ssd_edit2.xls');
%
% NOte that this expects the hrs to be in PM, ie, it adds 12 to them ...
[num,txt,raw]=xlsread(fname);
fout=fname(1:end-4);

H=num(:,3)+12;
MI=num(:,4);
S=num(:,5);
lat=num(:,1);
lon=0-num(:,2);
mins=(60.*H)+MI+(S./60);
dat=[mins lat lon]; keyboard
save([fout '_cosFormat.txt'],'dat','-ascii','-double');
disp(['data saved in codar''s format as ' pwd '\' fout '_cosFormat.txt'] )

return
plot(lon,lat,'.')
hold on
a=axis; %sbchan_map
axis(a)

end
