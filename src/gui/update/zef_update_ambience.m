function  ambience_val = zef_update_ambience(varargin)
% --- Zeffiro documentation header ---
% zef_update_ambience — Syncs GUI control values into `zef` for ambience.
%
% Purpose:
%   Syncs GUI control values into `zef` for ambience.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   varargin
%
% Outputs:
%   ambience_val
%
% Zef fields (observed):
%   zef.h_zeffiro (read)
%
% Calls (project):
%   zef_update_ambience
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[ambience_val] = zef_update_ambience(varargin)` with project root and `src` on the path.
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
h_object = findobj(get(h_figure,'Children'),'Tag','update_ambience_slider');
if isempty(h_object)
    h_figure = eval('zef.h_zeffiro');
    h_object = findobj(get(h_figure,'Children'),'Tag','update_ambience_slider');
end

ambience_val = h_object.Value;
h = h.Children;

for i = 1 : length(h)

    if not(isempty(find(ismember(properties(h(i)),'AmbientStrength'))))
        h(i).AmbientStrength = ambience_val;
    end

end

end
