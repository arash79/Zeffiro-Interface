function zef = ias_map_estimation(zef)
%IAS_MAP_ESTIMATION  IAS (iterative alternating sequential) inverse plugin.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = ias_map_estimation
%   zef = ias_map_estimation(zef)
%
%   INI callback (Inverse tools → IAS Inversion). Opens the IAS window via
%   zef_init_ias. Start (set in zef_init_ias) runs zef_ias_iteration(zef)
%   into zef.reconstruction and reconstruction_information. Needs zef.L
%   and zef.measurements. Does not call inverse.IASInverter.
%
%   See also zef_init_ias, zef_ias_iteration.
%

if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_tool_start(zef,'zef_init_ias',1/4,0);

if nargout == 0
    assignin('base','zef',zef)
end

end
