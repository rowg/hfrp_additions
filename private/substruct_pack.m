function R = substruct_pack(R,subS,fn)
% SUBSTRUCT PACK - move structure contents to a substructure structure
% R = substruct_pack(R,substruct,fields)
%
% EXAMPLE
% un-pack other matrix variables to the top level:
% R = substruct_unpack(R,'OtherMatrixVars',{'ERTC'})

% Copyright (C) 2010 Brian M. Emery


if ~isempty(fn)
   
   for i = 1:numel(fn)
      R.(subS).(fn{i}) = R.(fn{i});
   end
   
   R = rmfield(R,fn);
   
end

end