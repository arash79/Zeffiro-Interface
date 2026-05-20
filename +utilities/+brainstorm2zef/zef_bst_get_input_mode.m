function [input_mode] = zef_bst_get_input_mode(h_parent)
% --- Zeffiro documentation header ---
% utilities.brainstorm2zef.zef_bst_get_input_mode — Zef bst get input mode.
%
% Purpose:
%   Zef bst get input mode.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   h_parent
%
% Outputs:
%   input_mode
%
% Calls (project):
%   utilities.brainstorm2zef.zef_bst_get_input_mode
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[input_mode] = utilities.brainstorm2zef.zef_bst_get_input_mode(h_parent)` with project root and `src` on the path.
% --- End Zeffiro documentation header

if nargin < 1
    h_parent = get(gcbo,'Parent');
end

h_object = findobj(h_parent.Children,'Tag','input_mode');
input_mode = h_object.Value;

end
