function zef = zef_save(zef,file_name,path_name,save_switch)
%ZEF_SAVE  Save project data or export selected Zeffiro fields to disk.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Dispatches on zef.save_switch (menu wiring in zef_menu_tool):
%     1  Project → Save as...          full project
%     2  Export → Export lead field    L
%     3  Export → Export source space  source_positions, source_directions
%     4  Export → Export sensors       <current_sensors>_points/_directions
%     5  Export → Export segmentation data
%     6  Export → Export volume data
%     7  Project → Save                overwrite path, else Save as...
%     8  Export → Export reconstruction
%     9  Project → Save figures as...
%    10  Project → Print figure to file as...
%   Project saves strip handles, close tools/figs, then reopen mesh tools.
%
%   zef = zef_save(zef)
%   zef = zef_save(zef, file_name, path_name)
%   zef = zef_save(zef, file_name, path_name, save_switch)
%
%   Inputs
%     zef          - session struct; uses zef.save_switch when save_switch
%                    is omitted (default 1 for three-argument calls).
%     file_name    - optional output file name (no dialog when given with
%                    path_name).
%     path_name    - optional folder for file_name.
%     save_switch  - integer mode selector (1–10); see body for exported
%                    field subsets per mode.
%
%   Output
%     zef - updated session with file, file_path, save_file, and
%           save_file_path set after a successful save dialog or path.
%
%   See also zef_load, zef_remove_object_handles, zef_process_meshes,
%            zef_attach_sensors_volume.
%
if nargin == 0
    zef = evalin('base','zef');
end

if nargin == 3
    zef.save_switch = 1;
elseif nargin == 4
    zef.save_switch = save_switch;
end

if zef.save_switch == 1

    if nargin < 3
        if zef.use_display
            if not(isempty(zef.save_file_path)) & not(zef.save_file_path==0)
                [zef.file zef.file_path] = uiputfile('*.mat','Save as...',[zef.save_file_path filesep zef.save_file]);
            else
                [zef.file zef.file_path] = uiputfile('*.mat','Save as...');
            end
        end
    else
        zef.file = file_name;
        zef.file_path = path_name;
    end
    if not(isequal(zef.file,0))
        zef.save_file = zef.file;
        zef.save_file_path = zef.file_path;
        zef_close_tools;
        if ~local_unified_shell(zef)
            zef_close_figs;
        end

        if isfield(zef,'zeffiro_variable_data')
            if not(isempty(zef.zeffiro_variable_data))
                time_val = now;
                I = ismember(zef.zeffiro_variable_data(:,2),fieldnames(zef));
                zef.zeffiro_variable_data(I,5) = {time_val};
            end
        end

        zef_data = zef;
        zef_data = zef_remove_object_handles(zef_data);
        zef_data = zef_remove_system_fields(zef, zef_data);
        save([zef.save_file_path filesep zef.save_file],'-struct','zef_data','-v7.3');
        clear zef_data;
        if ~local_unified_shell(zef)
            zef_segmentation_tool;
            zef_mesh_tool;
            zef_mesh_visualization_tool;
            zef = zef_update(zef);
        end
        try
            zef_ui_shell('hide_companions', zef);
        catch
        end
    end
end
if zef.save_switch == 2
    if zef.use_display
        if not(isempty(zef.save_file_path)) & not(zef.save_file_path==0)
            [zef.file zef.file_path zef.file_index] = uiputfile({'*.mat';'*.dat'},'Export lead field',zef.save_file_path);
        else
            [zef.file zef.file_path zef.file_index] = uiputfile({'*.mat'},'Export lead field');
        end
    end
    if not(isequal(zef.file,0));
        save([zef.file_path filesep zef.file],'-struct','zef','L','-v7.3');
    end
end
if zef.save_switch == 3
    if zef.use_display
        if not(isempty(zef.save_file_path)) & not(zef.save_file_path==0)
            [zef.file zef.file_path zef.file_index] = uiputfile({'*.mat'},'Export source space',zef.save_file_path);
        else
            [zef.file zef.file_path zef.file_index] = uiputfile({'*.mat'},'Export source space');
        end
    end
    if not(isequal(zef.file,0));
        save([zef.file_path filesep zef.file],'-struct','zef','source_positions','source_directions','-v7.3');
    end
end
if zef.save_switch == 4
    if zef.use_display
        if not(isempty(zef.save_file_path)) & not(zef.save_file_path==0)
            [zef.file zef.file_path zef.file_index] = uiputfile({'*.mat'},'Export sensors',zef.save_file_path);
        else
            [zef.file zef.file_path zef.file_index] = uiputfile({'*.mat'},'Export sensors');
        end
    end
    if not(isequal(zef.file,0));
        save([zef.file_path filesep zef.file],'-struct','zef',[zef.current_sensors '_points'],[zef.current_sensors '_directions'],'-v7.3');
    end
end
if zef.save_switch == 5
    if zef.use_display
        if not(isempty(zef.save_file_path)) & not(zef.save_file_path==0)
            [zef.file zef.file_path zef.file_index] = uiputfile({'*.mat'},'Export segmentation data',zef.save_file_path);
        else
            [zef.file zef.file_path zef.file_index] = uiputfile({'*.mat'},'Export segmentation data');
        end
    end
    if not(isequal(zef.file,0));
        zef = zef_process_meshes(zef);
        zef.surface_mesh_nodes = zef.reuna_p;
        zef.surface_mesh_triangles = zef.reuna_t;
        if zef.imaging_method== 1
            zef.sensors_attached_surface = zef.sensors;
            for zef_i = 1 : size(zef.sensors,1)
                [zef.min_val, zef.min_ind] = min(sqrt(sum((zef.surface_mesh_nodes{end} - repmat(zef.sensors(zef_i,1:3),size(zef.surface_mesh_nodes{end},1),1)).^2,2)));
                zef.sensors_attached_surface(zef_i,1:3) = zef.surface_mesh_nodes{end}(zef.min_ind,:);
            end
            clear zef_i;
            save([zef.file_path filesep zef.file],'-struct','zef','sensors','surface_mesh_nodes','surface_mesh_triangles','sensors_attached_surface','-v7.3');
            zef = rmfield(zef,{'min_val','min_ind','sensors_attached_surface'});
        else
            save([zef.file_path filesep zef.file],'-struct','zef','sensors','surface_mesh_nodes','surface_mesh_triangles');
            zef = rmfield(zef,{'surface_mesh_nodes','surface_mesh_triangles'});
        end
    end
end
if zef.save_switch == 6
    if zef.use_display
        if not(isempty(zef.save_file_path)) & not(zef.save_file_path==0)
            [zef.file zef.file_path zef.file_index] = uiputfile({'*.mat'},'Export volume data',zef.save_file_path);
        else
            [zef.file zef.file_path zef.file_index] = uiputfile({'*.mat'},'Export volume data');
        end
    end
    if not(isequal(zef.file,0));
        zef = zef_process_meshes(zef);
        zef.tetrahedra = zef.tetra;
        if zef.imaging_method== 1
            [zef.sensors_attached_volume] = zef_attach_sensors_volume([]);
            save([zef.file_path filesep zef.file],'-struct','zef','sensors','nodes','tetrahedra','prisms','surface_triangles','sigma','sigma_prisms','sensors_attached_volume','brain_ind','-v7.3');
            zef = rmfield(zef,{'sensors_attached_volume','tetrahedra'});
        else
            save([zef.file_path filesep zef.file],'-struct','zef','sensors','nodes','tetrahedra','surface_triangles','sigma','-v7.3');
            zef = rmfield(zef,'tetrahedra');
        end
    end
end
if zef.save_switch == 7
    if not(isempty(zef.save_file)) & not(isempty(zef.save_file_path)) & not(zef.save_file_path==0) & not(isequal(zef.save_file,'default_project.mat'))
        zef_close_tools;
        if ~local_unified_shell(zef)
            zef_close_figs;
        end
        zef_data = zef;
        zef_data = zef_remove_object_handles(zef_data);
        zef_data = zef_remove_system_fields(zef, zef_data);
        save([zef.save_file_path filesep zef.save_file],'-struct','zef_data','-v7.3');
        clear zef_data;
        if ~local_unified_shell(zef)
            zef_mesh_tool;
            zef_mesh_visualization_tool
            zef_update;
        end
        try
            zef_ui_shell('hide_companions', zef);
        catch
        end
    else
        if zef.use_display
            if not(isempty(zef.save_file_path)) & not(zef.save_file_path==0)
                [zef.file zef.file_path] = uiputfile('*.mat','Save as...',[zef.save_file_path filesep zef.save_file]);
            else
                [zef.file zef.file_path] = uiputfile('*.mat','Save as...');
            end
        end
        if not(isequal(zef.file,0));
            zef.save_file = zef.file;
            zef.save_file_path = zef.file_path;
            zef_close_tools;
            if ~local_unified_shell(zef)
                zef_close_figs;
            end
            zef_data = zef;
            zef_data = zef_remove_object_handles(zef_data);
            zef_data = zef_remove_system_fields(zef, zef_data);
            save([zef.save_file_path filesep zef.save_file],'-struct','zef_data','-v7.3');
            clear zef_data;
        end
    end
end
if zef.save_switch == 8
    if zef.use_display
        if not(isempty(zef.save_file_path)) & not(zef.save_file_path==0)
            [zef.file zef.file_path zef.file_index] = uiputfile({'*.mat';'*.dat'},'Export reconstruction',zef.save_file_path);
        else
            [zef.file zef.file_path zef.file_index] = uiputfile({'*.mat';'*.dat'},'Export reconstruction');
        end
    end
    if not(isequal(zef.file,0));
        if zef.file_index == 1
            save([zef.file_path filesep zef.file],'-struct','zef','reconstruction','-v7.3');
        else
            save([zef.file_path filesep zef.file],'-struct','zef','reconstruction','-ascii');
        end
    end
end
if zef.save_switch == 9
    if zef.use_display
        [zef.file zef.file_path zef.file_index] = uiputfile({'*.fig'},'Save figures as...',zef.save_file_path);
    end
    if not(isequal(zef.file,0));
        zef.h_fig_aux = findall(groot, 'Type','figure','-regexp','Name','ZEFFIRO Interface: Figure tool*');
        savefig(zef.h_fig_aux,[zef.save_file_path zef.file]);
        rmfield(zef,'h_fig_aux');
    end;
end;
if zef.save_switch == 10
    if zef.use_display
        [zef.file zef.file_path zef.file_index] = uiputfile({'*.png';'*.jpg';'*.tiff'},'Print figure to file as...',zef.save_file_path);
    end
    if not(isequal(zef.file,0));
        if zef.file_index == 1
            print(gcf,'-dpng','-r200',[zef.file_path zef.file]);
        end
        if zef.file_index == 2
            print(gcf,['-djpeg' num2str(zef.video_codec)],'-r200',[zef.save_file_path zef.file]);
        end
        if zef.file_index == 3
            print(gcf,'-dtiff','-r200',[zef.file_path zef.file]);
        end
    end;
end;

if nargout == 0
    assignin('base','zef',zef);
end

end

function tf = local_unified_shell(zef)

tf = false;
try
    tf = isstruct(zef) && isfield(zef, 'h_zeffiro') && isvalid(zef.h_zeffiro) ...
        && zef_ui_is_unified(zef.h_zeffiro);
catch
end

end
