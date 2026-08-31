function zef = zef_ES_update_reconstruction(zef, varargin)
%ZEF_ES_UPDATE_RECONSTRUCTION  Update reconstruction button: zef.reconstruction = volumetric_current_density{sr,sc}.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   ButtonPushedFcn of h_ES_update_reconstruction (then zef_plot_meshes)
%   and right-click menu item 1. sr,sc from zef_ES_objective_function unless
%   nargin==3 supplies the indices. Deletes an existing ES_colorbar.
%
%   zef = zef_ES_update_reconstruction()
%   zef = zef_ES_update_reconstruction(zef)
%   zef = zef_ES_update_reconstruction(zef, sr, sc)
%
%   See also zef_ES_objective_function, zef_plot_meshes.
%

switch nargin
    case 0
        zef = evalin('base','zef');
        [sr, sc] = zef_ES_objective_function(zef);
        zef.reconstruction = zef.y_ES_interval.volumetric_current_density{sr,sc};
    case 3
        zef.reconstruction = zef.y_ES_interval.volumetric_current_density{varargin{1}, varargin{2}};
    otherwise
        error('Invalid length of input arguments.')
end
try %#ok<*TRYNC>
    delete(findobj(zef.h_zeffiro.Children,'-class','matlab.graphics.illustration.ColorBar', '-and', 'tag', 'ES_colorbar'));
end

if nargout == 0
    assignin('base','zef',zef);
end

end
