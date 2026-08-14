function zef_export_fem_mesh_as(zef)
%ZEF_EXPORT_FEM_MESH_AS  Export volume FEM mesh arrays to a MAT file.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Prompts with uiputfile when zef.use_display is true, otherwise uses
%   zef.file and zef.file_path, and saves nodes, tetra, domain_labels, and
%   name_tags from the current session.
%
%   zef_export_fem_mesh_as(zef)
%
%   Input
%     zef - session struct with tetrahedral mesh fields populated.
%
%   See also zef_save, zef_import_segmentation.

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
