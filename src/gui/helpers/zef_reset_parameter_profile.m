%ZEF_RESET_PARAMETER_PROFILE  Script: write parameter_profile defaults onto zef.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script, not a function. Needs zef in the caller (and base) workspace.
%   For each parameter_profile row with column 6 'On':
%     column 8 'Segmentation' → for every compartment_tag, set
%       zef.<tag>_<column2> to column 4 (num2str eval if Scalar, raw
%       eval if String)
%     column 8 'Sensors' → for every sensor_tag, set
%       zef.<tag>_<column2> = []
%
%   No first-party callers. Parameter profile Apply / init uses
%   zef_apply_parameter_profile (re-reads zeffiro_parameters.ini, then
%   zef_init_parameter_profile).
%
%   See also zef_apply_parameter_profile, zef_open_parameter_profile.
for zef_i = 1 : size(zef.parameter_profile,1)

    for zef_j = 1 : length(zef.compartment_tags)

        if isequal(zef.parameter_profile{zef_i,8},'Segmentation') && isequal(zef.parameter_profile{zef_i,6},'On')

            % if not(evalin('base',['isfield(zef,' '''' zef.compartment_tags{zef_j} '_' zef.parameter_profile{zef_i,2} '''' ');']))
            if isequal(zef.parameter_profile{zef_i,3},'Scalar')
                evalin('base',['zef.' zef.compartment_tags{zef_j} '_' zef.parameter_profile{zef_i,2} '= ' num2str(zef.parameter_profile{zef_i,4}) ';']);
            elseif isequal(zef.parameter_profile{zef_i,3},'String')
                evalin('base',['zef.' zef.compartment_tags{zef_j} '_' zef.parameter_profile{zef_i,2} '= ' (zef.parameter_profile{zef_i,4}) ';']);
            end
            %end

        end

    end

    for zef_j = 1 : length(zef.sensor_tags)

        if isequal(zef.parameter_profile{zef_i,8},'Sensors') && isequal(zef.parameter_profile{zef_i,6},'On')

            % if not(evalin('base',['isfield(zef,' '''' zef.sensor_tags{zef_j} '_' zef.parameter_profile{zef_i,2} '''' ');']))
            evalin('base',['zef.' zef.sensor_tags{zef_j} '_' zef.parameter_profile{zef_i,2} '= [];']);
            % end

        end

    end

end

clear zef_i zef_j
