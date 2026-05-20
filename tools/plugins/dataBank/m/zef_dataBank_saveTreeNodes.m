function [tree] = zef_dataBank_saveTreeNodes(tree, folder)
% --- Zeffiro documentation header ---
% zef_dataBank_saveTreeNodes — Zef data Bank save Tree Nodes.
%
% Purpose:
%   Zef data Bank save Tree Nodes.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   tree
%   folder
%
% Outputs:
%   tree
%
% Calls (project):
%   zef_dataBank_saveTreeNodes
%
% Side effects:
%   - filesystem I/O
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[tree] = zef_dataBank_saveTreeNodes(tree, folder)` with project root and `src` on the path.
% --- End Zeffiro documentation header

dbFieldNames=fieldnames(tree);

for i=1:length(dbFieldNames)

    nodeData=tree.(dbFieldNames{i}).data;
    folderName=strcat(folder, dbFieldNames{i});
    save(folderName, '-struct', 'nodeData');
    tree.(dbFieldNames{i}).data=matfile(folderName);

end

end
