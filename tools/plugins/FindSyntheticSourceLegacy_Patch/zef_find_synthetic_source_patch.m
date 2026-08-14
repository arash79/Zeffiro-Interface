function zef = zef_find_synthetic_source_patch(zef)
%ZEF_FIND_SYNTHETIC_SOURCE_PATCH  Open Forward tools → Synthetic extended source patch.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Default-profile menu callback. Create data:
%   zef.measurements = zef_find_source_patch(zef) after zef_update_fss_patch.
%
%   zef = zef_find_synthetic_source_patch(zef)
%
%   See also zef_find_source_patch.
%

if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_tool_start(zef,'zef_find_synthetic_source_patch_window',1/4,0);

if nargout == 0
    assignin('base','zef',zef)
end

end
