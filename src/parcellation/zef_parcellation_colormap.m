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
%     colormap_vec - value of zef.parcellation_colormap in the base workspace.
%
%   See also zef_parcellation_time_series.

colormap_vec = evalin('base','zef.parcellation_colormap');

end
