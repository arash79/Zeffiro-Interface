% --- Zeffiro documentation header ---
% h_axes = gca; — H axes = gca;.
%
% Purpose:
%   H axes = gca;.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.nse_field (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `h_axes = gca;` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

h_axes = gca;
if isempty(findobj(allchild(h_axes),'Type','DataTip'))~=1
    h_datatip = findobj(allchild(h_axes),'Type','DataTip');
    zef.nse_field.sphere_x = [];
    zef.nse_field.sphere_y = [];
    zef.nse_field.sphere_z = [];
    for i=1:size(h_datatip)
    zef.nse_field.sphere_x = [zef.nse_field.sphere_x h_datatip(i).X];
    zef.nse_field.sphere_y = [zef.nse_field.sphere_y h_datatip(i).Y];
    zef.nse_field.sphere_z = [zef.nse_field.sphere_z h_datatip(i).Z];
    end
    zef.nse_field.h_sphere_x.Value = num2str(zef.nse_field.sphere_x);
    zef.nse_field.h_sphere_y.Value = num2str(zef.nse_field.sphere_y);
    zef.nse_field.h_sphere_z.Value = num2str(zef.nse_field.sphere_z);

end
