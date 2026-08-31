%ZEF_WIREFRAME_CREATOR_START  Open Wireframe creator tool (asteroid profiles).
%
%   Copyright © 2019- Sampsa Pursiainen, Liisa-Ida Sorsa, Christelle Eyraud, Jean-Michel Geffrin.
%   GPU-ToRRe-3D wireframe modeling package.
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Asteroid INI callback (Multi tools → Wireframe creator tool;
%   not in multicompartment_head). Constructs zef_wireframe_creator_app.
%   Defaults wireframe_edge_threshold 1.2, printer_resolution 0.15,
%   relative_permittivity 6.5. Create: filling_vec from zef.epsilon via
%   zef_wireframe_filling_vec then wireframe(...) →
%   zef.wireframe_triangles/nodes. Needs tetra, nodes, domain_labels,
%   epsilon.
%
%   See also wireframe, zef_wireframe_plot.

zef_data = zef_wireframe_creator_app;
zef_assign_data;

if not(isfield(zef,'wireframe_edge_threshold'))
    zef.wireframe_edge_threshold = 1.2;
end

if not(isfield(zef,'wireframe_printer_resolution'))
    zef.wireframe_printer_resolution = 0.15;
end

if not(isfield(zef,'wireframe_relative_permittivity'))
    zef.wireframe_relative_permittivity = 6.5;
end

if not(isfield(zef,'wireframe_tolerance'))
    zef.wireframe_tolerance = 0.05;
end

if not(isfield(zef,'wireframe_regularization_parameter'))
    zef.wireframe_regularization_parameter = 0.05;
end

if not(isfield(zef,'wireframe_n_iter'))
    zef.wireframe_n_iter = 1000;
end

zef.h_wireframe_edge_threshold.Value = zef.wireframe_edge_threshold;
zef.h_wireframe_printer_resolution.Value = zef.wireframe_printer_resolution;
zef.h_wireframe_relative_permittivity.Value = zef.wireframe_relative_permittivity;
zef.h_wireframe_regularization_parameter.Value = zef.wireframe_regularization_parameter;
zef.h_wireframe_tolerance.Value = zef.wireframe_tolerance;
zef.h_wireframe_n_iter.Value = zef.wireframe_n_iter;

zef.h_wireframe_create.ButtonPushedFcn = 'zef.wireframe_filling_vec = zef_wireframe_filling_vec(zef.epsilon(:,1),zef.wireframe_relative_permittivity); [zef.wireframe_triangles,zef.wireframe_nodes,zef.wireframe_filling_vec_interp,zef.wireframe_w_vec,zef.wireframe_shape_vec] = wireframe(zef.tetra,zef.nodes,zef.domain_labels,zef.wireframe_filling_vec,zef.wireframe_printer_resolution,0,1,zef.wireframe_edge_threshold);zef.wireframe_permittivity_vec = zef_wireframe_permittivity_vec(zef.wireframe_filling_vec_interp,zef.wireframe_relative_permittivity);';
zef.h_wireframe_plot.ButtonPushedFcn = 'zef_wireframe_plot(zef.wireframe_triangles,zef.wireframe_nodes);';

zef.h_wireframe_creator.Name = 'ZEFFIRO Interface: Wireframe creator tool';

zef.h_wireframe_edge_threshold.ValueChangedFcn = 'zef.wireframe_edge_threshold = zef.h_wireframe_edge_threshold.Value;';
zef.h_wireframe_printer_resolution.ValueChangedFcn = 'zef.wireframe_printer_resolution = zef.h_wireframe_printer_resolution.Value;';
zef.h_wireframe_relative_permittivity.ValueChangedFcn = 'zef.wireframe_relative_permittivity = zef.h_wireframe_relative_permittivity.Value;';
zef.h_wireframe_tolerance.ValueChangedFcn = 'zef.wireframe_tolerance = zef.h_wireframe_tolerance.Value;';
zef.h_wireframe_regularization_parameter.ValueChangedFcn = 'zef.wireframe_regularization_parameter = zef.h_wireframe_regularization_parameter.Value;';
zef.h_wireframe_n_iter.ValueChangedFcn = 'zef.wireframe_n_iter = zef.h_wireframe_n_iter.Value;';

set(findobj(zef.h_wireframe_creator.Children,'-property','FontSize'),'FontSize',zef.font_size);

set(zef.h_wireframe_creator,'AutoResizeChildren','off');
zef.wireframe_creator_current_size = get(zef.h_wireframe_creator,'Position');
set(zef.h_wireframe_creator,'SizeChangedFcn','zef.wireframe_creator_current_size = zef_change_size_function(zef.h_wireframe_creator,zef.wireframe_creator_current_size);');
try
    zef_ui_ready(zef.h_wireframe_creator);
catch
end
