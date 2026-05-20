function zef = zef_dataBank_FunctionsDropDown(zef)
% --- Zeffiro documentation header ---
% zef_dataBank_FunctionsDropDown — Zef data Bank Functions Drop Down.
%
% Purpose:
%   Zef data Bank Functions Drop Down.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.dataBank (read)
%
% Calls (project):
%   zef_dataBank_FunctionsDropDown
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_dataBank_FunctionsDropDown(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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
