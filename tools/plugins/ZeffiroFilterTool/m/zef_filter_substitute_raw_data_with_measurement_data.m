%ZEF_FILTER_SUBSTITUTE_RAW_DATA_WITH_MEASUREMENT_DATA  Copy zef.measurements (or segment) onto zef.raw_data.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. ButtonPushedFcn of h_filter_substitute_raw_data_with_measurement_data.
%   Dialog: 'Substitute raw data with measurement data?'. On Yes, if
%   filter_data_segment > 0 copies measurements{segment} (promotes a
%   non-cell measurements to cell(0) first), else raw_data = measurements.
%   Does not run the pipeline.
%
%   See also zef_filter_substitute_raw_data, zef_import_raw_data.

[zef.yesno] = questdlg('Substitute raw data with measurement data?','Yes','No');
if isequal(zef.yesno,'Yes');

    if zef.filter_data_segment > 0
        if not(iscell(zef.measurements))
            zef.measurements = cell(0);
        end
        zef.raw_data = zef.measurements{zef.filter_data_segment};
    else
        zef.raw_data = zef.measurements;
    end

end;
