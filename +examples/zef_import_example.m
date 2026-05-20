function project_struct = zef_import_example
%
% examples.zef_import_example
%
% Demonstrates programmatic import of a segmentation into Zeffiro Interface
% without launching the graphical user interface. Creates a project from an
% existing import segmentation script (typically a multi-compartment head
% model) and returns the project struct for further processing.
%
% Returns:
%   project_struct  Struct containing the imported project data
%
    project_struct = zeffiro_interface( ...
        'start_mode', 'nodisplay', ...
        'import_to_existing_project', ...
        'scripts/scripts_for_importing/multicompartment_head_project/import_segmentation.zef' ...
    );
end
