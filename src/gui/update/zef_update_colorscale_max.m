function slider_value_new = zef_update_colorscale_max(varargin)
% --- Zeffiro documentation header ---
% zef_update_colorscale_max — Syncs GUI control values into `zef` for colorscale_max.
%
% Purpose:
%   Syncs GUI control values into `zef` for colorscale_max.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   varargin
%
% Outputs:
%   slider_value_new
%
% Zef fields (observed):
%   zef.h_zeffiro (read)
%
% Calls (project):
%   zef_update_colorscale_max
%   zef_update_contour
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[slider_value_new] = zef_update_colorscale_max(varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if isequal(evalin('caller','exist(''zef'')'),1)
    zef = evalin('caller','zef');
else
    zef = evalin('base','zef');
end

if not(isempty(varargin))
    h_figure = varargin{1};
else
    h_figure = eval('zef.h_zeffiro');
end

h = findobj(get(h_figure,'Children'),'Tag','axes1');
h_object = findobj(get(h_figure,'Children'),'Tag','colorscale_max_slider');
if isempty(h_object)
    h_figure = eval('zef.h_zeffiro');
    h_object = findobj(get(h_figure,'Children'),'Tag','colorscale_max_slider');
end

slider_value_new = h_object.Value;

if isempty(h_object.UserData)
    slider_value_old = 0;
else
    slider_value_old = h_object.UserData;
end

h_object.UserData = slider_value_new;

clim_vec = h.CLim;
if length(slider_value_new) == 1
    clim_vec(2) = clim_vec(2)*10^(slider_value_new - slider_value_old);
else
    clim_vec(2) = clim_vec(2)*10^(slider_value_new - slider_value_old);
end

h.CLim = clim_vec;
zef_update_contour(zef);

end
