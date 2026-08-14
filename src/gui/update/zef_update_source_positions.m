function [source_positions] = zef_update_source_positions(void)
%ZEF_UPDATE_SOURCE_POSITIONS  Rescale zef.source_positions between length units.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Function. Reads zef.location_unit_current and zef.location_unit from
%   base (1 = mm → factor 1000, 2 = cm → 100, 3 = m → 1) and returns
%   source_positions * (new/old). Does not write zef and does not plot.
%   The unused argument is historical.
%
%   source_positions = zef_update_source_positions([])
%
%   See also zef_plot_source.
location_unit_current = evalin('base','zef.location_unit_current');
location_unit = evalin('base','zef.location_unit');
source_positions = evalin('base','zef.source_positions');

switch location_unit_current
    case 1
        b = 1000;
    case 2
        b = 100;
    case 3
        b = 1;
end
switch location_unit
    case 1
        a = 1000;
    case 2
        a = 100;
    case 3
        a = 1;
end

if not(isempty(source_positions))
    source_positions = (a/b)*source_positions;
end
