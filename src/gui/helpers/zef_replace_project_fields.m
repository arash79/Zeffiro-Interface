% --- Zeffiro documentation header ---
% if zef.current_version <= 2 — If zef.current version <= 2.
%
% Purpose:
%   If zef.current version <= 2.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.active_compartment_ind (read, write)
%   zef.brain_ind (read)
%   zef.current_version (read)
%   zef.d (read)
%   zef.domain_labels (read, write)
%   zef.domain_labels_raw (read, write)
%   zef.sigma (read)
%   zef.sigma_ind (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if zef.current_version <= 2` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

if zef.current_version <= 2.2
    for zef_i = 1 : 22
        eval(['zef.d' num2str(zef_i) '_priority =' num2str(28-zef_i) ';']);
    end
end
clear zef_i

if zef.current_version < 4

    if isempty(zef.active_compartment_ind) &&  isfield(zef,'brain_ind')
        zef.active_compartment_ind = zef.brain_ind;
    end

    if isfield(zef,'sigma_ind') && isempty(zef.domain_labels_raw)
        zef.domain_labels_raw = zef.sigma_ind;
    end

    if isfield(zef,'sigma') && isempty(zef.domain_labels)
        if not(isempty(zef.sigma))
            zef.domain_labels= zef.sigma(:,2);
        end
    end

    if isfield(zef,'nodes_b')
        zef = rmfield(zef,'nodes_b');
    end

    if isfield(zef,'tetra_aux')
        zef = rmfield(zef,'tetra_aux');
    end

end
