function zef = zef_csm_class_start(zef)
%ZEF_CSM_CLASS_START  Inverse tools entry for class CSM (zef_inverse_run).
%
%   Zeffiro Interface.
%   Copyright 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Opens a parameter dialog for inverse.CSMInverter. Distinct from the
%   legacy Classical Sparse Methods plugin (CSM_app_start).
%
%   zef = zef_csm_class_start
%   zef = zef_csm_class_start(zef)
%
%   See also zef_open_class_inverse, inverse.CSMInverter.

if nargin == 0
    zef = evalin('base', 'zef');
end

zef = zef_tool_start(zef, 'zef_csm_class_window', 1/3, 0);

if nargout == 0
    assignin('base', 'zef', zef);
end

end
