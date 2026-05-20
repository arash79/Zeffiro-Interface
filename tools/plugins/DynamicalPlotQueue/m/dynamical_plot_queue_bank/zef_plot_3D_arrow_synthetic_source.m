function zef_plot_3D_arrow_synthetic_source(varargin)
% --- Zeffiro documentation header ---
% zef_plot_3D_arrow_synthetic_source — Renders or updates a plot_3d_arrow_synthetic_source figure from current `zef` state.
%
% Purpose:
%   Renders or updates a plot_3d_arrow_synthetic_source figure from current `zef` state.
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
%   zef_plot_3D_arrow
%   zef_plot_3D_arrow_synthetic_source
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `zef_plot_3D_arrow_synthetic_source(varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header

arrow_scale = 1;
arrow_type = 2;
arrow_color = 0.5*[1 1 1];
arrow_shape = 10;
arrow_length = 1;
arrow_head_size = 2;
arrow_n_polygons = 100;

if not(isempty(varargin))
    arrow_scale = varargin{1};
    if length(varargin)>1
        arrow_type = varargin{2};
    end
    if length(varargin)>2
        arrow_color = varargin{3};
    end
    if length(varargin)>3
        arrow_shape= varargin{4};
    end
    if length(varargin)>4
        arrow_length = varargin{5};
    end
    if length(varargin)>5
        arrow_head_size = varargin{6};
    end
    if length(varargin)>6
        arrow_n_polygons = varargin{7};
    end
end

color_cell = {'k','r','g','b','y','m','c'};
h_axes = evalin('caller','h_axes_image');
axes(h_axes);
s = evalin('base','zef.inv_synth_source');
s_o = s(:,4:6)./repmat(sqrt(sum(s(:,4:6).^2,2)),1,3);
for i = 1 : size(s,1)
    arrow_scale = 5*sqrt(s(i,9));
    h_arrow = zef_plot_3D_arrow(s(i,1),s(i,2),s(i,3),s_o(i,1),s_o(i,2),s_o(i,3),arrow_scale,arrow_type,color_cell{s(i,10)},arrow_shape,arrow_length,arrow_head_size,arrow_n_polygons);
    set(h_arrow,'Tag','additional: synthetic source');
end

end
