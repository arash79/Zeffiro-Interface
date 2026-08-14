function zef = zef_import_mat_struct(zef,varargin)
%ZEF_IMPORT_MAT_STRUCT  Merge variables from a MAT file into zef.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Loads a MAT file (uigetfile when path not given in varargin{1}),
%   optionally derives surface_triangles from tetra via zef_surface_mesh,
%   optionally prefixes all field names with varargin{2}, and copies each
%   loaded variable onto zef.
%
%   zef = zef_import_mat_struct(zef)
%   zef = zef_import_mat_struct(zef, file_path)
%   zef = zef_import_mat_struct(zef, file_path, extension_prefix)
%
%   Inputs
%     zef             - session struct.
%     file_path       - optional full or relative path to *.fig dialog
%                       filter (legacy) or MAT file path.
%     extension_prefix - optional string prepended to each imported field
%                        name (e.g. compartment tag plus underscore).
%
%   Output
%     zef - session with imported fields merged in.
%
%   See also zef_import_segmentation, zef_surface_mesh.

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
