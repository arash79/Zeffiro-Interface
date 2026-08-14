function [] = zef_dataBank_uiTreeDeleteHash(node, hashList)
%ZEF_DATABANK_UITREEDELETEHASH  Delete uitree nodes whose NodeData is in hashList.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Widget-side delete when hashes are known but the nodes are not the
%   current selection. Walks Children (root or a subtree) and deletes a
%   node whose NodeData equals an entry of hashList. Recurses remaining
%   children in reverse so sibling indices stay valid. Not used by
%   zef_open_dataBank (delete + refreshTree rebuilds the uitree instead).
%   Commented-out in analysis scripts such as dataBank_delete_x.
%
%   zef_dataBank_uiTreeDeleteHash(node, hashList)
%
%   Inputs
%     node      - uitree or uitreenode (must have Children; NodeData optional).
%     hashList  - cellstr of hashes to remove.
%
%   See also zef_dataBank_delete, zef_dataBank_refreshTree.

% Deleting uitree nodes when the hash is known but the nodes are not selected.
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
