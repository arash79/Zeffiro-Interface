%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% if not(isempty(zef.save_file_path)) & not(zef — If not(isempty(zef.save file path)) & not(zef.
%
% Purpose:
%   If not(isempty(zef.save file path)) & not(zef.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.current_pattern (read, write)
%   zef.file (read)
%   zef.file_path (read)
%   zef.file_type (read, write)
%   zef.h_inv_data_segment (read)
%   zef.imaging_method (read)
%   zef.inv_bg_data (read)
%   zef.inv_import_type (read, write)
%   zef.measurements (read, write)
%   zef.reconstruction (read, write)
%   zef.save_file_path (read)
%
% Side effects:
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: Call `if not(isempty(zef.save_file_path)) & not(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header



if not(isempty(zef.save_file_path)) & not(zef.save_file_path==0)
    [zef.file zef.file_path zef.file_type] = uigetfile({'*.mat','*.dat'},'Import',zef.save_file_path);
else
    [zef.file zef.file_path zef.file_type] = uigetfile({'*.mat','*.dat'},'Import');
end
if zef.inv_import_type == 1;
    if not(isequal(zef.file,0));
        if zef.file_type == 1
            [zef.measurements] = struct2cell(load([zef.file_path zef.file]));
            zef.measurements = zef.measurements{1};
        else
            [zef.measurements] = load([zef.file_path zef.file]);
        end
        if iscell(zef.measurements)
            if isfield(zef,'h_inv_data_segment')
                if ishandle(zef.h_inv_data_segment)
                    set(zef.h_inv_data_segment,'enable','on');
                end
            end
            if ismember(zef.imaging_method,[4])
                for cell_ind_aux = 1 : length(zef.measurements)
                    zef.measurements{cell_ind_aux} = zef.measurements{cell_ind_aux} - zef.inv_bg_data;
                end
            end
        end
        if not(iscell(zef.measurements))
            if isfield(zef,'h_inv_data_segment')
                if ishandle(zef.h_inv_data_segment)
                    set(zef.h_inv_data_segment,'enable','off');
                end
            end
            if ismember(zef.imaging_method,[4])
                zef.measurements = zef.measurements - zef.inv_bg_data;
            end
        end
    end
end
if zef.inv_import_type == 2;
    if not(isequal(zef.file,0));
        if zef.file_type == 1
            [zef.reconstruction] = struct2cell(load([zef.file_path zef.file]));
            zef.reconstruction = zef.reconstruction{1};
        else
            [zef.reconstruction] = load([zef.file_path zef.file]);
        end
    end
end
if zef.inv_import_type == 3;
    if not(isequal(zef.file,0));
        if zef.file_type == 1
            [zef.current_pattern] = struct2cell(load([zef.file_path zef.file]));
            zef.current_pattern = zef.current_pattern{1};
        else
            [zef.current_pattern] = load([zef.file_path zef.file]);
        end
    end
end
