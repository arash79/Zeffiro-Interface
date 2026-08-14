function zef = zef_set_nse_source_space(zef,nse_field)



%ZEF_SET_NSE_SOURCE_SPACE  Copy NSE interior nodes into zef.source_positions.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   source_positions = nse_field.nodes(nse_field.i_node_ind,:);
%   source_orientations = []; then zef_source_interpolation. Lets the
%   figure tool display NSE nodes as a source space; does not assemble L.
%
%   zef = zef_set_nse_source_space(zef, nse_field)
%
%   See also zef_source_interpolation, zef_nse_iteration.

zef.source_positions = nse_field.nodes(nse_field.i_node_ind,:);
zef.source_orientations = [];
zef = zef_source_interpolation(zef);

end
