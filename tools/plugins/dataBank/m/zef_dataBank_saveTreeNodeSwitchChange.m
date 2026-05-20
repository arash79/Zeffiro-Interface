function zef = zef_dataBank_saveTreeNodeSwitchChange(zef)
% --- Zeffiro documentation header ---
% zef_dataBank_saveTreeNodeSwitchChange — Zef data Bank save Tree Node Switch Change.
%
% Purpose:
%   Zef data Bank save Tree Node Switch Change.
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
%   zef_dataBank_loadTreeNodes
%   zef_dataBank_saveTreeNodeSwitchChange
%   zef_dataBank_saveTreeNodes
%   zef_waitbar
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_dataBank_saveTreeNodeSwitchChange(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef')
end

zef.dataBank.save2disk=zef.dataBank.app.savetodiskSwitch.Value;

if strcmp(zef.dataBank.save2disk, 'Off') %deleting the files
    fwait= zef_waitbar(0,1, 'loading and deleting the data. Please wait');
    zef.dataBank.tree=zef_dataBank_loadTreeNodes(zef.dataBank.tree);
    close(fwait);

end

if strcmp(zef.dataBank.save2disk, 'On') %saving the files
    fwait= zef_waitbar(0,1, 'Saving the data. Please wait');
    zef.dataBank.tree=zef_dataBank_saveTreeNodes(zef.dataBank.tree, zef.dataBank.folder);
    close(fwait);
end

clear fwait

if nargout == 0
    assignin('base','zef',zef);
end

end
