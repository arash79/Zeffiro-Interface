function [info, columnNames] = zef_dataBank_WorkingSpaceInfo(tree, hash)
%ZEF_DATABANK_WORKINGSPACEINFO  Table of hash / type / name for workingHashes.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   showworkingHashes.ButtonPushedFcn and the last step of modifyMenu in
%   zef_open_dataBank fill currentTable. Does not modify zef or the tree.
%
%   [info, columnNames] = zef_dataBank_WorkingSpaceInfo(tree, hash)
%
%   Inputs
%     tree  - zef.dataBank.tree.
%     hash  - char or cellstr of working hashes.
%
%   Output
%     info         - n-by-3 cell: hash, node type, name.
%     columnNames  - {'hash', 'node type', 'name'}.
%
%   See also zef_dataBank_hashToWorkingSpace.

columnNames={'hash', 'node type', 'name'};
if ~iscell(hash)
    hash={hash};
end
info=cell(length(hash), 3);

for i=1:length(hash)

    info{i,1}=hash{i};
    info{i,2}=tree.(hash{i}).type;
    info{i,3}=tree.(hash{i}).name;

end

end
