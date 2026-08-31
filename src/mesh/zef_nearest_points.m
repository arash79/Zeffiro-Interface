function nearest_list = zef_nearest_points( ...
    points, ...
    neighbour_points, ...
    quantity, ...
    quantity_interpretation ...
    )
%ZEF_NEAREST_POINTS  Neighbours of query points via KD-tree or range search.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Searches neighbour_points for each row of points. quantity_interpretation:
%     'single'  knnsearch K=1; nearest_list is n_points-by-1 indices
%     'count'   knnsearch K=quantity (nonnegative integer); n_points-by-K
%     'range'   rangesearch radius quantity, then unique([cells{:}]') so
%               the result is a single column of neighbour indices, not
%               a per-query cell array
%
%   Only first-party caller is zef_deep_nodes_and_tetra, twice with
%   'range' (drop source-compartment nodes within a depth of the
%   submesh boundary, including the boundary nodes themselves).
%
%   nearest_list = zef_nearest_points(points, neighbour_points, quantity, interpretation)
%
%   Inputs
%     points                  - n-by-3 query coordinates.
%     neighbour_points        - m-by-3 search set.
%     quantity                - K (count) or radius (range); ignored for
%                               'single' except the nonnegative check.
%     quantity_interpretation - 'single', 'count', or 'range'.
%
%   Output
%     nearest_list - indices into neighbour_points (see modes above).
%
%   See also zef_deep_nodes_and_tetra.

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
