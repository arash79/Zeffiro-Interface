function [zef] = zef_dataBank_hash2tree(zef)
%ZEF_DATABANK_HASH2TREE  Rebuild the uitree from zef.dataBank.tree hash keys.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called from zef_open_dataBank when a tree already exists, and from
%   zef_dataBank_refreshTree after the uitree children are deleted. Sorts
%   and rebuilds hashes so sibling indices are dense; if save2disk is 'On',
%   rebuildTreeSaveFile keeps .mat names in sync. Then walks each hash
%   after the 'node_' prefix: each numeric segment before the last selects
%   Children(k) as parent, and the last segment becomes a new uitreenode
%   with Text = node.name, NodeData = node.hash, ContextMenu = treeMenu.
%   Assumes hashes are already a forest under 'node'. nargout==0 → base.
%
%   zef = zef_dataBank_hash2tree(zef)
%
%   Inputs
%     zef  - session with dataBank.tree and dataBank.app.Tree.
%
%   Output
%     zef  - uitree filled; hashList = fieldnames(tree); hash used as scratch.
%
%   See also zef_dataBank_refreshTree, zef_dataBank_sortTree, zef_dataBank_rebuildTree.

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
