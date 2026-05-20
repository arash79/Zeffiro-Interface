function nearest_list = zef_nearest_points( ...
% --- Zeffiro documentation header ---
% nearest_list — Nearest list.
%
% Purpose:
%   Nearest list.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   points
%   neighbour_points
%   quantity
%   quantity_interpretation
%
% Calls (project):
%   zef_nearest_points
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `nearest_list(points, neighbour_points, quantity, quantity_interpretation)` with project root and `src` on the path.
% --- End Zeffiro documentation header
    points, ...
    neighbour_points, ...
    quantity, ...
    quantity_interpretation ...
    )

arguments
    points (:, 3) double
    neighbour_points (:, 3) double
    quantity (1,1) double { mustBeReal, mustBeNonnegative }
    quantity_interpretation { mustBeText, mustBeMember(quantity_interpretation, ['single', 'count', 'range']) }
end

if strcmp(quantity_interpretation, 'count')

    if  (~ is_integer(quantity)) | quantity < 0
        error('Given quantity must be a positive integer when its interpretation is the number of neighbours');
    end

    MdlKDT = KDTreeSearcher(neighbour_points);

    nearest_list = knnsearch(MdlKDT, points, 'K', quantity);

elseif strcmp(quantity_interpretation, 'range')

    nearest_list = rangesearch(neighbour_points, points, quantity);

    % Reshape and -size

    nearest_list = unique([nearest_list{:}]');

elseif strcmp(quantity_interpretation, 'single')

    MdlKDT = KDTreeSearcher(neighbour_points);

    nearest_list = knnsearch(MdlKDT, points);

else

    error('Undefined quantity interpretation. Must be either ''single'', ''count'' or ''range''.');

end % if

end % function

%% Helper functions

function isint = is_integer(in_number)

arguments
    in_number double
end

isint = in_number == floor(in_number);

end
