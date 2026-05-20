% --- Zeffiro documentation header ---
% function [] = zef_dataBank_uiTreeDeleteHash(node, hashList) — Function [] = zef data Bank ui Tree Delete Hash(node, hash List).
%
% Purpose:
%   Function [] = zef data Bank ui Tree Delete Hash(node, hash List).
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Calls (project):
%   zef_dataBank_uiTreeDeleteHash
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `function [] = zef_dataBank_uiTreeDeleteHash(node, hashList)` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header
function [] = zef_dataBank_uiTreeDeleteHash(node, hashList)

if isprop(node, 'NodeData')

    for i=1:length(hashList)
        if strcmp(node.NodeData, hashList{i})
            node.delete;
            return;
        end
    end
end

if ~isempty(node.Children)
    for i=length(node.Children):-1:1
        zef_dataBank_uiTreeDeleteHash(node.Children(i), hashList);
    end
end

end
