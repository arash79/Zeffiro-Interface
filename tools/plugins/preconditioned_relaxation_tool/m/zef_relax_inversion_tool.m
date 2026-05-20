%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% zef_data = zef_relax; — Zef data = zef relax;.
%
% Purpose:
%   Zef data = zef relax;.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.fieldnames (read, write)
%   zef.font_size (read)
%   zef.h_relax_find_preconditioner (read)
%   zef.h_relax_iteration_type (read)
%   zef.h_relax_normalize_data (read)
%   zef.h_relax_preconditioner_type (read)
%   zef.h_relax_start_iteration (read)
%   zef.h_relax_tool (read)
%   zef.reconstruction (read)
%   zef.reconstruction_information (read)
%   zef.relax_preconditioner (read)
%   zef.relax_preconditioner_permutation (read)
%   zef.relax_tool_current_size (read, write)
%
% Calls (project):
%   zef_change_size_function
%   zef_relax_iteration
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: Call `zef_data = zef_relax;` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header




zef_data = zef_relax;
zef.fieldnames = fieldnames(zef_data);
for zef_i = 1:length(zef.fieldnames)
    zef.(zef.fieldnames{zef_i}) = zef_data.(zef.fieldnames{zef_i});
end
clear zef_data;

set(zef.h_relax_tool,'Name','ZEFFIRO Interface: Preconditioned Iterative Relaxation');
set(findobj(zef.h_relax_tool.Children,'-property','FontUnits'),'FontUnits','pixels')
set(findobj(zef.h_relax_tool.Children,'-property','FontSize'),'FontSize',zef.font_size);
set(zef.h_relax_start_iteration,'ButtonPushedFcn','zef_update_relax_inversion_tool; [zef.reconstruction, zef.reconstruction_information] = zef_relax_iteration([]);');
set(zef.h_relax_find_preconditioner,'ButtonPushedFcn','zef_update_relax_inversion_tool; [zef.relax_preconditioner, zef.relax_preconditioner_permutation]  = zef_relax_find_preconditioner;');
set(zef.h_relax_iteration_type,'ItemsData',[1:length(get(zef.h_relax_iteration_type,'Items'))])
set(zef.h_relax_preconditioner_type,'ItemsData',[1:length(get(zef.h_relax_preconditioner_type,'Items'))])
set(zef.h_relax_normalize_data,'ItemsData',[1:length(get(zef.h_relax_normalize_data,'Items'))])

zef_init_relax_inversion_tool;

set(zef.h_relax_tool,'AutoResizeChildren','off');
zef.relax_tool_current_size = get(zef.h_relax_tool,'Position');
set(zef.h_relax_tool,'SizeChangedFcn','zef.relax_tool_current_size = zef_change_size_function(zef.h_relax_tool,zef.relax_tool_current_size);');
