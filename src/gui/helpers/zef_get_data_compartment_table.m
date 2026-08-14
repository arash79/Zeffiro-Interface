%ZEF_GET_DATA_COMPARTMENT_TABLE  Copy one compartment-table row onto zef.<tag>_*.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Called from zef_update inside the compartment loop. Needs
%   zef_i (table row), zef_j (tag index), zef.aux_field_1 (table Data).
%   Column map: 2 On, 3 Name, 4 Visible, 7 Merge, 8 Invert, 9 Activity
%   (ColumnFormat{9} index minus 2 -> <tag>_sources).
eval(['zef.' zef.compartment_tags{zef_j}, '_on = ' num2str(double(zef.aux_field_1{zef_i,2})) ';']); % col 2 On
eval(['zef.' zef.compartment_tags{zef_j}, '_name = ''' zef.aux_field_1{zef_i,3} ''';']); % col 3 Name
eval(['zef.' zef.compartment_tags{zef_j}, '_visible = ' num2str(double(zef.aux_field_1{zef_i,4})) ';']); % col 4 Visible
eval(['zef.' zef.compartment_tags{zef_j}, '_merge = ' num2str(double(zef.aux_field_1{zef_i,7})) ';']); % col 7 Merge
eval(['zef.' zef.compartment_tags{zef_j}, '_invert = ' num2str(double(zef.aux_field_1{zef_i,8})) ';']); % col 8 Invert normal
% Activity popup index minus 2 → <tag>_sources (-1 PML, 0 inactive, 1+ sources)
eval(['zef.' zef.compartment_tags{zef_j}, '_sources = ' num2str(find(ismember(zef.h_compartment_table.ColumnFormat{9},zef.aux_field_1{zef_i,9}),1)-2) ';']);
