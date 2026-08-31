function project_struct = zef_import_example
%ZEF_IMPORT_EXAMPLE  Nodisplay import of the bundled head segmentation.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   project_struct = zef_import_example()
%
%   zeffiro_interface start_mode nodisplay, import_to_existing_project
%   data/segmentations/multicompartment_head_project/import_segmentation.zef.
%   No meshing.
%

project_struct = zeffiro_interface( ...
        'start_mode', 'nodisplay', ...
        'import_to_existing_project', ...
        fullfile("data", "segmentations", "multicompartment_head_project", "import_segmentation.zef") ...
    );
end
