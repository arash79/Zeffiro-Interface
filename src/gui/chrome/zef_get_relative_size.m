function [relative_size] = zef_get_relative_size(object_handle)
%ZEF_GET_RELATIVE_SIZE  Child Position vectors scaled by parent width/height.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Sets the figure's Units to pixels, reads Position, and for every
%   descendant with a Position property (except the figure itself)
%   divides [x y w h] by [W H W H] of the parent. Always returns a
%   column cell, even for a single child.
%
%   Callers store the cell on zef.*_relative_size and pass it to
%   zef_change_size_function. Used by zef_set_size_change_function
%   (type 2) and the open scripts for parameter / segmentation / init
%   profile, system settings, and plugin settings, plus several plugin
%   windows (DTI, ES workbench, synthetic source/gravity, dipolar pair).
%
%   relative_size = zef_get_relative_size(object_handle)
%
%   Input
%     object_handle - figure or UIFigure.
%
%   Output
%     relative_size - cell column of 1-by-4 relative positions.
%
%   See also zef_change_size_function, zef_set_size_change_function.
set(object_handle,'units','pixels')
object_size = get(object_handle,'position');
object_children = findall(object_handle,'-property','Position');
object_children = setdiff(object_children,object_handle);
relative_size_aux = get(object_children,'Position');

if and(iscell(relative_size_aux),not(isempty(relative_size_aux)))
    for i = 1 : length(relative_size_aux)
        if size(relative_size_aux{i},2) == 4
            relative_size_aux{i} = relative_size_aux{i}./object_size([3 4 3 4]);
        end
    end
else
    relative_size_aux = relative_size_aux./object_size([3 4 3 4]);
end

if iscell(relative_size_aux)
    relative_size = relative_size_aux(:);
else
    relative_size = {relative_size_aux};
end


end
