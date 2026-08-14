%ZEF_REOPEN_FIGURE  Figure-tool DeleteFcn: rebuild if the closed fig was h_zeffiro.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. zef_figure_tool sets DeleteFcn to this file. Clears gcbo Tag,
%   then if gcbo is zef.h_zeffiro calls zef_figure_tool again so closing the
%   window does not leave the session without axes1. exist('zef') must be 1
%   in the callback workspace.

set(gcbo,'Tag','');
if isequal(exist('zef'),1)
    if isfield(zef,'h_zeffiro')
        if zef.h_zeffiro == gcbo;
            zef_figure_tool;
        end
    end
end
