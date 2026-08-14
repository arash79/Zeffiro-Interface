%ZEF_REPLACE_PROJECT_FIELDS  Rename legacy project fields after load (script).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script on zef in the caller workspace.
%     current_version <= 2.2: d1..d22_priority = 27..6
%     current_version < 4: active_compartment_ind from brain_ind;
%       domain_labels_raw from sigma_ind; domain_labels from sigma(:,2);
%       drop nodes_b and tetra_aux if present
%   Called from the project-load path so old .mat files match current names.

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
