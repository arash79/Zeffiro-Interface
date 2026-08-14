%ZEF_DATABANK_DELETE_UITREE  Delete currently selected uitreenode(s) from the widget.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   UI-only companion to zef_dataBank_delete (which updates the tree
%   struct). zef_open_dataBank's deleteMenu does not call this file; it
%   deletes from the struct then zef_dataBank_refreshTree. This file has
%   no `function` keyword: the first executable line is a self-call
%   `zef = zef_dataBank_delete_uitree(zef)` and the rest uses nargin /
%   nargout as if it were a function. Documented as-is; not wired to a
%   ButtonPushedFcn.
%
%   Intended: zef = zef_dataBank_delete_uitree(zef)
%
%   Inputs
%     zef  - session with dataBank.app.Tree.SelectedNodes.
%
%   Side effects
%     Calls .delete on the selected uitreenode(s). Does not rmfield the tree.
%
%   See also zef_dataBank_delete, zef_dataBank_uiTreeDeleteHash.

zef = zef_dataBank_delete_uitree(zef)

if nargin == 0
    zef = evalin('base','zef')
end

if size(zef.dataBank.app.Tree.SelectedNodes,1)>1

    for dbk=1:size(zef.dataBank.app.Tree.SelectedNodes,1)
        zef.dataBank.app.Tree.SelectedNodes(dbk).delete;
    end

else

    zef.dataBank.app.Tree.SelectedNodes.delete;

end

clear dbk;

if nargout == 0
    assignin('base','zef',zef);
end

end
