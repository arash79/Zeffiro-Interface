function out_L = zef_set_lead_field_zero_potential( ...
% --- Zeffiro documentation header ---
% out_L — Out L.
%
% Purpose:
%   Out L.
%   Folder: Sensor lead-field matrices (EEG, MEG, EIT, TES, gravity) and `zef_lead_field_matrix` dispatch on `core.types.ZefSourceModel`.
%
% Inputs:
%   in_L
%   in_electrodes
%
% Calls (project):
%   zef_set_lead_field_zero_potential
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `out_L(in_L, in_electrodes)` with project root and `src` on the path.
% --- End Zeffiro documentation header
    in_L, ...
    in_electrodes ...
    )

arguments
    in_L double
    in_electrodes double
end

n_of_electrodes = size(in_electrodes, 1);

zero_potential_setter = ...
    eye(n_of_electrodes,n_of_electrodes) ...
    - ...
    (1/n_of_electrodes) ...
    * ...
    ones(n_of_electrodes,n_of_electrodes) ...
    ;

out_L = zero_potential_setter * in_L;

end
