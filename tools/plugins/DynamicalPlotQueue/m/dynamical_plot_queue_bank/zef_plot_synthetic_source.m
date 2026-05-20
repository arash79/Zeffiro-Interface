function zef_plot_synthetic_source(varargin)
% --- Zeffiro documentation header ---
% zef_plot_synthetic_source — Renders or updates a plot_synthetic_source figure from current `zef` state.
%
% Purpose:
%   Renders or updates a plot_synthetic_source figure from current `zef` state.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   varargin
%
% Outputs:
%   See function signature and code below.
%
% Zef fields (observed):
%   zef.inv_synth_source (read)
%
% Calls (project):
%   zef_plot_synthetic_source
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `zef_plot_synthetic_source(varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header

color_cell = {'k','r','g','b','y','m','c'};
h_axes = evalin('caller','h_axes_image');
%axes(h_axes);
s = evalin('base','zef.inv_synth_source');
s_o = s(:,4:6)./repmat(sqrt(sum(s(:,4:6).^2,2)),1,3);
for i = 1 : size(s,1)
    source_size = 6*sqrt(s(i,9));
    h_source = quiver3(h_axes,s(i,1),s(i,2),s(i,3),s(i,9)*s_o(i,1),s(i,9)*s_o(i,2),s(i,9)*s_o(i,3),'Marker','o','MarkerSize',0.8*source_size);
    set(h_source,'Tag','additional: synthetic source');
    set(h_source,'linewidth',0.5*source_size);
    set(h_source,'color',color_cell{s(i,10)})

end

end
