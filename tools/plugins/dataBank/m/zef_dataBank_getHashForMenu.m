function zef = zef_dataBank_getHasForMenu(zef)
% --- Zeffiro documentation header ---
% zef_dataBank_getHasForMenu — Zef data Bank get Has For Menu.
%
% Purpose:
%   Zef data Bank get Has For Menu.
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
%   zef_dataBank_getHasForMenu
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_dataBank_getHasForMenu(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef');
end

if isempty(zef.dataBank.app.Tree.SelectedNodes) %either no selected or no node in tree, either way start on first level

    disp('please select nodes');
    return;

else
    if size(zef.dataBank.app.Tree.SelectedNodes,1)>1

        if ~zef.dataBank.selectMultiple
            disp('cannot select multiple nodes');
            return;
        end

        for dbi=1:size(zef.dataBank.app.Tree.SelectedNodes,1)
            zef.dataBank.hash{dbi}=zef.dataBank.app.Tree.SelectedNodes(dbi).NodeData;
        end
    else

        zef.dataBank.hash=zef.dataBank.app.Tree.SelectedNodes.NodeData;
    end

end

if nargout == 0
    assignin('base','zef',zef);
end


end
