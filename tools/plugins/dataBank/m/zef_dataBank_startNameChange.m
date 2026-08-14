function zef = zef_dataBank_startNameChange(zef)
%ZEF_DATABANK_STARTNAMECHANGE  Dialog that writes tree.(hash).name and uitree Text.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   changeNameMenu.MenuSelectedFcn in zef_open_dataBank. Disables the
%   uitree, forces selectMultiple false, getHashForMenu, then opens
%   zef_dataBank_nameChange_app. Label_oldName / Label_node show the
%   current name and hash. OkButton copies NameField.Value onto
%   tree.(hash).name and SelectedNodes.Text, re-enables the tree, and
%   deletes the dialog. CancelButton only re-enables and deletes.
%
%   zef = zef_dataBank_startNameChange(zef)
%
%   Inputs
%     zef  - session with a selected tree node. nargin==0 → base.
%
%   Output
%     zef  - nameChangeapp attached; name is written when OkButton runs.
%            nargout==0 → assignin base.
%
%   See also zef_dataBank_getHashForMenu.

if nargin == 0
    zef = evalin('base','zef');
end


zef.dataBank.app.Tree.Enable='off';

zef.dataBank.selectMultiple=false;
zef = zef_dataBank_getHashForMenu(zef);

zef.dataBank.nameChangeapp=zef_dataBank_nameChange_app;

zef.dataBank.nameChangeapp.Label_oldName.Text=zef.dataBank.tree.(zef.dataBank.hash).name;
zef.dataBank.nameChangeapp.Label_node.Text=zef.dataBank.hash;

zef.dataBank.nameChangeapp.OkButton.ButtonPushedFcn=strcat("zef.dataBank.tree.(zef.dataBank.hash).name=zef.dataBank.nameChangeapp.NameField.Value;", ...
    "zef.dataBank.app.Tree.SelectedNodes.Text=zef.dataBank.nameChangeapp.NameField.Value;", ...
    "zef.dataBank.app.Tree.Enable='on';", ...
    "zef.dataBank.nameChangeapp.delete;" );

zef.dataBank.nameChangeapp.CancelButton.ButtonPushedFcn=strcat("zef.dataBank.app.Tree.Enable='on';", ...
    "zef.dataBank.nameChangeapp.delete;" );

if nargout == 0
    assignin('base','zef',zef);
end

end
