function zef_capture_ui(out_dir)
%ZEF_CAPTURE_UI  Snapshot Zeffiro windows to PNG for layout review.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef_capture_ui
%   zef_capture_ui(out_dir)

if nargin < 1 || isempty(out_dir)
    out_dir = fullfile(fileparts(which('zeffiro_interface')), 'data', 'log');
end
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

zef = zeffiro_interface('start_mode', 'display', 'use_github', false, ...
    'skip_submodules', true, 'use_waitbar', false);
assignin('base', 'zef', zef);

wins = { ...
    'h_zeffiro', 'ui_figure_tool.png'; ...
    'h_zeffiro_window_main', 'ui_segmentation_tool.png'; ...
    'h_mesh_tool', 'ui_mesh_tool.png'; ...
    'h_mesh_visualization_tool', 'ui_mesh_visualization_tool.png'; ...
    'h_zeffiro_menu', 'ui_menu_tool.png'};

pause(0.6);
drawnow;

for i = 1:size(wins, 1)
    local_snap_field(zef, wins{i, 1}, fullfile(out_dir, wins{i, 2}));
end

openers = { ...
    'zef_open_system_settings;', 'h_system_settings', 'ui_system_settings.png'; ...
    'zef_open_plugin_settings;', 'h_plugin_settings', 'ui_plugin_settings.png'; ...
    'zef_open_graphics_options;', 'h_zef_graphics_processing_options', 'ui_graphics_options.png'; ...
    'zef_open_forward_and_inverse_options;', 'h_zef_forward_and_inverse_processing_options', 'ui_forward_inverse_options.png'; ...
    'zef_open_gaussian_prior_options;', 'h_zef_gaussian_prior_options', 'ui_gaussian_prior.png'; ...
    'zef_open_parameter_profile;', 'h_parameter_profile', 'ui_parameter_profile.png'};

for i = 1:size(openers, 1)
    try
        evalin('base', openers{i, 1});
        zef = evalin('base', 'zef');
        local_snap_field(zef, openers{i, 2}, fullfile(out_dir, openers{i, 3}));
    catch err
        fprintf('open skip %s: %s\n', openers{i, 2}, err.message);
    end
end

tools = { ...
    @() evalin('base', 'zef_parcellation_tool;'), 'Parcellation', 'ui_parcellation_tool.png'; ...
    @() evalin('base', 'zef_butterfly_plot;'), 'butterfly', 'ui_butterfly_plot.png'; ...
    @() evalin('base', 'zef = zef_tool_start(zef, ''zef_mne_tool_start'', 1/4, 0); assignin(''base'',''zef'',zef);'), 'Minimum norm', 'ui_mne_tool.png'; ...
    @() evalin('base', 'zef = zef_tool_start(zef, ''zef_init_ias'', 1/4, 0); assignin(''base'',''zef'',zef);'), 'IAS', 'ui_ias_tool.png'};

for i = 1:size(tools, 1)
    try
        tools{i, 1}();
        pause(0.35);
        drawnow;
        figs = findall(groot, '-regexp', 'Name', 'ZEFFIRO Interface*');
        hit = [];
        for k = 1:numel(figs)
            try
                if contains(char(figs(k).Name), tools{i, 2}, 'IgnoreCase', true)
                    hit = figs(k);
                    break
                end
            catch
            end
        end
        if isempty(hit)
            fprintf('tool skip %s\n', tools{i, 2});
        else
            local_export(hit, fullfile(out_dir, tools{i, 3}));
            fprintf('wrote %s (%s)\n', tools{i, 3}, char(hit.Name));
        end
    catch err
        fprintf('tool skip %s: %s\n', tools{i, 2}, err.message);
    end
end

end

function local_snap_field(zef, name, dest)

ok = false;
try
    ok = isfield(zef, name) && isscalar(zef.(name)) && ishghandle(zef.(name)) && isvalid(zef.(name));
catch
end
if ~ok
    fprintf('skip %s\n', name);
    return
end
h = zef.(name);
try
    h.Visible = 'on';
    figure(h);
    drawnow;
    pause(0.25);
    local_export(h, dest);
    fprintf('wrote %s (%s)\n', dest, char(h.Name));
catch err
    fprintf('failed %s: %s\n', name, err.message);
end

end

function local_export(h, dest)

try
    exportapp(h, dest);
    return
catch
end
try
    fr = getframe(h);
    imwrite(fr.cdata, dest);
    return
catch
end
print(h, dest, '-dpng', '-r120');

end
