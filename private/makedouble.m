
% MAKEDOUBLE.M
% makedouble
% Make all numeric variables in the current workspace 
% Double precision.

% 14Oct99 Brian Emery

% get variable names
a=who; 
[m,n]=size(a); 

% run loop to use double.m
for l=1:m
   str=a{l,:};
   if eval(['isnumeric(' str ')'])
	eval([str '=double(' str ');'])
	str=[];
	end   
end

clear a j l m n str