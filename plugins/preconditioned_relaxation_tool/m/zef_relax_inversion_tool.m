%ZEF_RELAX_INVERSION_TOOL  Preconditioned relaxation multigrid inverse plugin.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   INI callback (Inverse tools → Preconditioned relaxation tool). Loads
%   zef_relax, titles the window, and wires Start iteration to
%   zef_relax_iteration and Find preconditioner to zef_relax_find_preconditioner.
%   Run Find preconditioner before Start. Needs zef.L and zef.measurements.
%   No inverse.*Inverter.
%

zef_data = zef_relax;
zef.fieldnames = fieldnames(zef_data);
for zef_i = 1:length(zef.fieldnames)
    zef.(zef.fieldnames{zef_i}) = zef_data.(zef.fieldnames{zef_i});
end
clear zef_data;

set(zef.h_relax_tool,'Name','ZEFFIRO Interface: Preconditioned Iterative Relaxation')
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
