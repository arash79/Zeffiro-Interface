function zef = zeffiro_interface(args)
%ZEFFIRO_INTERFACE  Start Zeffiro Interface (GUI or batch) and return the project state.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Builds the session struct zef, puts src/, plugins, profiles, and GUI
%   assets on the MATLAB path, optionally installs git submodules via
%   zeffiro_setup, then runs zef_start. Name-value arguments can open a
%   project, import a .zef segmentation, export a FEM mesh, run a trusted
%   script, or shut down Zeffiro/MATLAB after startup.
%
%   zef = zeffiro_interface
%   zef = zeffiro_interface(Name, Value, ...)
%   zef = zeffiro_interface(Name=Value, ...)   % R2021a+
%
%   Name-value arguments (all optional)
%     zeffiro_restart     - logical, default false. If true, skip the
%                           "already open" check so a new session can start.
%     start_mode          - "display", "nodisplay", or "default". Controls
%                           whether GUI windows are shown. Hidden windows
%                           may still be created in the background.
%     open_project        - path to a .mat project loaded after start.
%                           Empty path defaults to data/; empty suffix to .mat.
%     import_to_new_project
%                         - path to a .zef segmentation imported into a new
%                           empty project (zef_start_new_project).
%     import_to_existing_project
%                         - path to a .zef segmentation imported into the
%                           current project.
%     save_project        - path where the full project is saved via zef_save.
%     export_fem_mesh     - path for zef_export_fem_mesh_as.
%     open_figure         - path to a .fig opened with zef_import_figure.
%                           Default folder is assets/fig/.
%     open_figure_folder  - folder (relative to program_path) whose .fig
%                           files are opened. The dir listing skips the
%                           first two entries (typically . and ..).
%     run_script          - string passed to eval after other I/O setup and
%                           before save/export/exit. Treat as a security
%                           hole: only pass trusted content.
%     exit_zeffiro        - logical, default false. Calls zef_close_all on return.
%     quit_matlab         - logical, default false. Calls quit force on return.
%     use_github          - logical, default false. Forwarded into zef; zef_start
%                           may run !git pull when this is true.
%     use_gpu             - logical. Select gpuDevice(zef.gpu_num) when a GPU
%                           is present. Missing fields are copied from args
%                           by utilities.structs.copy_fields.
%     use_gpu_graphic     - logical. GPU graphics acceleration flag stored on zef.
%     gpu_num             - nonnegative integer GPU device index.
%     use_display         - logical. Whether file dialogs are shown.
%     parallel_processes  - positive integer worker count stored on zef.
%     verbose_mode        - logical. Logger verbosity stored on zef.
%     use_waitbar         - logical. Waitbar flag stored on zef.
%     use_log             - logical. Log-file flag stored on zef.
%     log_file_name       - string log path stored on zef.
%     submodules          - string array of names from .gitmodules, or "all".
%                           Passed to zeffiro_setup.
%     skip_submodules     - logical, default false. Skip submodule setup.
%     always_show_waitbar - logical, default false. Show waitbar even when
%                           other windows are suppressed.
%
%   Output
%     zef  - session struct (paths, GPU flags, GUI handles, project data).
%            If called with no output argument, zef is assigned into the
%            base workspace and cleared locally so ans is not duplicated.
%
%   Side effects
%     Adds project paths, may write src/core/zef_start_config.m via
%     zeffiro_setup, creates GUI figures, may load default_project.mat,
%     and may mutate GPU device, files, and the base workspace.
%
%   Failure
%     Errors if zef already exists in the base workspace and
%     zeffiro_restart is false. Errors if zef_start_config cannot be run
%     (typically because zeffiro_setup was never executed). Warns and
%     continues if gpu_num does not match a device.
%
%   See also zeffiro_setup, zef_start, zef_close_all, zef_load, zef_save.

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

root_path = fileparts(mfilename('fullpath'));
addpath(fullfile(root_path, 'src', 'core'));
% zef_close_all restores R2025a+ WindowStyle via zef_window_manager, which
% lives next to the other GUI helpers, not in src/core.
addpath(fullfile(root_path, 'src', 'gui', 'helpers'));

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

% Choose GPU device, if available. gpuDeviceCount requires Parallel
% Computing Toolbox; zef_gpu_count returns 0 when it is missing.
zef.gpu_count = zef_gpu_count();

if zef.gpu_count > 0 && isfield(zef, 'use_gpu') && zef.use_gpu

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
