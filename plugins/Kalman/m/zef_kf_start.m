function zef = zef_kf_start(zef)
%ZEF_KF_START  Entry point that opens the Kalman plugin.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = zef_kf_start
%   zef = zef_kf_start(zef)
%
%   INI callback (Inverse tools → Kalman; not in asteroid INIs). Opens
%   zef_kf_app via zef_kf_open_window. StartButton runs zef = zef_KF(zef).
%   Needs zef.L and zef.measurements. Does not call inverse.KalmanInverter.
%   nargin 0 / nargout 0 use the base workspace.
%
%   See also zef_kf_open_window, zef_KF.
%

if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_tool_start(zef,'zef_kf_open_window',1/4,1);

if nargout == 0
    assignin('base','zef',zef)
end

end
