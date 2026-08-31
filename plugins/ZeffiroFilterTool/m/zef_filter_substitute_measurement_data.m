%ZEF_FILTER_SUBSTITUTE_MEASUREMENT_DATA  Copy processed_data onto zef.raw_data.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Despite the filename, this writes raw_data. Wired to
%   h_filter_substitute_raw_data in zef_filter_tool (names are swapped
%   with zef_filter_substitute_raw_data). Dialog: 'Substitute raw data
%   with processed data?'. On Yes, zef_filter_raw_data then
%   raw_data = processed_data. Does not touch measurements.
%
%   See also zef_filter_substitute_raw_data, zef_filter_raw_data.

[zef.yesno] = zef_ui_confirm('Substitute raw data with processed data?','Yes','No');
if isequal(zef.yesno,'Yes');
    zef_filter_raw_data;

    zef.raw_data = zef.processed_data;

end;
