function zef = zef_GMModel_open(zef)
%ZEF_GMMODEL_OPEN  Construct the SP GMM window and run init.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = zef_GMModel_open(zef)
%
%   Called via zef_tool_start from zef_GMModel_start. Window then
%   zef_GMModel_init (script). Does not cluster.
%
%   See also zef_GMModel_window, zef_GMModel_start.

zef = zef_GMModel_window(zef);
zef_GMModel_init;

end
