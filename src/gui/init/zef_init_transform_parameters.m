%ZEF_INIT_TRANSFORM_PARAMETERS  Load h_parameters_table for the selected transform (script).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Required: zef.current_transform (slot) and zef.current_tag.
%   Rows (name → field): Scaling, X/Y/Z-shift, Xy/Yz/Zx-rotation,
%   Affine transform. Affine is mat2str of a 4-by-4 (eye(4) if missing).
%   Sets current_parameters='transform' for zef_update_parameters.
%
%   See also zef_update_transform_parameters, zef_init_transform.
zef.aux_data_1 = cell(0);
zef.aux_data_2 = {{'Scaling','scaling'},{'X-shift','x_correction'},{'Y-shift','y_correction'},{'Z-shift','z_correction'},{'Xy-rotation','xy_rotation'},{'Yz-rotation','yz_rotation'},{'Zx-rotation','zx_rotation'},{'Affine transform','affine_transform'}};
zef_i = evalin('base','zef.current_transform');

for zef_j = 1 : length(zef.aux_data_2)
    zef.aux_data_1{zef_j,1} = zef.aux_data_2{zef_j}{1};
    if isequal(zef.aux_data_2{zef_j}{2},'affine_transform')
        if not(evalin('base',['isfield(zef,''' zef.current_tag '_' zef.aux_data_2{zef_j}{2} ''')']))
            zef.aux_data_1{zef_j,2} = evalin('base','eye(4)');
        else
            zef.aux_data_1{zef_j,2} = evalin('base',['zef.' zef.current_tag '_' zef.aux_data_2{zef_j}{2} '{' num2str(zef_i) '}']);
        end
    else
        zef.aux_data_1{zef_j,2} = evalin('base',['zef.' zef.current_tag '_' zef.aux_data_2{zef_j}{2} '(' num2str(zef_i) ')']);
    end

    if iscell(zef.aux_data_1{zef_j,2})
        zef.aux_data_1{zef_j,2} = cell2mat(zef.aux_data_1{zef_j,2});
    end
    zef.aux_data_1{zef_j,2} = mat2str(zef.aux_data_1{zef_j,2});
end


zef.h_parameters_table.Data = zef.aux_data_1;

zef.current_parameters = 'transform';

zef = rmfield(zef,{'aux_data_1','aux_data_2'});
clear zef_i zef_j;
