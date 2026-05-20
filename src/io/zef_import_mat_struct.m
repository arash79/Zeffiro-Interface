function zef = zef_import_mat_struct(zef,varargin)
% --- Zeffiro documentation header ---
% zef_import_mat_struct — Loads external data or a saved Zeffiro project into `zef`.
%
% Purpose:
%   Loads external data or a saved Zeffiro project into `zef`.
%   Folder: Project load/save, segmentation import, figure import, FEM export.
%
% Inputs:
%   zef
%   varargin
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.save_file_path (read)
%
% Calls (project):
%   zef_import_mat_struct
%   zef_surface_mesh
%
% Side effects:
%   - base/caller workspace
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: `[zef] = zef_import_mat_struct(zef, varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header


mat_struct = [];
extension = [];

if not(isempty(varargin))
    if not(isempty(varargin{1}))
        [folder_name, file_name_1,file_name_2] = fileparts(varargin{1});
        file_name = [file_name_1 file_name_2];
    end
    if length(varargin) > 1
        extension = varargin{2};
    end
end

if isempty(file_name)

    [file_name folder_name] = uigetfile({'*.fig'},'Import MAT struct',evalin('base','zef.save_file_path'));

end

if not(isequal(file_name,0))

    mat_struct = load(fullfile(folder_name, file_name));

end



if isfield(mat_struct,'tetra')
    [mat_struct.surface_triangles] = zef_surface_mesh(mat_struct.tetra);
    [mat_struct.tetra_aux] = mat_struct.tetra;
end

if isfield(mat_struct,'nodes')
    [mat_struct.nodes_aux] = mat_struct.nodes;
end


if not(isempty(extension))
    mat_struct_aux = cell(0);
    fieldnames_cell = fieldnames(mat_struct);
    for i = 1 : length(fieldnames_cell)
        eval(['mat_struct_aux.' extension fieldnames_cell{i} '=' 'mat_struct.' fieldnames_cell{i} ';'])
    end
    mat_struct = mat_struct_aux;
end

fieldnames_cell = fieldnames(mat_struct);

for i = 1 : length(fieldnames_cell)
    zef.(fieldnames_cell{i}) = mat_struct.(fieldnames_cell{i});
end

if nargout == 0
    assignin('base','zef', zef);
end



end
