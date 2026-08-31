function zef_source_tree_addnode_pushed(~, ~, ~)
%ZEF_SOURCE_TREE_ADDNODE_PUSHED  Add a child under the selected tree node.
%
%   App callback. Reads zef from base, requires a selection, calls
%   zef_source_tree_add_child(..., 'NewNode'), rebuilds zef.source_tree,
%   and assignin('base','zef',zef). Alerts if nothing is selected.
%
%   See also zef_source_tree_add_child, zef_build_source_tree.
zef = evalin('base','zef');

    selected_node = zef_source_tree_get_selected(zef.h_source_tree.SourceTree);
    if isempty(selected_node)
        uialert(ancestor(zef.h_source_tree.SourceTree,'figure'), ...
            'Select a node first (the parent for the new child).', ...
            'No selection');
        return;
    end

    % Add child (your existing function should create/attach the UI node)
    zef_source_tree_add_child(selected_node, 'NewNode');

        zef.source_tree = zef_build_source_tree(zef.h_source_tree.SourceTree);


    % If you want the base-workspace zef to reflect the change immediately
    assignin('base','zef', zef);
end