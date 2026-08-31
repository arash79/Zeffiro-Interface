


function zef = zef_minimum_norm_estimation(zef)
%ZEF_MINIMUM_NORM_ESTIMATION  Minimum-norm (MNE) inverse mapping plugin.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = zef_minimum_norm_estimation
%   zef = zef_minimum_norm_estimation(zef)
%
%   INI callback (Inverse tools → Minimum norm estimation tool). Opens the
%   MNE window via zef_tool_start → zef_mne_tool_start. Does not invert.
%   Solver is zef_find_mne_reconstruction (Start in the window dump). Needs
%   zef.L and zef.measurements already on zef. Does not call inverse.MNEInverter.
%
%   See also zef_mne_tool_start, zef_find_mne_reconstruction.
%

if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_tool_start(zef,'zef_mne_tool_start',1/4,0);

if nargout == 0
    assignin('base','zef',zef)
end

end
