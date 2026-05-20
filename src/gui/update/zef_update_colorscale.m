function  colorscale_val = zef_update_colorscale(varargin)
% --- Zeffiro documentation header ---
% zef_update_colorscale — Syncs GUI control values into `zef` for colorscale.
%
% Purpose:
%   Syncs GUI control values into `zef` for colorscale.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   varargin
%
% Outputs:
%   colorscale_val
%
% Zef fields (observed):
%   zef.h_zeffiro (read)
%
% Calls (project):
%   zef_update_colorscale
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[colorscale_val] = zef_update_colorscale(varargin)` with project root and `src` on the path.
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
h_object= findobj(get(h_figure,'Children'),'Tag','colorscaleselection');
if isempty(h_object)
    h_figure = eval('zef.h_zeffiro');
    h_object = findobj(get(h_figure,'Children'),'Tag','colorscaleselection');
end

colorscale_val = h_object.Value;

if isequal(colorscale_val,1)
    h.ColorScale = 'linear';
elseif isequal(colorscale_val,2)
    h.ColorScale = 'log';
end

end
