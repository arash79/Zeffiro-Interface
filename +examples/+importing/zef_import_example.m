function project_struct = zef_import_example
% --- Zeffiro documentation header ---
% examples.importing.project_struct — Example or study script demonstrating project_struct.
%
% Purpose:
%   Example or study script demonstrating project_struct.
%   Folder: Runnable examples and study scripts that exercise meshing, forward lead fields, inverse solvers, importing, and published workflows.
%
% Calls (project):
%   zef_import_example
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `examples.importing.project_struct` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

    project_struct = zeffiro_interface( ...
        'start_mode', 'nodisplay', ...
        'import_to_existing_project', ...
        'scripts/scripts_for_importing/multicompartment_head_project/import_segmentation.zef' ...
    );
end
