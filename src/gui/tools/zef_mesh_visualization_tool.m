%ZEF_MESH_VISUALIZATION_TOOL  Open Mesh visualization tool; wire plot/camera controls.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script (not a function). Instantiates zef_mesh_visualization_tool_app_exported.
%   Every ValueChangedFcn is zef_update_mesh_visualization_tool.
%   Buttons (App Designer Text=): Visualize volume, Visualize surfaces,
%   Frame / Movie, Axes pop-up, Plot graph, Visualize DTI streamlines.
%   Visualization type items: Domain labels, Distribution (volume/surface),
%   Parcellation, Topography.
%
%   See also zef_visualize_volume, zef_plot_volume.
if isfield(zef,'h_mesh_visualization_tool')
    if isvalid(zef.h_mesh_visualization_tool)
        delete(zef.h_mesh_visualization_tool)
    end
end

zef_data = zef_mesh_visualization_tool_app_exported;
%zef_data.h_mesh_visualization_tool.Visible = zef.use_display;

zef.fieldnames = fieldnames(zef_data);
for zef_i = 1:length(zef.fieldnames)
    zef.(zef.fieldnames{zef_i}) = zef_data.(zef.fieldnames{zef_i});
    if isprop(zef.(zef.fieldnames{zef_i}),'ValueChangedFcn')
        set(zef.(zef.fieldnames{zef_i}),'ValueChangedFcn','zef_update_mesh_visualization_tool;');
    end
end

%*******

set(zef.h_plot_graph,'ButtonPushedFcn','zef_plot_graph;');
set(zef.h_pushbutton31,'ButtonPushedFcn','zef_visualize_volume;');
set(zef.h_pushbutton20,'ButtonPushedFcn','zef_visualize_surfaces;');
set(zef.h_pushbutton22,'ButtonPushedFcn','zef_snapshot_movie;');
set(zef.h_axes_popup,'ButtonPushedFcn','zef_axes_popup;');
set(zef.h_pushbutton_dti_streamlines,'ButtonPushedFcn','zef_visualize_dti_streamlines;');

set(zef.h_checkbox14,'value',zef.attach_electrodes);
set(zef.h_checkbox15,'value',zef.axes_visible);
set(zef.h_edit80,'value',zef.azimuth);
set(zef.h_edit81,'value',zef.elevation);
set(zef.h_edit82,'value',zef.cam_va);
set(zef.h_cone_draw,'value',zef.cone_draw);
set(zef.h_streamline_draw,'value',zef.streamline_draw);
set(zef.h_show_contour,'value',zef.show_contour);
set(zef.h_show_contour_text,'value',zef.show_contour_text);
set(zef.h_contour_set_text,'value',zef.contour_set_text);
zef.contour_set = str2num(zef.contour_set_text);

set(zef.h_mesh_visualization_parameter_list,'Items',zef_get_profile_parameters(zef));
zef.h_mesh_visualization_parameter_list.ItemsData = [1:length(zef.h_mesh_visualization_parameter_list.Items)];

zef.mesh_visualization_parameter_selected = 1;
set(zef.h_mesh_visualization_parameter_list,'value',zef.mesh_visualization_parameter_selected);

zef.mesh_visualization_graph_list = cell(0);
zef.dir_aux = dir(fileparts(which('zef_histogram')));
zef_i_graph = 0;
for zef_i = 1 : length(zef.dir_aux)
    zef_name_aux = zef.dir_aux(zef_i).name;
    [~, zef_fn_aux, zef_ext_aux] = fileparts(zef_name_aux);
    if ~strcmpi(zef_ext_aux, '.m') || startsWith(zef_fn_aux, '.') || strcmpi(zef_fn_aux, 'contents')
        continue
    end
    zef_i_graph = zef_i_graph + 1;
    zef_label_aux = strrep(zef_fn_aux, '_', ' ');
    if strncmpi(zef_label_aux, 'zef ', 4)
        zef_label_aux = strtrim(zef_label_aux(5:end));
    end
    if ~isempty(zef_label_aux)
        zef_label_aux(1) = upper(zef_label_aux(1));
    end
    zef.mesh_visualization_graph_list{1}{zef_i_graph} = zef_label_aux;
    zef.mesh_visualization_graph_list{2}{zef_i_graph} = zef_fn_aux;
end
if zef_i_graph < 1
    zef.mesh_visualization_graph_list{1} = {'(none)'};
    zef.mesh_visualization_graph_list{2} = {''};
end

set(zef.h_mesh_visualization_graph_list,'Items',zef.mesh_visualization_graph_list{1});
zef.h_mesh_visualization_graph_list.ItemsData = [1:length(zef.h_mesh_visualization_graph_list.Items)];

if not(isfield(zef,'mesh_visualization_graph_selected'))
    zef.mesh_visualization_graph_selected = 1;
end
set(zef.h_mesh_visualization_graph_list,'value',zef.mesh_visualization_graph_selected);

set(zef.h_visualization_type,'Items',{'Domain labels','Distribution (volume)','Distribution (surface)','Parcellation','Topography'});
zef.h_visualization_type.ItemsData = [1:length(zef.h_visualization_type.Items)];
set(zef.h_visualization_type,'Value',zef.visualization_type);

set(zef.h_volumetric_distribution_mode,'Items',{'Reconstruction','Parameter real','Parameter imaginary'});
zef.h_volumetric_distribution_mode.ItemsData = [1:length(zef.h_volumetric_distribution_mode.Items)];
set(zef.h_volumetric_distribution_mode,'Value',zef.volumetric_distribution_mode);

set(zef.h_frame_start,'value',num2str(zef.frame_start));
set(zef.h_frame_stop,'value',num2str(zef.frame_stop));
set(zef.h_frame_step,'value',num2str(zef.frame_step));
set(zef.h_orbit,'value',num2str(zef.orbit_1));
set(zef.h_orbit_2,'value',num2str(zef.orbit_2));
set(zef.h_cp2_on,'value',zef.cp2_on);
set(zef.h_cp2_a,'value',num2str(zef.cp2_a));
set(zef.h_cp2_b,'value',num2str(zef.cp2_b));
set(zef.h_cp2_c,'value',num2str(zef.cp2_c));
set(zef.h_cp2_d,'value',num2str(zef.cp2_d));
set(zef.h_cp3_on,'value',zef.cp3_on);
set(zef.h_cp3_a,'value',num2str(zef.cp3_a));
set(zef.h_cp3_b,'value',num2str(zef.cp3_b));
set(zef.h_cp3_c,'value',num2str(zef.cp3_c));
set(zef.h_cp3_d,'value',num2str(zef.cp3_d));
set(zef.h_layer_transparency,'value',num2str(1 - zef.layer_transparency));
set(zef.h_use_inflated_surfaces,'value',zef.use_inflated_surfaces);
set(zef.h_explode_everything,'value',zef.explode_everything);

set(zef.h_reconstruction_type,'Items',{'Amplitude','Normal','Tangential','Normal constraint (-)','Normal constraint (+)','Value','Amplitude smoothed'});
zef.h_reconstruction_type.ItemsData = [1:length(zef.h_reconstruction_type.Items)];
set(zef.h_reconstruction_type,'Value',zef.reconstruction_type);

set(zef.h_checkbox_cp_on,'value',zef.cp_on);
set(zef.h_edit_cp_a,'value',num2str(zef.cp_a));
set(zef.h_edit_cp_b,'value',num2str(zef.cp_b));
set(zef.h_edit_cp_c,'value',num2str(zef.cp_c));
set(zef.h_edit_cp_d,'value',num2str(zef.cp_d));

set(zef.h_inv_scale,'Items',{'Logarithmic','Linear','Square root'});
zef.h_inv_scale.ItemsData = [1:length(zef.h_inv_scale.Items)];
set(zef.h_inv_scale,'Value',zef.inv_scale);

zef.h_inv_colormap = zef_data.h_inv_colormap;

set(zef.h_inv_colormap,'Items',zef.colormap_items);
zef.h_inv_colormap.ItemsData = [1:length(zef.h_inv_colormap.Items)];
set(zef.h_inv_colormap,'Value',zef.inv_colormap);

set(zef.h_cp_mode,'Items',{'Cut out','Cut in','Cut out & whole brain','Cut in & whole brain'});
zef.h_cp_mode.ItemsData = [1:length(zef.h_cp_mode.Items)];
set(zef.h_cp_mode,'Value',zef.cp_mode);

set(zef.h_brain_transparency,'value',num2str(1 - zef.brain_transparency));

set(zef.h_inv_dynamic_range,'value',num2str(1./zef.inv_dynamic_range));

set(zef.h_submesh_num,'value',num2str(zef.submesh_num));

zef.h_mesh_visualization_tool.Units = 'normalized';
zef.h_mesh_visualization_tool.Position = [0.3 0.3 zef.h_mesh_visualization_tool.Position(3:4)];
zef.h_mesh_visualization_tool.Units = 'pixels';

zef = zef_ui_tag_handles(zef);

clear zef_data;

% if zef.h_segmentation_tool_toggle == 1
% 
%     zef.h_mesh_visualization_tool.Position = [zef.segmentation_tool_default_position(1) + 1.75*0.505*zef.segmentation_tool_default_position(3), ...
%         zef.segmentation_tool_default_position(2),...
%         0.5*0.505*zef.segmentation_tool_default_position(3),...
%         zef.segmentation_tool_default_position(4)];
% 
% else
% 
%     zef.h_mesh_visualization_tool.Position = [zef.segmentation_tool_default_position(1) + 1.75*zef.segmentation_tool_default_position(3), ...
%         zef.segmentation_tool_default_position(2),...
%         0.5*zef.segmentation_tool_default_position(3),...
%         zef.segmentation_tool_default_position(4)];
% 
% end

ref = zef.segmentation_tool_default_position;
zef.h_mesh_visualization_tool.Position = [ref(1) + ref(3) - 680, ref(2) + ref(4) - 600, 680, 600];
zef_window_manager('standalone', zef.h_mesh_visualization_tool);
zef_ui_apply_size(zef.h_mesh_visualization_tool, 700, 620, 640, 580);
try
    zef.h_mesh_visualization_tool.Scrollable = 'off';
catch
end
zef_ui_ready(zef.h_mesh_visualization_tool);

set(zef.h_mesh_visualization_tool,'DeleteFcn','zef_closereq;');

if not(ismember('ZefTool',properties(zef.h_mesh_visualization_tool)))
    addprop(zef.h_mesh_visualization_tool,'ZefTool');
end
zef.h_mesh_visualization_tool.ZefTool = mfilename;

zef.h_mesh_visualization_tool.CloseRequestFcn = 'zef.h_mesh_visualization_tool.Visible=''off'';';
zef.h_mesh_visualization_tool.DeleteFcn = 'zef.h_mesh_visualization_tool.Visible=''off'';';
