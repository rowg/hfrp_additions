function M = struct_pack(fn,M)
% STRUCT PACK - move varibles into structure
% S = struct_pack(varibles, S)
%
% INPUT
% cell array with names of variable 
% (optionally) the struct to append to 
%
% see also: struct_unpack, substruct_unpack

% Copyright (C) 2010 Brian M. Emery

if nargin < 2, M = []; end 

for i = 1:numel(fn)
  M.(fn{i}) = evalin('caller',fn{i});
end


end