%ZEF_FILTER_SUBSTITUTE_RAW_DATA  Copy processed_data onto zef.measurements (optional data_segment cell).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Despite the filename, this writes measurements. Wired to
%   h_filter_substitute_measurement_data in zef_filter_tool (names are
%   swapped with zef_filter_substitute_measurement_data). Dialog:
%   'Substitute measurement data with processed data?'. On Yes,
%   zef_filter_raw_data, then if filter_data_segment > 0 writes
%   measurements{segment} (promotes a non-cell measurements to cell(0)
%   first), else measurements = processed_data.
%
%   See also zef_filter_substitute_measurement_data, zef_filter_raw_data.

[zef.yesno] = zef_ui_confirm('Substitute measurement data with processed data?','Yes','No');
if isequal(zef.yesno,'Yes');
    zef_filter_raw_data;

    if zef.filter_data_segment > 0
        if not(iscell(zef.measurements))
            zef.measurements = cell(0);
        end
        zef.measurements{zef.filter_data_segment} = zef.processed_data;
    else
        zef.measurements = zef.processed_data;
    end

end;
