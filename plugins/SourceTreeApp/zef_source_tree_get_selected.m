function selected_node = zef_source_tree_get_selected(treeObj)
%ZEF_SOURCE_TREE_GET_SELECTED  First selected uitreenode of the source tree.
%
%   selected_node = zef_source_tree_get_selected(treeObj)
%
%   treeObj is zef.h_source_tree.SourceTree. Errors if SelectedNodes is
%   empty (error id still uses the older name zef_cbtreenode_add_child).
%   Multi-select: only sel(1) is returned.
%
%   See also zef_source_tree_addnode_pushed, zef_source_tree_deletenode_pushed.

sel = treeObj.SelectedNodes;
    if isempty(sel)
        error('zef_cbtreenode_add_child:NoSelection', ...
              'SelectedNodes is empty. Select a parent node first.');
    end

    selected_node = sel(1);

end