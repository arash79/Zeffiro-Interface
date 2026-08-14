%ZEF_FILTER_SUBSTITUTE_NOISE_DATA  Copy processed_data onto zef.noise_data.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. ButtonPushedFcn of h_filter_substitute_noise_data. Dialog:
%   'Substitute noise data with processed data?'. On Yes,
%   zef_filter_raw_data then noise_data = processed_data.
%
%   See also zef_filter_raw_data, zef_filter_substitute_raw_data.

[zef.yesno] = questdlg('Substitute noise data with processed data?','Yes','No');
if isequal(zef.yesno,'Yes');
    zef_filter_raw_data;

    zef.noise_data = zef.processed_data;
end
