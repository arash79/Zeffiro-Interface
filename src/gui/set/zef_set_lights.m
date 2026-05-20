function zef_set_lights(lights_vec,varargin)
% --- Zeffiro documentation header ---
% zef_set_lights — Zef set lights.
%
% Purpose:
%   Zef set lights.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   lights_vec
%   varargin
%
% Outputs:
%   See function signature and code below.
%
% Zef fields (observed):
%   zef.h_axes1 (read)
%
% Calls (project):
%   zef_set_lights
%
% Side effects:
%   - base/caller workspace
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `zef_set_lights(lights_vec, varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if isequal(evalin('caller','exist(''zef'')'),1)
    zef = evalin('caller','zef');
else
    zef = evalin('base','zef');
end

if not(isempty(varargin))
    h_1 = varargin{1};
else
    h_1 = eval('zef.h_axes1');
end

delete(findobj(h_1.Children,'Type','Light'));

for i = 1 : length(lights_vec)

    aux_val = lights_vec(i);

    if aux_val == 1

        light(h_1,'Position',[0 0 1],'Style','infinite');
        light(h_1,'Position',[0 0 -1],'Style','infinite');

    elseif aux_val == 3

        light(h_1,'Position',[1 0 0],'Style','infinite');
        light(h_1,'Position',[-1 0 0 ],'Style','infinite');

    elseif aux_val == 4

        light(h_1,'Position',[0 1 0],'Style','infinite');
        light(h_1,'Position',[0 -1 0 ],'Style','infinite');

    elseif aux_val == 5

        light(h_1,'Position',[0 0 1],'Style','infinite');
        light(h_1,'Position',[0 0 -1 ],'Style','infinite');

    elseif aux_val == 6

        camlight(h_1,'headlight')

    end

end
