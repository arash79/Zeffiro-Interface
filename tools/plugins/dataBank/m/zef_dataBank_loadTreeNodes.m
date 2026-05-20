function [tree] = zef_dataBank_loadTreeNodes(tree)
% --- Zeffiro documentation header ---
% zef_dataBank_loadTreeNodes — Zef data Bank load Tree Nodes.
%
% Purpose:
%   Zef data Bank load Tree Nodes.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   tree
%
% Outputs:
%   tree
%
% Calls (project):
%   zef_dataBank_loadTreeNodes
%
% Side effects:
%   - filesystem I/O
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[tree] = zef_dataBank_loadTreeNodes(tree)` with project root and `src` on the path.
% --- End Zeffiro documentation header

dbFieldNames=fieldnames(tree);

folder=extractBefore(tree.(dbFieldNames{1}).data.Properties.Source, 'node_');

for i=1:length(dbFieldNames)

    tree.(dbFieldNames{i}).data=load(tree.(dbFieldNames{i}).data.Properties.Source);

end
folder=strcat(folder, 'node_*');
delete(folder);

end
