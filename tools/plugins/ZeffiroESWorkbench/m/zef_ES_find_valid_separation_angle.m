function angles_list = zef_ES_find_valid_separation_angle
% --- Zeffiro documentation header ---
% angles_list — Angles list.
%
% Purpose:
%   Angles list.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Calls (project):
%   zef_ES_4x1_sensors
%   zef_ES_find_valid_separation_angle
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `angles_list` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

ell = zeros(360,6);
for i = 0:359;
    ell(i+1) = i;
    ell(i+1,2:6) = zef_ES_4x1_sensors(i);
    ell(i+1,7) = length(ell(i+1,2:6)) == length(unique(ell(i+1,2:6)));
end
angles_list = ell(find(ell(:,7)),1:6); %#ok<FNDSB>
angles_list = array2table(angles_list(:,1:6),'Variablenames',{'Separation Angle','O','P1','P2','P3','P4'});
end
