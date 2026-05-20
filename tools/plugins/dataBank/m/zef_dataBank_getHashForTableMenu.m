function zef = zef_dataBank_getHashForTableMenu(zef)
% --- Zeffiro documentation header ---
% zef_dataBank_getHashForTableMenu — Zef data Bank get Hash For Table Menu.
%
% Purpose:
%   Zef data Bank get Hash For Table Menu.
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
%   zef_dataBank_getHashForTableMenu
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: `[zef] = zef_dataBank_getHashForTableMenu(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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
