function [workingHashes] = zef_dataBank_hashToWorkingSpace(newHash, workingHashes)
%ZEF_DATABANK_HASHTOWORKINGSPACE  Append unique hashes to workingHashes.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   modifyMenu / modifyMenuData in zef_open_dataBank: after getHashForMenu,
%   workingHashes = zef_dataBank_hashToWorkingSpace(hash, workingHashes).
%   Those hashes are the Combine input. Duplicates are skipped. No widget I/O.
%
%   workingHashes = zef_dataBank_hashToWorkingSpace(newHash, workingHashes)
%
%   Inputs
%     newHash        - char or cellstr of hashes to add.
%     workingHashes  - existing cell (or a char, wrapped to a cell).
%
%   Output
%     workingHashes  - cellstr, unique, order preserved, new hashes at the end.
%
%   See also zef_dataBank_WorkingSpaceInfo, zef_dataBank_combineLeadFields.

if ~iscell(newHash)
    newHash={newHash};
end

if ~iscell(workingHashes)
    workingHashes={workingHashes};
end

for i=1:length(newHash)
    duplicate=0;
    for wh=1:length(workingHashes)

        if strcmp(newHash{i}, workingHashes{wh})
            duplicate=1;
        end

    end
    if ~duplicate
        workingHashes{end+1}=newHash{i};
    end

end

end
