%ZEF_PARCELLATION_RESET  Clear parcellation data and disable parcellation mode.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Empties zef.parcellation_colortable and zef.parcellation_points, sets
%   parcellation_merge to 1, use_parcellation to 0, clears
%   parcellation_selected, and calls zef_update_parcellation.
%
%   See also zef_import_parcellation_colortable, zef_parcellation_default.

zef.parcellation_colortable = cell(0);
zef.parcellation_points = cell(0);
zef.parcellation_merge = 1;
zef.use_parcellation = 0;
zef.parcellation_selected = [];
zef_update_parcellation;
