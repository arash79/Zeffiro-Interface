function strip_struct = zef_get_strip_parameters(strip_struct)
% --- Zeffiro documentation header ---
% zef_get_strip_parameters — Zef get strip parameters.
%
% Purpose:
%   Zef get strip parameters.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   strip_struct
%
% Outputs:
%   strip_struct
%
% Calls (project):
%   zef_get_strip_parameters
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[strip_struct] = zef_get_strip_parameters(strip_struct)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if isequal(strip_struct.strip_model,1)
strip_struct.strip_radius = 0.635;
strip_struct.strip_n_contacts = 4;
elseif isequal(strip_struct.strip_model,2)
strip_struct.strip_radius = 0.635;
strip_struct.strip_n_contacts = 8;
elseif isequal(strip_struct.strip_model,3)
strip_struct.strip_radius = 0.635;
strip_struct.strip_n_contacts = 40;
end

end
