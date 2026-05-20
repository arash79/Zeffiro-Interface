function slider_value_new = zef_update_transparency_additional(varargin)
% --- Zeffiro documentation header ---
% zef_update_transparency_additional — Syncs GUI control values into `zef` for transparency_additional.
%
% Purpose:
%   Syncs GUI control values into `zef` for transparency_additional.
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
%   zef_update_transparency_additional
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[slider_value_new] = zef_update_transparency_additional(varargin)` with project root and `src` on the path.
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
h_object = findobj(get(h_figure,'Children'),'Tag','transparency_additional_slider');
if isempty(h_object)
    h_figure = eval('zef.h_zeffiro');
    h_object = findobj(get(h_figure,'Children'),'Tag','transparency_additional_slider');
end

slider_value_new = h_object.Value;

h = findobj(h,'-regexp','Tag','additional*');

kappa = 1.05.^(-100*(slider_value_new));

for i = 1 : length(h)

    h(i).FaceAlpha = min(1,kappa);

end
end
