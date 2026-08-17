%CAPTURE_ZEF_UI  Start Zeffiro (hidden if possible) and snapshot core windows.
%
%   Run from the project root in MATLAB:
%     run('data/log/capture_zef_ui.m')
%
%   Writes PNG files next to this script.

project_root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
if isempty(project_root)
    project_root = pwd;
end
addpath(project_root);
addpath(genpath(fullfile(project_root, 'src')));

out_dir = fullfile(project_root, 'data', 'log');
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

if evalin('base', 'exist(''zef'',''var'')')
    evalin('base', 'zef_close_all');
end

zef = zeffiro_interface('start_mode', 'display', 'use_github', false, ...
    'skip_submodules', true, 'use_waitbar', false);

windows = { ...
    'h_zeffiro', 'ui_figure_tool.png'; ...
    'h_zeffiro_window_main', 'ui_segmentation_tool.png'; ...
    'h_mesh_tool', 'ui_mesh_tool.png'; ...
    'h_mesh_visualization_tool', 'ui_mesh_visualization_tool.png'; ...
    'h_zeffiro_menu', 'ui_menu_tool.png'};

pause(0.5);
drawnow;

for i = 1:size(windows, 1)
    name = windows{i, 1};
    file = windows{i, 2};
    if ~isfield(zef, name) || ~isgraphics(zef.(name)) || ~isvalid(zef.(name))
        fprintf('skip %s\n', name);
        continue
    end
    h = zef.(name);
    try
        h.Visible = 'on';
        figure(h);
        drawnow;
        pause(0.2);
        dest = fullfile(out_dir, file);
        try
            exportgraphics(h, dest, 'Resolution', 120);
        catch
            saveas(h, dest);
        end
        fprintf('wrote %s\n', dest);
    catch err
        fprintf('failed %s: %s\n', name, err.message);
    end
end

assignin('base', 'zef', zef);
