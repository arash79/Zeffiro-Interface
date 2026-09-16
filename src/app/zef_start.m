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
%   counts GPUs, opens segmentation/figure/mesh/menu tools, then
%   zef_update. Distinct from the +core package.
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
%     Does not run git pull. The name-value use_github is accepted and ignored.
%     Selects gpuDevice(zef.gpu_num) when a GPU is requested and available.
%     Creates the main GUI figures and forces standalone window style via
%     zef_window_manager (MATLAB R2025a+ defaults WindowStyle to docked).
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

if isequal(zef.zeffiro_restart, 0) && isfield(zef, 'use_github') && zef.use_github
    warning('Zeffiro:GitPullDisabled', ...
        ['use_github is ignored. Automatic git pull at startup was removed. ', ...
         'Pull explicitly from a terminal if you intend to update.']);
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

if zef.gpu_count > 0 && isfield(zef, 'use_gpu') && zef.use_gpu
    try
        gpuDevice(zef.gpu_num);
    catch
        warning('Zeffiro:GpuDeviceMissing', ...
            "Tried using GPU with index " + zef.gpu_num + ...
            " but no such device was found. Starting without GPU...");
    end
end

zef.new_empty_project = 0;

zef_data = struct;

zef_init;

zef_segmentation_tool;

zef_figure_tool;
zef_mesh_tool;
zef_mesh_visualization_tool;
zef_menu_tool;

zef = zef_update(zef);

set(findobj(zef.h_zeffiro.Children,'-property','FontUnits'),'FontUnits','pixels')
zef_ui_ready(zef.h_zeffiro);
zef_ui_ready(zef.h_zeffiro_window_main);
zef_ui_ready(zef.h_mesh_tool);
zef_ui_ready(zef.h_mesh_visualization_tool);
zef_ui_ready(zef.h_zeffiro_menu);

zef_window_manager('standalone', zef.h_zeffiro_window_main);
zef_window_manager('standalone', zef.h_zeffiro);
zef_window_manager('standalone', zef.h_mesh_tool);
zef_window_manager('standalone', zef.h_mesh_visualization_tool);
zef_window_manager('standalone', zef.h_zeffiro_menu);
zef_ui_shell('bind', zef);
zef_ui_shell('hide_menu', zef);
zef_ui_shell('hide_companions', zef);

if nargout == 0
    assignin('base','zef',zef);
end

end
