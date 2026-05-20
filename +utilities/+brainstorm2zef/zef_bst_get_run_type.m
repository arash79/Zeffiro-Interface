function [run_type] = zef_bst_get_run_type(h_parent)
% --- Zeffiro documentation header ---
% utilities.brainstorm2zef.zef_bst_get_run_type — Zef bst get run type.
%
% Purpose:
%   Zef bst get run type.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   h_parent
%
% Outputs:
%   run_type
%
% Calls (project):
%   utilities.brainstorm2zef.zef_bst_get_run_type
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[run_type] = utilities.brainstorm2zef.zef_bst_get_run_type(h_parent)` with project root and `src` on the path.
% --- End Zeffiro documentation header

if nargin < 1
    h_parent = get(gcbo,'Parent');
end

h_object = findobj(h_parent.Children,'Tag','run_type');
run_type = h_object.Value;

end
