function zef = zef_start(zef)
%ZEF_START  Apply system settings, open the core GUI tools, and sync zef.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called from zeffiro_interface after paths are set. Merges
%   zef_apply_system_settings into the current zef (caller fields win),
%   optionally git-pulls, counts GPUs, opens segmentation/figure/mesh/menu
%   tools, then zef_update. Distinct from the +core package.
%
%   zef = zef_start(zef)
%   zef_start          % reads zef from the base workspace
%
%   Input
%     zef  - session struct. If omitted, evalin('base','zef').
%
%   Output
%     zef  - updated session. If nargout is 0, assigned into the base workspace.
%
%   Side effects
%     May run !git pull when zef.use_github is true and zeffiro_restart is 0.
%     Selects gpuDevice(zef.gpu_num) when a GPU is requested and available.
%     Creates the main GUI figures and forces standalone window style via
%     zef_window_manager (MATLAB R2025a+ defaults WindowStyle to docked).
%     Adds src/nodisplay to the path when zef.use_display is 0.
%
%   See also zeffiro_interface, zef_init, zef_update, zef_close_all.


if nargin == 0
    zef = evalin('base','zef');
end

% Apply INI/system defaults, then overlay the caller's zef fields so
% session-specific values (paths, start_mode, GPU flags) are not lost.
zef_aux = zef;
zef = zef_apply_system_settings(zef);
fieldnames_aux = fieldnames(zef_aux);
for i = 1 : length(fieldnames_aux)
    zef.(fieldnames_aux{i}) = zef_aux.(fieldnames_aux{i});
end
clear zef_aux fieldnames_aux;

if isequal(zef.zeffiro_restart,0)

    use_github = zef.use_github;
    if evalin('caller','exist(''use_github'',''var'')')
        use_github = evalin('caller','use_github');
    end

    if use_github
        !git pull
    end

end

% gpuDeviceCount requires Parallel Computing Toolbox; treat a missing
% license as "no GPU" rather than erroring at startup.
zef.gpu_count = zef_gpu_count();

if ismember(zef.start_mode,{'nodisplay'})
    zef.use_display = 0;
else
    zef.use_display = 1;
end

% R2025a+: figure() factory WindowStyle is 'docked'. Force standalone
% windows for the session before any Zeffiro figure is created.
zef_window_manager('init');

if not(zef.use_display)
    addpath(genpath(fullfile(zef.program_path, 'src', 'nodisplay')));
end

if zef.gpu_count > 0 & zef.use_gpu == 1
    gpuDevice(zef.gpu_num);
end

zef.mlapp = 1;
zef.new_empty_project = 0;

zef_data = struct;

zef_init;

if zef.mlapp == 1
    zef_segmentation_tool;
else
    % Legacy: load segmentation tool from .fig (fig/ on path; see fig/README.md).
    zef.h_zeffiro_window_main = open('zef_segmentation_tool.fig');
end

zef_figure_tool;
zef_mesh_tool;
zef_mesh_visualization_tool;
zef_menu_tool;

zef = zef_update(zef);

set(findobj(zef.h_zeffiro.Children,'-property','FontUnits'),'FontUnits','pixels')
set(findobj(zef.h_zeffiro.Children,'-property','FontSize'),'FontSize',zef.font_size);
set(findobj(zef.h_zeffiro_window_main.Children,'-property','FontUnits'),'FontUnits','pixels')
set(findobj(zef.h_zeffiro_window_main.Children,'-property','FontSize'),'FontSize',zef.font_size);
set(findobj(zef.h_mesh_tool.Children,'-property','FontUnits'),'FontUnits','pixels')
set(findobj(zef.h_mesh_tool.Children,'-property','FontSize'),'FontSize',zef.font_size);
set(findobj(zef.h_mesh_visualization_tool.Children,'-property','FontUnits'),'FontUnits','pixels')
set(findobj(zef.h_mesh_visualization_tool.Children,'-property','FontSize'),'FontSize',zef.font_size);

zef_window_manager('standalone', zef.h_zeffiro_window_main);
zef_window_manager('standalone', zef.h_zeffiro);
zef_window_manager('standalone', zef.h_mesh_tool);
zef_window_manager('standalone', zef.h_mesh_visualization_tool);
zef_window_manager('standalone', zef.h_zeffiro_menu);
zef_window_manager('dock_menu', zef);

if nargout == 0
    assignin('base','zef',zef);
end

end
