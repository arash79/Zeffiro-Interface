function [processed_data] = zef_select_channels(f, select_channels)
%ZEF_SELECT_CHANNELS  Pipeline stage: keep listed channel rows of f.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Add Input: Selected channels [Default: ''].
%
%Description: Select channels
%Input: 1 Selected channels [Default: '']
%Output: Data for selected channels.
%

if isstr(select_channels)
    select_channels = str2num(select_channels);
end
%End of conversion.

processed_data = f(select_channels,:);
