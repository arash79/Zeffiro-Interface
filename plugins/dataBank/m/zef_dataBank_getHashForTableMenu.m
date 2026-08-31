function zef = zef_dataBank_getHashForTableMenu(zef)
%ZEF_DATABANK_GETHASHFORTABLEMENU  DataTable row → zef.dataBank.hash via DataTableHashList.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Same role as getHashForMenu but for the type table context menus
%   (showinformationMenuData, deleteMenuData, modifyMenuData).
%   DataTable.Selection(:,1) indexes zef.dataBank.DataTableHashList, which
%   showAll filled when the table was last drawn. Multi-row selection
%   requires selectMultiple. Empty Selection prints 'please select nodes'.
%
%   zef = zef_dataBank_getHashForTableMenu(zef)
%
%   Inputs
%     zef  - session with DataTable.Selection and DataTableHashList.
%            nargin==0 → base.
%
%   Output
%     zef  - zef.dataBank.hash char or cell. nargout==0 → assignin base.
%
%   See also zef_dataBank_getHashForMenu, zef_databank_showAll.

if nargin == 0
    zef = evalin('base','zef')
end

if isempty(zef.dataBank.app.DataTable.Selection) %either no selected or no node in tree, either way start on first level

    disp('please select nodes');
    return;

else
    if size(zef.dataBank.app.DataTable.Selection,1)>1

        if ~zef.dataBank.selectMultiple
            disp('cannot select multiple nodes');
            return;
        end

        for dbi=unique(zef.dataBank.app.DataTable.Selection(:,1))'
            zef.dataBank.hash{dbi}=zef.dataBank.DataTableHashList{dbi};
        end
    else

        zef.dataBank.hash=zef.dataBank.DataTableHashList(zef.dataBank.app.DataTable.Selection(1));
    end

end

if nargout == 0
    assignin('base','zef',zef);
end

end
