% --- Zeffiro documentation header ---
% zef_data = zef_wireframe_creator_app; — Zef data = zef wireframe creator app;.
%
% Purpose:
%   Zef data = zef wireframe creator app;.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.domain_labels (read)
%   zef.epsilon (read)
%   zef.font_size (read)
%   zef.h_wireframe_create (read)
%   zef.h_wireframe_creator (read)
%   zef.h_wireframe_edge_threshold (read)
%   zef.h_wireframe_n_iter (read)
%   zef.h_wireframe_plot (read)
%   zef.h_wireframe_printer_resolution (read)
%   zef.h_wireframe_regularization_parameter (read)
%   zef.h_wireframe_relative_permittivity (read)
%   zef.h_wireframe_tolerance (read)
%   zef.nodes (read)
%   zef.tetra (read)
%   zef.wireframe_creator_current_size (read, write)
%   … (13 more)
%
% Calls (project):
%   zef_change_size_function
%   zef_wireframe_filling_vec
%   zef_wireframe_permittivity_vec
%   zef_wireframe_plot
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: Call `zef_data = zef_wireframe_creator_app;` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

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
