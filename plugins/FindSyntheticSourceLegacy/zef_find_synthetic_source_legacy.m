function zef = zef_find_synthetic_source_legacy(zef)
%ZEF_FIND_SYNTHETIC_SOURCE_LEGACY  Open Forward tools → Find synthetic source legacy.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = zef_find_synthetic_source_legacy(zef)
%
%   Default-profile INI callback. zef_tool_start(...,
%   'zef_find_synthetic_source_legacy_window', 1/4, 0). Create synthetic
%   data: zef.measurements = zef_find_source_legacy(zef). Single snapshot
%   (no pulse train). Needs zef.L, zef.source_positions. nargin 0 /
%   nargout 0 use base zef.
%
%   See also zef_find_source_legacy, zef_update_fss_legacy.

if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_tool_start(zef,'zef_find_synthetic_source_legacy_window',1/4,0);

if nargout == 0
    assignin('base','zef',zef)
end

end
