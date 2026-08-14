function zef = zef_dataBank_getHasForMenu(zef)
%ZEF_DATABANK_GETHASHFORMENU  Selected uitree NodeData → zef.dataBank.hash.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Tree.SelectionChangedFcn and tree-menu callbacks in zef_open_dataBank
%   (loadMenu, loadwithparentsMenu, deleteMenu, modifyMenu, changeName,
%   showinformationMenu, exportButtonPress). If nothing is selected, prints
%   'please select nodes' and returns. Multiple SelectedNodes are allowed
%   only when zef.dataBank.selectMultiple is true (modifyMenu sets that);
%   then hash is a cell of NodeData strings. Otherwise hash is the single
%   NodeData char. Filename is zef_dataBank_getHashForMenu.m; the function
%   symbol is zef_dataBank_getHasForMenu.
%
%   zef = zef_dataBank_getHashForMenu(zef)
%
%   Inputs
%     zef  - session with dataBank.app.Tree. nargin==0 → base.
%
%   Output
%     zef  - zef.dataBank.hash set. nargout==0 → assignin base.
%
%   See also zef_dataBank_getHashForTableMenu, zef_dataBank_setData.

if nargin == 0
    zef = evalin('base','zef');
end

if isempty(zef.dataBank.app.Tree.SelectedNodes) %either no selected or no node in tree, either way start on first level

    disp('please select nodes');
    return;

else
    if size(zef.dataBank.app.Tree.SelectedNodes,1)>1

        if ~zef.dataBank.selectMultiple
            disp('cannot select multiple nodes');
            return;
        end

        for dbi=1:size(zef.dataBank.app.Tree.SelectedNodes,1)
            zef.dataBank.hash{dbi}=zef.dataBank.app.Tree.SelectedNodes(dbi).NodeData;
        end
    else

        zef.dataBank.hash=zef.dataBank.app.Tree.SelectedNodes.NodeData;
    end

end

if nargout == 0
    assignin('base','zef',zef);
end


end
