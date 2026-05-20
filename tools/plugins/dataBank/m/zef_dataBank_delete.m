function [tree] = zef_dataBank_delete(tree, parentHash, save2disk)
% --- Zeffiro documentation header ---
% zef_dataBank_delete — Zef data Bank delete.
%
% Purpose:
%   Zef data Bank delete.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   tree
%   parentHash
%   save2disk
%
% Outputs:
%   tree
%
% Calls (project):
%   zef_dataBank_delete
%   zef_dataBank_rebuildTree
%   zef_dataBank_rebuildTreeSaveFile
%   zef_dataBank_sortTree
%
% Side effects:
%   - filesystem I/O
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: `[tree] = zef_dataBank_delete(tree, parentHash, save2disk)` with project root and `src` on the path.
% --- End Zeffiro documentation header


hashNames=fieldnames(tree);

for i=1:length(hashNames)

    if startsWith(hashNames{i}, strcat(parentHash, '_')) || strcmp(hashNames{i}, parentHash) %only children should be deleted. node_11 should not be deleted by node_1
        if isobject(tree.(hashNames{i}).data)
            delete(tree.(hashNames{i}).data.Properties.Source);
        end

        tree=rmfield(tree, hashNames{i});
    end

end

tree=zef_dataBank_sortTree(tree);
tree=zef_dataBank_rebuildTree(tree);

if strcmp(save2disk, 'On')
    tree=zef_dataBank_rebuildTreeSaveFile(tree);
end

end
