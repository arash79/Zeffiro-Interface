%ZEF_INIT_PARAMETER_PROFILE  Create missing zef.<tag>_<param> fields from the profile (script).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. For enabled Segmentation rows, if
%   zef.<compartment_tags{j}>_<profile{i,2}> is missing, creates it from
%   the profile default (column 4). For enabled Sensors rows, creates
%   empty zef.<sensor_tags{j}>_<param> arrays. Does not open
%   Settings → Parameter profile (that is zef_open_parameter_profile).
%
%   See also zef_open_parameter_profile.
for zef_i = 1 : size(zef.parameter_profile,1)

    for zef_j = 1 : length(zef.compartment_tags)

        if isequal(zef.parameter_profile{zef_i,8},'Segmentation') && isequal(zef.parameter_profile{zef_i,6},'On')

            if not(eval(['isfield(zef,' '''' zef.compartment_tags{zef_j} '_' zef.parameter_profile{zef_i,2} '''' ');']))
                if isequal(zef.parameter_profile{zef_i,3},'Scalar')
                    eval(['zef.' zef.compartment_tags{zef_j} '_' zef.parameter_profile{zef_i,2} '= ' num2str(zef.parameter_profile{zef_i,4}) ';']);
                elseif isequal(zef.parameter_profile{zef_i,3},'String')
                    eval(['zef.' zef.compartment_tags{zef_j} '_' zef.parameter_profile{zef_i,2} '= ' (zef.parameter_profile{zef_i,4}) ';']);
                end
            end

        end

    end

    for zef_j = 1 : length(zef.sensor_tags)

        if isequal(zef.parameter_profile{zef_i,8},'Sensors') && isequal(zef.parameter_profile{zef_i,6},'On')

            if not(eval(['isfield(zef,' '''' zef.sensor_tags{zef_j} '_' zef.parameter_profile{zef_i,2} '''' ');']))
                eval(['zef.' zef.sensor_tags{zef_j} '_' zef.parameter_profile{zef_i,2} '= [];']);
            end

        end

    end

end

clear zef_i zef_j
