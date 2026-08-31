function zef = zef_dataBank_exportButtonPress(zef)
%ZEF_DATABANK_EXPORTBUTTONPRESS  Save the selected node or the whole tree to a .mat.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   exportButton.ButtonPushedFcn in zef_open_dataBank. Calls
%   zef_dataBank_getHashForMenu, then uiputfile('Select a file').
%   typeDropDown.Value 'Node' saves that node struct (if .data is an
%   object, tries load(data.Properties.Source) — the Source lives on
%   data.data for a matfile payload). Otherwise save(..., '-struct',
%   'tree') of zef.dataBank.tree. Tree exportMenu is a separate stub
%   ('sorry, this is not implemented,yet') and does not call this.
%
%   zef = zef_dataBank_exportButtonPress(zef)
%
%   Inputs
%     zef  - session with a selected tree node. nargin==0 → base.
%
%   Output
%     zef  - unchanged except hash from getHashForMenu. Writes a .mat.
%            nargout==0 → assignin base.
%
%   See also zef_dataBank_importNodeButtonPress.

if nargin == 0
    zef = evalin('base','zef');
end

zef_dataBank_getHashForMenu;
[savefile,savepath] = uiputfile('*','Select a file');

if strcmp(zef.dataBank.app.typeDropDown.Value, 'Node')

    data=zef.dataBank.tree.(zef.dataBank.hash);
    if isobject(data.data)
        data.data=load(data.Properties.Source);
    end
    save(strcat(savepath, savefile), '-struct', 'data');
else
    tree=zef.dataBank.tree;
    save(strcat(savepath, savefile), '-struct', 'tree');
end

clear data savefile savepath tree

if nargout == 0
    assignin('base','zef',zef);
end

end
