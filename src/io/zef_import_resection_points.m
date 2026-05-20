% --- Zeffiro documentation header ---
% [zef.file,zef.file_path] = uigetfile({'*.dat;* — [zef.file,zef.file path] = uigetfile({'*.dat;*.
%
% Purpose:
%   [zef.file,zef.file path] = uigetfile({'*.dat;*.
%   Folder: Project load/save, segmentation import, figure import, FEM export.
%
% Zef fields (observed):
%   zef.aux_field_1 (read, write)
%   zef.aux_field_2 (read, write)
%   zef.file (read)
%   zef.file_path (read)
%   zef.resection_points (read, write)
%
% Side effects:
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `[zef.file,zef.file_path] = uigetfile({'*.dat;*` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

[zef.file,zef.file_path] = uigetfile({'*.dat;*.mat'});

if not(isequal(zef.file,0))

    zef.aux_field_1 = load([zef.file_path '/' zef.file]);
    zef.aux_field_2 = [];

    if isstruct(zef.aux_field_1)
        zef.aux_field_2 = fieldnames(zef.aux_field_1);
        zef.resection_points = zef.aux_field_1.(zef.aux_field_2{1});
    else
        zef.resection_points = zef.aux_field_1;
    end

    zef = rmfield(zef,{'aux_field_1','aux_field_2'});

end
