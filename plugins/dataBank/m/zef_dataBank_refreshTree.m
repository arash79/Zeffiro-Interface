function zef = zef_dataBank_refreshTree(zef)
%ZEF_DATABANK_REFRESHTREE  Wipe uitree children and rebuild from the tree struct.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   RefreshButton.ButtonPushedFcn in zef_open_dataBank. Also called after
%   delete, import, and from add_data_item. Deletes all Tree.Children then
%   zef_dataBank_hash2tree.
%
%   zef = zef_dataBank_refreshTree(zef)
%
%   Inputs
%     zef  - session with dataBank.app.Tree and dataBank.tree. nargin==0 → base.
%
%   Output
%     zef  - uitree rebuilt. nargout==0 → assignin base.
%
%   See also zef_dataBank_hash2tree.

if nargin == 0
    zef = evalin('base','zef');
end

zef.dataBank.app.Tree.Children.delete;
zef = zef_dataBank_hash2tree(zef);

if nargout == 0
    assignin('base','zef',zef);
end

end
