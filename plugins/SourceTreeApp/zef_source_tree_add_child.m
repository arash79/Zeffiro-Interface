function zef_source_tree_add_child(treeObj, childText)
%ZEF_SOURCE_TREE_ADD_CHILD  Attach a uitreenode under a parent node or tree.
%
%   zef_source_tree_add_child(treeObj, childText)
%
%   treeObj    - a uitreenode (child of selected parent) or the CheckBoxTree
%                itself (new root).
%   childText  - char or scalar string used as the new node's Text.
%
%   The new node copies NodeData from the parent when that property exists;
%   otherwise it gets zef_init_jr_nodedata(). Does not rebuild
%   zef.source_tree; callers (add-node / add-root buttons) call
%   zef_build_source_tree afterward.
%
%   Error identifiers still use the older name zef_cbtreenode_add_child.
%
%   See also zef_source_tree_addnode_pushed, zef_init_jr_nodedata.

    if nargin ~= 2
        error('zef_cbtreenode_add_child:InvalidInput', ...
              'Provide (CheckBoxTree, childText).');
    end
    if ~(ischar(childText) || (isstring(childText) && isscalar(childText)))
        error('zef_cbtreenode_add_child:InvalidInput', ...
              'childText must be a char or scalar string.');
    end
    childText = char(string(childText));

        parentNode = treeObj;

    newNode = uitreenode(parentNode);
    newNode.Text = childText;
    if isprop(parentNode,'NodeData')
    newNode.NodeData = parentNode.NodeData;
    else
    newNode.NodeData = zef_init_jr_nodedata();
    end

end
