function zef_plot_dof_space(void)
% --- Zeffiro documentation header ---
% zef_plot_dof_space — Renders or updates a plot_dof_space figure from current `zef` state.
%
% Purpose:
%   Renders or updates a plot_dof_space figure from current `zef` state.
%   Folder: Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.
%
% Inputs:
%   void
%
% Outputs:
%   See function signature and code below.
%
% Zef fields (observed):
%   zef.h_axes1 (read)
%   zef.source_positions (read)
%
% Calls (project):
%   zef_plot_dof_space
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `zef_plot_dof_space(void)` with project root and `src` on the path.
% --- End Zeffiro documentation header

h_axes = evalin('base','zef.h_axes1');
axes(h_axes);
hold on
source_positions = evalin('base','zef.source_positions');
scatter3(source_positions(:,1),source_positions(:,2),source_positions(:,3),'filled')

end
