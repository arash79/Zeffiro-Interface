% --- Zeffiro documentation header ---
% function zef_plot_graph — Function zef plot graph.
%
% Purpose:
%   Function zef plot graph.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.mesh_visualization_graph_list (read)
%   zef.mesh_visualization_graph_selected (read)
%   zef.mesh_visualization_parameter_selected (read)
%
% Calls (project):
%   zef_get_profile_parameters
%   zef_plot_graph
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `function zef_plot_graph` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header
function zef_plot_graph


zef = evalin('base','zef');
g_list = eval('zef.mesh_visualization_graph_list');
g_ind = eval('zef.mesh_visualization_graph_selected');
p_ind =  eval('zef.mesh_visualization_parameter_selected');
[~,v_name] = zef_get_profile_parameters(zef,p_ind);

eval([g_list{2}{g_ind} '(' v_name ');']);

end
