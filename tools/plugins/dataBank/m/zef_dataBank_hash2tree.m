function [zef] = zef_dataBank_hash2tree(zef)
% --- Zeffiro documentation header ---
% zef_dataBank_hash2tree — Zef data Bank hash2tree.
%
% Purpose:
%   Zef data Bank hash2tree.
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
%   zef_dataBank_hash2tree
%   zef_dataBank_rebuildTree
%   zef_dataBank_rebuildTreeSaveFile
%   zef_dataBank_reorderTree
%   zef_dataBank_sortTree
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_dataBank_hash2tree(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef')
end

%this builds a uiTree in the databank.app from the databank.tree node
%hashcodes

%zef.dataBank.tree=zef_dataBank_reorderTree(zef.dataBank.tree);
%zef.dataBank.tree=zef_dataBank_sortTree(zef.dataBank.tree);

% if strcmp(zef.dataBank.save2disk, 'Off')
zef.dataBank.tree=zef_dataBank_sortTree(zef.dataBank.tree);
zef.dataBank.tree=zef_dataBank_rebuildTree(zef.dataBank.tree);

if strcmp(zef.dataBank.save2disk, 'On')
    zef.dataBank.tree= zef_dataBank_rebuildTreeSaveFile(zef.dataBank.tree);
end

zef.dataBank.hashList=fieldnames(zef.dataBank.tree);

for dbi=1:length(zef.dataBank.hashList)
    dbparent=zef.dataBank.app.Tree;

    zef.dataBank.hash=extractAfter(zef.dataBank.hashList{dbi}, 'node_');

    while contains(zef.dataBank.hash, '_')
        hashNumber=extractBefore(zef.dataBank.hash, '_');
        dbparent=dbparent.Children(str2double(hashNumber));
        zef.dataBank.hash=extractAfter(zef.dataBank.hash, '_');
    end
    newNode=uitreenode(dbparent, 'Text', zef.dataBank.tree.(zef.dataBank.hashList{dbi}).name, 'NodeData',zef.dataBank.tree.(zef.dataBank.hashList{dbi}).hash);
    newNode.ContextMenu=zef.dataBank.app.treeMenu;

end

expand(zef.dataBank.app.Tree, 'all');

clear dbparent newNode

if nargout == 0
    assignin('base','zef',zef);
end

end
