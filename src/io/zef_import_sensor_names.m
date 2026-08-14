%ZEF_IMPORT_SENSOR_NAMES  Load sensor name list from a DAT file into zef.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Prompts uigetfile for *.dat, reads whitespace-delimited names, assigns
%   them to zef.<current_sensors>_name_list in the base workspace, and
%   refreshes the sensor name table via zef_init_sensors_name_table.
%
%   See also zef_import_segmentation, zef_build_sensors_table.

[zef.file,zef.file_path] = uigetfile('*.dat');

if not(isequal(zef.file,0))

    zef.h_aux = fopen([zef.file_path '/' zef.file]);
    zef.aux_field = textscan(zef.h_aux,'%s');

    for zef_i = 1 : length(zef.aux_field{1})
        evalin('base',['zef.' zef.current_sensors '_name_list{' num2str(zef_i) '} = ''' zef.aux_field{1}{zef_i} ''';']);
    end

    zef_init_sensors_name_table;

end

zef = rmfield(zef,{'h_aux','aux_field'});

clear zef_i;
