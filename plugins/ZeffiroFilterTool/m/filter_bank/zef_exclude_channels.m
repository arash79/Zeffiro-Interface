function [processed_data] = zef_exclude_channels(f, exclude_channels)
%ZEF_EXCLUDE_CHANNELS  Pipeline stage: drop listed channel rows of f.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Add Input: Exclude channels [Default: ].
%
%Description: Exclude channels
%Input: 1 Exclude channels [Default: ]
%Output: Data without the excluded channels.
%

if isstr(exclude_channels)
    exclude_channels = str2num(exclude_channels);
end
%End of conversion.

selected_channels = find(not(ismember([1:length(f)],exclude_channels)));

processed_data = f(selected_channels,:);
