function [h_node_output, node_found] = zef_dataBank_treeSearch(h_node_input, node_name)
%ZEF_DATABANK_TREESEARCH  Find a uitreenode whose Text equals node_name.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Used by zef_dataBank_add_data_item to select a parent before Add.
%   Depth-first over Children; first Text match wins. Empty node_name
%   matches nothing, so SelectedNodes stays empty and Add uses the root.
%
%   [h_node_output, node_found] = zef_dataBank_treeSearch(h_node_input, node_name)
%
%   Inputs
%     h_node_input  - uitree or uitreenode (has .Children).
%     node_name     - char compared with Children(i).Text, or [] .
%
%   Output
%     h_node_output  - matching uitreenode, or [] if none.
%     node_found     - 1 if a match was found, else 0.
%
%   See also zef_dataBank_add_data_item.

node_found = 0;
h_node_output = [];
i = 0;
while i < length(h_node_input.Children) && not(node_found)
    i = i + 1;
    if isequal(h_node_input.Children(i).Text, node_name)
        node_found = 1;
        h_node_output = h_node_input.Children(i);
    else
        [h_node_output, node_found] = zef_dataBank_treeSearch(h_node_input.Children(i),node_name);
    end
end
end
