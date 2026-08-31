function zef = zef_dipole_start(zef)
%ZEF_DIPOLE_START  Entry point that opens the Dipole scan plugin.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = zef_dipole_start
%   zef = zef_dipole_start(zef)
%
%   INI callback (Inverse tools → Dipole Scan). Opens
%   dipole_app via zef_dipole_window. StartButton runs zef_dipoleScan(zef)
%   into reconstruction and reconstruction_information. Needs zef.L and
%   zef.measurements. Does not call inverse.DipoleScanInverter.
%
%   See also zef_dipole_window, zef_dipoleScan.
%

if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_tool_start(zef,'zef_dipole_window',1/4,1);

if nargout == 0
    assignin('base','zef',zef)
end

end
