function zef = zeffiro_interface(args)
% --- Zeffiro documentation header ---
% zeffiro_interface — Zeffiro interface.
%
% Purpose:
%   Zeffiro interface.
%   Folder: Repository root: startup (`zeffiro_interface`, `zeffiro_setup`), path configuration, and entry to `src/`, `+core`, `+inverse`, `+utilities`, `tools/plugins`, and bundled data.
%
% Inputs:
%   args
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.cluster_path (read, write)
%   zef.code_path (read, write)
%   zef.data_path (read, write)
%   zef.external_path (read, write)
%   zef.file (read, write)
%   zef.file_path (read, write)
%   zef.gpu_count (read, write)
%   zef.gpu_num (read)
%   zef.h_mesh_tool (read)
%   zef.h_mesh_visualization_tool (read)
%   zef.h_zeffiro (read)
%   zef.h_zeffiro_menu (read)
%   zef.h_zeffiro_window_main (read)
%   zef.new_empty_project (read, write)
%   zef.program_path (read, write)
%   … (7 more)
%
% Calls (project):
%   utilities.structs.copy_fields
%   zef_build_compartment_table
%   zef_close_all
%   zef_export_fem_mesh_as
%   zef_import_figure
%   zef_import_segmentation
%   zef_load
%   zef_save
%   zef_start
%   zef_start_log
%
% Side effects:
%   - GPU
%   - base/caller workspace
%   - parallel/cluster
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Primary startup: paths, `zef` struct, optional CLI import/save/export.
%   Programmatic: `[zef] = zeffiro_interface(args)` with project root and `src` on the path.
% --- End Zeffiro documentation header

arguments

    args.zeffiro_restart (1,1) logical = false;

    args.start_mode (1,1) string { mustBeMember(args.start_mode, ["display", "nodisplay", "default"]) } = "default";

    args.open_project (1,1) string = "";

    args.import_to_new_project (1,1) string = "";

    args.import_to_existing_project (1,1) string = "";

    args.save_project (1,1) string = "";

    args.export_fem_mesh (1,1) string = "";

    args.open_figure (1,1) string = "";

    args.open_figure_folder (1,1) string = "";

    args.run_script (:,1) string = "";

    args.exit_zeffiro (1,1) logical = false;

    args.quit_matlab (1,1) logical = false;

    args.use_github (1,1) logical = false;

    args.use_gpu (1,1) logical;

    args.use_gpu_graphic (1,1) logical;

    args.gpu_num (1,1) double { mustBeInteger, mustBeNonnegative };

    args.use_display (1,1) logical;

    args.parallel_processes (1,1) double {mustBePositive, mustBeInteger};

    args.verbose_mode (1,1) logical; 

    args.use_waitbar (1,1) logical;

    args.use_log (1,1) logical;

    args.log_file_name (1,1) string;

    args.submodules = string([])

    args.skip_submodules (1,1) logical = false

    args.always_show_waitbar (1,1) logical = false

end

% Prevent starting of Zeffiro, if there is an existing value of zef.

if not(args.zeffiro_restart) && evalin("base","exist('zef', 'var');")

    error( ...
        "It looks like another instance of Zeffiro Interface is already open." ...
        + " To start a new instance, close Zeffiro Interface with 'zef_close_all'," ...
        + " clear zef from the base workspace with the command 'clear zef' or" ...
        + " force a restart with" ...
        + newline + newline ...
        + "    zef = zeffiro_interface('zeffiro_restart', true, other_options…);" ...
        )

end

addpath([fileparts(mfilename('fullpath')) filesep 'src' filesep 'core']);

zef_close_all();

addpath([fileparts(mfilename('fullpath'))]);

%% Set zef fields based on name–value arguments.

zef = struct;

zef = utilities.structs.copy_fields ( args, zef ) ;

%% Then do initial preparations like path building and additions.

program_path = string(mfilename("fullpath"));

[program_path, ~] = fileparts(program_path);

program_path = string(program_path);

code_path = fullfile(program_path, "src");

% TODO: should this be run here?
%
% run(code_path + filesep + "zef_close_all.m");

zef.program_path = char(program_path);

zef.code_path = code_path;

zef.data_path = fullfile(zef.program_path, "data");

zef.external_path = fullfile(zef.program_path, "external");

zef.zeffiro_task_id = 0;

zef.zeffiro_restart_time = cputime;

% Cluster utilities path (for backward compatibility)
% Note: Cluster utilities are available via the +utilities/+cluster package.
% MATLAB namespace (package) directories must NOT be added to the path;
% they are accessible automatically when the parent directory is on the path
% (e.g., call functions as utilities.cluster.functionName).
zef.cluster_path = fullfile(zef.program_path, "+utilities", "+cluster");

addpath(zef.program_path);
addpath(zef.code_path);
addpath(genpath(zef.code_path));

addpath(genpath(fullfile(zef.program_path, "assets", "fig")));
addpath(genpath(fullfile(zef.program_path, "tools", "plugins")));
addpath(genpath(fullfile(zef.program_path, "profile")));

% legacy/ holds deprecated shims (compute_measurements, run_inverse_script)
% that delegate to the new zef_-prefixed functions. Add it to the path so
% existing batch / cluster jobs that source those names keep working.
if isfolder(fullfile(zef.program_path, "legacy"))
    addpath(genpath(fullfile(zef.program_path, "legacy")));
end

addpath(zef.external_path);

zef.start_mode = args.start_mode ;

zeffiro_setup ( 'submodules', args.submodules, 'skip_submodules', args.skip_submodules ) ;

addpath(zef.code_path);

if not(zef.zeffiro_restart)
    try
        zef_start_config;
    catch
        error ( "Could not run zef_start_config. Did you run the zeffiro_setup script before trying to start Zeffiro?" ) ;
    end
end

zef = zef_start(zef);

if not(zef.zeffiro_restart) && isfile(fullfile(zef.data_path, "default_project.mat"))

    zef = zef_load(zef, "default_project.mat", fullfile(zef.data_path));

end

zef = zef_start_log(zef);

if isfield(zef, "h_zeffiro_window_main") ...
        && isvalid(zef.h_zeffiro_window_main) ...
        && zef.start_mode == "display"

    zef.h_zeffiro.Visible = 1;
    zef.h_zeffiro_window_main.Visible = 1;
    zef.h_mesh_tool.Visible = 1;
    zef.h_mesh_visualization_tool.Visible = 1;
    zef.h_zeffiro_menu.Visible = 1;
    zef.use_display = 1;

end

%% Finally, do the things specified by the input arguments.

% Choose GPU device, if available.

zef.gpu_count = gpuDeviceCount;

if zef.gpu_count > 0 && zef.use_gpu

    try

        gpuDevice(zef.gpu_num);

    catch

        warning("Tried using GPU with index " + zef.gpu_num + " but no such device was found. Starting without GPU...");

    end

end % if

% Open new project if given.

if not(args.open_project == "")

    open_project_file = args.open_project;

    [file_path, fname, fsuffix] = fileparts(open_project_file);

    if file_path == ""
        file_path = fullfile(zef.program_path, "data");
    end

    if fsuffix == ""
        fsuffix = ".mat";
    end

    zef.file_path = char(file_path);

    zef.file = char(fname + fsuffix);

    zef = zef_load(zef, zef.file, zef.file_path);

end % if

% Import given file contents to a new project.

if not(args.import_to_new_project == "")

    import_segmentation_file = args.import_to_new_project;

    [file_path, fname, fsuffix] = fileparts(import_segmentation_file);

    if file_path == ""

        file_path = fullfile(zef.program_path, "data");

    end

    if fsuffix == ""

        fsuffix = ".mat";

    end

    zef.new_empty_project = 1;

    zef_start_new_project;

    zef.file_path = char(file_path);

    zef.file = char(fname + fsuffix);

    zef = zef_import_segmentation(zef);

    zef = zef_build_compartment_table(zef);

end % if

% Import given file contents into an existing project.

if not(args.import_to_existing_project == "")

    import_segmentation_file = args.import_to_existing_project;

    [file_path, fname, fsuffix] = fileparts(import_segmentation_file);

    if file_path == ""

        file_path = fullfile(zef.program_path, "data");

    end

    if fsuffix == ""

        fsuffix = ".mat";

    end

    zef.file_path = char(file_path);

    zef.file = char(fname + fsuffix);

    zef.new_empty_project = 0;

    zef = zef_import_segmentation(zef);

    zef = zef_build_compartment_table(zef);

end % if

% Open figure in a given path.

if not(args.open_figure == "")

    open_figure_file = args.open_figure;

    if not(iscell(open_figure_file))

        open_figure_file_aux = open_figure_file;

        open_figure_file = cell(0);

        open_figure_file{1} = open_figure_file_aux;

    end

    for i = 1 : length(open_figure_file)

        [file_path, fname, fsuffix] = fileparts(open_figure_file{i});

        % Default folder for figure files is fig/ (templates and tools in fig/tools/).
        if file_path == ""
            file_path = fullfile(zef.program_path, "assets", "fig");
        end

        if fsuffix == ""
            fsuffix = ".fig";
        end

        zef.file_path = char(file_path);

        zef.file = char(fname + fsuffix);

        zef.save_switch = 1;

        zef = zef_import_figure(zef);

    end % for

end % if

% Open all figures in a given folder, if given.

if not(args.open_figure_folder == "")

    file_path = args.open_figure_folder;

    dir_aux = dir(fullfile(zef.program_path,file_path));

    for i = 3 : length(dir_aux)

        [~, fname, fsuffix] = fileparts(string(dir_aux(i).name));

        if isequal(fsuffix, ".fig")

            zef.file_path = char(file_path);

            zef.file = char(fname + fsuffix);

            zef.save_switch = 1;

            zef = zef_import_figure(zef);

        end % if

    end % for

end % if

% Before possibly saving and quitting, run the script given as an
% argument.
%
% NOTE: using eval here is very unsafe. Allows for arbitrary code
% execution. Make sure given script is from a trusted source.

if not(args.run_script == "")

    eval(args.run_script);

end % if

% Export FE mesh to a given path.

if not(args.export_fem_mesh == "")

    export_fem_mesh_file = args.export_fem_mesh;

    [file_path, fname, fsuffix] = fileparts(export_fem_mesh_file );

    if file_path == ""

        file_path = fullfile(zef.program_path, "data");

    end

    if fsuffix == ""

        fsuffix = ".mat";

    end

    zef.file_path = char(file_path);

    zef.file = char(fname + fsuffix);

    zef.save_switch = 1;

    zef_export_fem_mesh_as(zef);

end % if

% Save entire open project to the given file, if not empty.

if not(args.save_project == "")

    save_project_file = args.save_project;

    [file_path, fname, fsuffix] = fileparts(save_project_file);

    if file_path == ""

        file_path = fullfile(zef.program_path, ['data' filesep]);

    end

    if fsuffix == ""

        fsuffix = ".mat";

    end

    zef.file_path = char(file_path);

    zef.file = char(fname + fsuffix);

    zef.save_switch = 1;

    zef = zef_save(zef, zef.file, zef.file_path);

end

% Exit zeffiro, if told to.

if args.exit_zeffiro
    zef_close_all;
end

% Close Matlab, if told to.

if args.quit_matlab
    quit force;
end

% Make sure zef exists as a varible in the base workspace.

if nargout == 0

    assignin("base", "zef", zef);

    % This prevents the returning of zef twice, with "ans" as the name of
    % the other instance.

    clear zef;

end

end % function
