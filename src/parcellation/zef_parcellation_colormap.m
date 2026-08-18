function [colormap_vec] = zef_parcellation_colormap(varargin)
%ZEF_PARCELLATION_COLORMAP  Return the current parcellation colormap from base zef.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   colormap_vec = zef_parcellation_colormap()
%
%   Output
%     colormap_vec - value of zef.parcellation_colormap in the base
%                    workspace, or [] if zef or the field is missing.
%
%   See also zef_parcellation_time_series.

colormap_vec = [];
if evalin('base', 'exist(''zef'', ''var'')') == 1
    zef_base = evalin('base', 'zef');
    if isstruct(zef_base) && isfield(zef_base, 'parcellation_colormap')
        colormap_vec = zef_base.parcellation_colormap;
    end
end

end
