function zef_export_fem_mesh_as(zef)
% --- Zeffiro documentation header ---
% zef_export_fem_mesh_as — Writes project, mesh, or reconstruction data to disk.
%
% Purpose:
%   Writes project, mesh, or reconstruction data to disk.
%   Folder: Project load/save, segmentation import, figure import, FEM export.
%
% Inputs:
%   zef
%
% Outputs:
%   See function signature and code below.
%
% Zef fields (observed):
%   zef.domain_labels (read)
%   zef.file (read)
%   zef.file_path (read)
%   zef.name_tags (read)
%   zef.nodes (read)
%   zef.save_file_path (read)
%   zef.tetra (read)
%   zef.use_display (read)
%
% Calls (project):
%   zef_export_fem_mesh_as
%
% Side effects:
%   - base/caller workspace
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: `zef_export_fem_mesh_as(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef');
end

if eval('zef.use_display')
    [file path] = uiputfile('*.mat','Export FEM mesh as...',eval('zef.save_file_path'));
else
    file = eval('zef.file');
    path = eval('zef.file_path');
end

if not(isequal(file,0))

    tetra = eval('zef.tetra');
    nodes = eval('zef.nodes');
    domain_labels = eval('zef.domain_labels');
    name_tags = eval('zef.name_tags');
    save([path '/' file],'-v7.3','nodes','tetra','domain_labels','name_tags');


end
