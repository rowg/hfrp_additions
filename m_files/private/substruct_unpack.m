function R = substruct_unpack(R,subS)
% SUBSTRUCT UNPACK - move substructure contents to the top level structure
% R = substruct_unpack(R,substruct)
%
% EXAMPLE
% un-pack other matrix variables to the top level:
% R = substruct_unpack(R,'OtherMatrixVars')

% Copyright (C) 2010 Brian M. Emery


fn = fieldnames(R.(subS));
if ~isempty(fn)
   
   for i = 1:numel(fn)
      R.(fn{i}) = R.(subS).(fn{i});
   end
   
   R.(subS) = rmfield(R.(subS),fn);
   
end

end