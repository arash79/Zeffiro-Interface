function zef = zef_start(zef)
% --- Zeffiro documentation header ---
% zef_start — Zef start.
%
% Purpose:
%   Zef start.
%   Folder: Application lifecycle: `zef_start`, `zef_init`, `zef_update`, `zef_close_all`, logging, waitbars, window layout—not the `+core` package.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.font_size (read)
%   zef.gpu_count (read, write)
%   zef.gpu_num (read)
%   zef.h_mesh_tool (read)
%   zef.h_mesh_visualization_tool (read)
%   zef.h_zeffiro (read)
%   zef.h_zeffiro_window_main (read, write)
%   zef.mlapp (read, write)
%   zef.new_empty_project (read, write)
%   zef.program_path (read)
%   zef.start_mode (read)
%   zef.use_display (read, write)
%   zef.use_github (read)
%   zef.use_gpu (read, write)
%   zef.ver (read, write)
%   … (1 more)
%
% Calls (project):
%   zef_apply_system_settings
%   zef_start
%   zef_update
%
% Side effects:
%   - GPU
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_start(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef');
end

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

zef.ver = ver;
if not(license('test','distrib_computing_toolbox')) || not(any(strcmp(cellstr(char(zef.ver.Name)), 'Parallel Computing Toolbox')))
    zef.gpu_count = 0;
else
    zef.gpu_count = gpuDeviceCount;
end
zef = rmfield(zef, 'ver');

if ismember(zef.start_mode,{'nodisplay'})
    zef.use_display = 0;
else
    zef.use_display = 1;
end

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

if nargout == 0
    assignin('base','zef',zef);
end

end
