function zef = zef_find_synthetic_source_ROI(zef)
%ZEF_FIND_SYNTHETIC_SOURCE_ROI  Open Forward tools → Find synthetic extended source.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Default-profile menu callback. Builds measurements from every source
%   point inside a spherical, flat (optionally curved), or ellipsoidal ROI
%   via zef_find_source_ROI after zef_update_fss_ROI.
%
%   zef = zef_find_synthetic_source_ROI(zef)
%
%   See also zef_find_source_ROI, zef_ROI_finder.

if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_tool_start(zef,'zef_find_synthetic_source_ROI_window',1/4,0);

if nargout == 0
    assignin('base','zef',zef)
end

end
