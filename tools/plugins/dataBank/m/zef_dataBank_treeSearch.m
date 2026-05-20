function [h_node_output, node_found] = zef_dataBank_treeSearch(h_node_input, node_name)
% --- Zeffiro documentation header ---
% zef_dataBank_treeSearch — Zef data Bank tree Search.
%
% Purpose:
%   Zef data Bank tree Search.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   h_node_input
%   node_name
%
% Outputs:
%   h_node_output
%   node_found
%
% Calls (project):
%   zef_dataBank_treeSearch
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[h_node_output, node_found]] = zef_dataBank_treeSearch(h_node_input, node_name)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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
