function zef = ias_map_estimation(zef)
%IAS_MAP_ESTIMATION  IAS ROI plugin entry (filename ias_map_estimation_roi.m).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = ias_map_estimation_roi
%   zef = ias_map_estimation_roi(zef)
%
%   INI callback ias_map_estimation_roi (Inverse tools → IAS ROI Inversion).
%   Filename is ias_map_estimation_roi.m; declared function name is
%   ias_map_estimation (same as the non-ROI start file; MATLAB calls the
%   filename). Opens the ROI window via zef_init_ias_roi. Does not invert.
%   Live Start calls ias_iteration_roi; solver on disk is zef_ias_iteration_roi.
%   Needs zef.L and zef.measurements.
%
%   See also zef_init_ias_roi, zef_ias_iteration_roi.
%

if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_tool_start(zef,'zef_init_ias_roi',1/4,0);

if nargout == 0
    assignin('base','zef',zef)
end

end
