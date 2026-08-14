%ZEF_INIT_SENSORS_TABLE  Fill h_transform_table from current_tag names (script).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Filename is historical: this writes zef.h_transform_table.Data
%   as two columns (Index, Name) from zef.<current_tag>_transform_name —
%   the same layout as zef_init_transform. Does not touch h_sensors_table.
%
%   See also zef_init_transform.
zef.aux_data_1 = cell(0);
zef.aux_data_2 = evalin('base',['zef.' zef.current_tag '_transform_name']);

for zef_i = 1 : length(zef.aux_data_2)
    zef.aux_data_1{zef_i,1} = zef_i;
    zef.aux_data_1{zef_i,2} = zef.aux_data_2{zef_i};
end

zef.h_transform_table.Data = zef.aux_data_1;

zef = rmfield(zef,{'aux_data_1','aux_data_2'});
clear zef_i;
