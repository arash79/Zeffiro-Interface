function [tree] = zef_dataBank_delete(tree, parentHash, save2disk)
%ZEF_DATABANK_DELETE  Remove a hash and its children from the tree.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   deleteMenu.MenuSelectedFcn (and deleteMenuData) in zef_open_dataBank:
%   after getHashForMenu, tree = zef_dataBank_delete(tree, hash, save2disk)
%   then refreshTree. Drops parentHash and every field that starts with
%   parentHash_ (so node_1 does not delete node_11). If a node's .data is
%   a matfile object, deletes that file. Then sortTree + rebuildTree so
%   sibling numbers are dense; if save2disk is 'On', rebuildTreeSaveFile
%   renames remaining .mat files.
%
%   tree = zef_dataBank_delete(tree, parentHash, save2disk)
%
%   Inputs
%     tree        - zef.dataBank.tree.
%     parentHash  - char hash to remove (and descendants).
%     save2disk   - 'On' or other; only 'On' rewrites disk names.
%
%   Output
%     tree  - struct with those fields gone and hashes rebuilt.
%
%   See also zef_dataBank_refreshTree, zef_dataBank_rebuildTree.

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
