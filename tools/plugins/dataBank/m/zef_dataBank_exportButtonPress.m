function zef = zef_dataBank_exportButtonPress(zef)
% --- Zeffiro documentation header ---
% zef_dataBank_exportButtonPress — Zef data Bank export Button Press.
%
% Purpose:
%   Zef data Bank export Button Press.
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
%   zef_dataBank_exportButtonPress
%
% Side effects:
%   - base/caller workspace
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: `[zef] = zef_dataBank_exportButtonPress(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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
