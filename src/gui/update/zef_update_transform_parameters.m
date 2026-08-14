%ZEF_UPDATE_TRANSFORM_PARAMETERS  Transform parameters-table CellEditCallback (script).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Same row map as the 'transform' branch of zef_update_parameters
%   (scaling, x/y/z_correction, xy/yz/zx_rotation, affine_transform) but
%   writes through evalin('base',...) so a nested caller still updates
%   session zef. Target slot is zef.current_transform on zef.current_tag.
%
%   See also zef_update_parameters, zef_init_transform_parameters.
zef.aux_field_1 = zef.h_parameters_table.Data;
zef.aux_field_2 = {'scaling','x_correction','y_correction','z_correction','xy_rotation','yz_rotation','zx_rotation','affine_transform'};

for zef_i = 1 : size(zef.aux_field_1,1)

    if numel(str2num(zef.aux_field_1{zef_i,2})) > 1
        evalin('base',['zef.' zef.current_tag '_' zef.aux_field_2{zef_i} '(' num2str(zef.current_transform) ')= {[' zef.aux_field_1{zef_i,2} ']};']);
    else
        evalin('base',['zef.' zef.current_tag '_' zef.aux_field_2{zef_i} '(' num2str(zef.current_transform) ')=' zef.aux_field_1{zef_i,2} ';']);
    end

end

zef = rmfield(zef,{'aux_field_1','aux_field_2'});
clear zef_i;
