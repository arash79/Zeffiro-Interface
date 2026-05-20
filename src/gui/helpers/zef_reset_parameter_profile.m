% --- Zeffiro documentation header ---
% for zef_i = 1 : size(zef — For zef i = 1 : size(zef.
%
% Purpose:
%   For zef i = 1 : size(zef.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.compartment_tags (read)
%   zef.parameter_profile (read)
%   zef.sensor_tags (read)
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `for zef_i = 1 : size(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

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
