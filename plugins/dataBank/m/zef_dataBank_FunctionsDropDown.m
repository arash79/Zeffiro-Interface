function zef = zef_dataBank_FunctionsDropDown(zef)
%ZEF_DATABANK_FUNCTIONSDROPDOWN  Show the Combine or Import/Export panel.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   FunctionsDropDown.ValueChangedFcn in zef_open_dataBank. Hides
%   combinePanel, importPanel, and mag2gragPanel, then:
%     'combine Lf'     → combinePanel Visible On
%     'Import/Export'  → importPanel moved to combinePanel.Position, Visible On
%     'mag2grad'       → empty case
%
%   zef = zef_dataBank_FunctionsDropDown(zef)
%
%   Inputs
%     zef  - session with dataBank.app. nargin==0 → base.
%
%   Output
%     zef  - panel visibility updated. nargout==0 → assignin base.
%
%   See also zef_open_dataBank, zef_dataBank_combineLeadFields.

if nargin == 0
    zef = evalin('base','zef');
end

zef.dataBank.app.combinePanel.Visible='Off';
zef.dataBank.app.importPanel.Visible='Off';
zef.dataBank.app.mag2gragPanel.Visible='Off';

switch zef.dataBank.app.FunctionsDropDown.Value

    case 'combine Lf'
        zef.dataBank.app.combinePanel.Visible='On';

    case 'Import/Export'
        zef.dataBank.app.importPanel.Position=zef.dataBank.app.combinePanel.Position;
        zef.dataBank.app.importPanel.Visible='On';

    case 'mag2grad'

end

if nargout == 0
    assignin('base','zef',zef);
end

end
