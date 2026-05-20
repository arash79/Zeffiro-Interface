function max_point = zef_rec_maximizer(rec_arr, s_pos)
% --- Zeffiro documentation header ---
% examples.studies.decision_making.helpers.zef_rec_maximizer — Example or study script demonstrating zef_rec_maximizer.
%
% Purpose:
%   Example or study script demonstrating zef_rec_maximizer.
%   Folder: Runnable examples and study scripts that exercise meshing, forward lead fields, inverse solvers, importing, and published workflows.
%
% Inputs:
%   rec_arr
%   s_pos
%
% Outputs:
%   max_point
%
% Calls (project):
%   zef_rec_maximizer
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[max_point] = examples.studies.decision_making.helpers.zef_rec_maximizer(rec_arr, s_pos)` with project root and `src` on the path.
% --- End Zeffiro documentation header

    [~, max_ind] = max(sqrt(sum(reshape(rec_arr, 3, length(rec_arr(:))/3).^2)), [], 2);
    max_point = s_pos(max_ind, :);
end
