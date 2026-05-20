function zef = zef_dataBank_startNameChange(zef)
% --- Zeffiro documentation header ---
% zef_dataBank_startNameChange — Zef data Bank start Name Change.
%
% Purpose:
%   Zef data Bank start Name Change.
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
%   zef_dataBank_getHashForMenu
%   zef_dataBank_startNameChange
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: `[zef] = zef_dataBank_startNameChange(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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
