function zef_plot_graph
%ZEF_PLOT_GRAPH  Mesh visualization → **Plot graph**.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Function. ButtonPushedFcn of h_plot_graph (Text='Plot graph').
%   feval mesh_visualization_graph_list{2}{graph_selected} on the
%   profile parameter named by mesh_visualization_parameter_selected.
%   The graph tool draws on zef.h_axes1. Does not process meshes.
%
%   See also zef_mesh_visualization_tool, zef_get_profile_parameters.


zef = evalin('base','zef');
g_list = eval('zef.mesh_visualization_graph_list');
g_ind = eval('zef.mesh_visualization_graph_selected');
p_ind =  eval('zef.mesh_visualization_parameter_selected');
[~,v_name] = zef_get_profile_parameters(zef,p_ind);

eval([g_list{2}{g_ind} '(' v_name ');']);

end
