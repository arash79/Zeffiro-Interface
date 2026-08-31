function zef = zef_start_dataBank(zef)
%ZEF_START_DATABANK  Open Multi tools → Data Bank.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Default-profile menu callback. zef_tool_start → zef_open_dataBank.
%   Tree of leadfield/data/reconstruction snapshots; Combine writes
%   zef.L and zef.measurements.
%
%   zef = zef_start_dataBank(zef)
%
%   See also zef_open_dataBank, zef_dataBank_setData.
%

if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_tool_start(zef,'zef_open_dataBank',1/2,1);

if nargout == 0
    assignin('base','zef',zef)
end

end
