% --- Zeffiro documentation header ---
% zef = zef_dataBank_delete_uitree(zef) — Zef = zef data Bank delete uitree(zef).
%
% Purpose:
%   Zef = zef data Bank delete uitree(zef).
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.dataBank (read)
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef = zef_dataBank_delete_uitree(zef)` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef = zef_dataBank_delete_uitree(zef)

if nargin == 0
    zef = evalin('base','zef')
end

if size(zef.dataBank.app.Tree.SelectedNodes,1)>1

    for dbk=1:size(zef.dataBank.app.Tree.SelectedNodes,1)
        zef.dataBank.app.Tree.SelectedNodes(dbk).delete;
    end

else

    zef.dataBank.app.Tree.SelectedNodes.delete;

end

clear dbk;

if nargout == 0
    assignin('base','zef',zef);
end

end
