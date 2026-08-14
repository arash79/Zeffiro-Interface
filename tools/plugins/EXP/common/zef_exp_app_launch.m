function zef = zef_exp_app_launch(zef)
%ZEF_EXP_APP_LAUNCH  Inverse tools → Standardized Hierarchical L1/L2 MAP (Lasso).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = zef_exp_app_launch
%   zef = zef_exp_app_launch(zef)
%
%   Default-profile INI callback. zef_tool_start(..., 'zef_exp_app_start',
%   1/6, 1). StartButton runs exp_iteration(zef), not
%   inverse.GroupLassoInverter. nargin 0 / nargout 0 use base zef.
%
%   See also zef_exp_app_start, exp_iteration.

if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_tool_start(zef,'zef_exp_app_start',1/6,1);

if nargout == 0
    assignin('base','zef',zef)
end

end
