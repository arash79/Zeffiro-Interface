%ZEF_INIT_TRANSFORM  Fill h_transform_table from current_tag names (script).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Two columns: Index, Name from zef.<current_tag>_transform_name.
%   Called after zef_update_transform and when the Segmentation tool
%   switches the current tag.
%
%   See also zef_init_transform_parameters, zef_update_transform.
zef.aux_data_1 = cell(0);
zef.aux_data_2 = eval(['zef.' zef.current_tag '_transform_name']);

for zef_i = 1 : length(zef.aux_data_2)
    zef.aux_data_1{zef_i,1} = zef_i;
    zef.aux_data_1{zef_i,2} = zef.aux_data_2{zef_i};
end

zef.h_transform_table.Data = zef.aux_data_1;

zef = rmfield(zef,{'aux_data_1','aux_data_2'});
clear zef_i;
