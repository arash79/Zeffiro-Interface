function [name_cell, variable_cell] = zef_get_profile_parameters(zef,varargin)
%ZEF_GET_PROFILE_PARAMETERS  On scalar Segmentation/Free-form parameter names.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   From zef.parameter_profile rows where column 8 is Segmentation or
%   Free-form, column 6 is On, and column 3 is Scalar. name_cell is column 1
%   (display name); variable_cell is 'zef.' plus column 2 (field name).
%
%   Mesh visualization **Parameter:** list calls this with one output
%   (names). zef_plot_volume / zef_print_meshes / zef_plot_graph pass
%   parameter_index to get the matching zef.* field for the selected row.
%
%   [name_cell, variable_cell] = zef_get_profile_parameters(zef)
%   [name, variable] = zef_get_profile_parameters(zef, parameter_index)

parameter_index = [];

if not(isempty(varargin))
    parameter_index = varargin{1};
end

parameter_profile = eval('zef.parameter_profile');

zef_n = 0;

for zef_k =  1  : size(parameter_profile,1)
    if ismember(parameter_profile{zef_k,8},{'Segmentation', 'Free-form'}) ...
            && isequal(parameter_profile{zef_k,6},'On') ...
            && isequal(parameter_profile{zef_k,3},'Scalar')
        zef_n = zef_n + 1;
        name_cell{zef_n} = parameter_profile{zef_k,1};
        variable_cell{zef_n} = ['zef.' parameter_profile{zef_k,2}];
    end
end

if not(isempty(parameter_index))
    name_cell = name_cell{parameter_index};
    variable_cell = variable_cell{parameter_index};
end

end
