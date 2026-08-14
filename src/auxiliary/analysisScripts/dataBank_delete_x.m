%DATABANK_DELETE_X  Lab script: delete every databank node of type 'gmm'.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Walks fieldnames of zef.dataBank.tree that start with 'node'.
%   zef_dataBank_delete(..., 'false') when type=='gmm'. Restarts the scan
%   after each delete. Needs a live zef.dataBank.
%

dltType='gmm';

%dltType='reconstruction';

onlyIn='node';

allHashes=fieldnames(zef.dataBank.tree);
allHashes=allHashes(startsWith(allHashes, onlyIn));

i=1;

while i<=length(allHashes)

    if strcmp(zef.dataBank.tree.(allHashes{i}).type, dltType)
        zef.dataBank.hash=allHashes{i};
        zef.dataBank.tree=zef_dataBank_delete(zef.dataBank.tree, zef.dataBank.hash, 'false');
        %zef_dataBank_uiTreeDeleteHash(zef.dataBank.app.Tree, zef.dataBank.hash);
        allHashes=fieldnames(zef.dataBank.tree);
        allHashes=allHashes(startsWith(allHashes, onlyIn));

        i=1;
    else
        i=i+1;
    end

end
