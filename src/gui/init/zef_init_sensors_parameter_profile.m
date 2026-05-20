% --- Zeffiro documentation header ---
% for zef_j = 1 : size(zef — For zef j = 1 : size(zef.
%
% Purpose:
%   For zef j = 1 : size(zef.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.current_sensors (read)
%   zef.parameter_profile (read)
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `for zef_j = 1 : size(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

for zef_j = 1 : size(zef.parameter_profile,1)
    if isequal(zef.parameter_profile{zef_j,8},'Sensors') && isequal(zef.parameter_profile{zef_j,6},'On') && isequal(zef.parameter_profile{zef_j,7},'On')
        if not(isequal(evalin('base', ['size(zef.' zef.current_sensors '_points,1)']),evalin('base', ['size(zef.' zef.current_sensors '_' zef.parameter_profile{zef_j,2} ',1)'])))
            if isequal(zef.parameter_profile{zef_j,3},'Scalar')
                evalin('base', ['zef.' zef.current_sensors '_' zef.parameter_profile{zef_j,2} '=' num2str(zef.parameter_profile{zef_j,4}) '*ones(size(zef.' zef.current_sensors '_points,1),1);']);
            elseif isequal(zef.parameter_profile{zef_j,3},'String')
                evalin('base', ['zef.' zef.current_sensors '_' zef.parameter_profile{zef_j,2} '=' (zef.parameter_profile{zef_j,4}) '*ones(size(zef.' zef.current_sensors '_points,1),1);']);
            end
        end
    end
end
