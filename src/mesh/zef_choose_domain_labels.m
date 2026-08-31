function [domain_labels, subcompartment_labeling_priority_vec, compartment_labeling_priority_vec] = zef_choose_domain_labels(zef, label_array, use_labeling_priority, ordinal_index)
%ZEF_CHOOSE_DOMAIN_LABELS  Pick one domain label per tet from candidate columns.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Builds a priority rank per submesh (and per compartment). If
%   use_labeling_priority is true, starts from each
%   zef.<tag>_labeling_priority (tag from compartment_tags{reuna_mesh_ind});
%   zeros are replaced by reverse index n…1 offset by the max stored
%   priority. If false, priority is only that reverse index.
%
%   When label_array is nonempty (n_tet-by-k candidate submesh indices,
%   typically the node labels of a tet's vertices), each row keeps the
%   column with the smallest priority. ordinal_index > 1 NaNs out the
%   first ordinal_index-1 minima before taking min (default 1). Empty
%   label_array leaves domain_labels []. Returned priority vectors are
%   then converted to ranks (1 = highest priority).
%
%   Callers: zef_mesh_labeling_step (initial labeling); zef_mesh_relabeling
%   when use_labeling_priority; zef_update_labeling_priority (third output
%   only, with empty label_array) for the Mesh-tool labeling-priority list.
%   Callers always pass use_labeling_priority; nargin<3 only sets an unused
%   local priority_mode.
%
%   [domain_labels, sub_pri, comp_pri] = zef_choose_domain_labels(zef, label_array, use_labeling_priority)
%   [domain_labels, sub_pri, comp_pri] = zef_choose_domain_labels(zef, label_array, use_labeling_priority, ordinal_index)
%
%   Inputs
%     zef                    - session with reuna_p, reuna_submesh_ind,
%                              reuna_mesh_ind, compartment_tags,
%                              <tag>_labeling_priority.
%     label_array            - n-by-k candidate labels, or [].
%     use_labeling_priority  - logical; use stored *_labeling_priority.
%     ordinal_index          - which min to take (default 1).
%
%   Outputs
%     domain_labels                         - n-by-1 chosen labels, or [].
%     subcompartment_labeling_priority_vec  - rank per submesh.
%     compartment_labeling_priority_vec     - rank per reuna_mesh_ind entry.
%
%   See also zef_mesh_labeling_step, zef_mesh_relabeling, zef_update_labeling_priority.
if nargin < 3
    priority_mode = 1; 
end

if nargin < 4
    ordinal_index = 1; 
end

domain_labels = [];

submesh_vec = cell2mat(zef.reuna_submesh_ind);
n_subcompartments = length(submesh_vec);
n_compartments = length(zef.reuna_mesh_ind);
subcompartment_labeling_priority_vec = zeros(n_subcompartments,1);
compartment_labeling_priority_vec = zeros(length(zef.reuna_mesh_ind),1);

priority_vec = flipud([1:n_subcompartments]');
priority_vec_compartments = flipud([1:n_compartments]');

if use_labeling_priority

counter_ind = 0;

for i = 1 : length(zef.reuna_p)

     compartment_labeling_priority_vec(i) = zef.([zef.compartment_tags{zef.reuna_mesh_ind(i)} '_labeling_priority']);

    for j = 1 : length(zef.reuna_submesh_ind{i})

     counter_ind = counter_ind + 1;
      subcompartment_labeling_priority_vec(counter_ind) = zef.([zef.compartment_tags{zef.reuna_mesh_ind(i)} '_labeling_priority']);

    end
end

priority_vec = max(subcompartment_labeling_priority_vec) + priority_vec;
priority_vec_compartments = max(compartment_labeling_priority_vec) + priority_vec_compartments;
I = find(subcompartment_labeling_priority_vec==0);
subcompartment_labeling_priority_vec(I) = priority_vec(I);
I = find(compartment_labeling_priority_vec==0);
compartment_labeling_priority_vec(I) = priority_vec_compartments(I);

else
subcompartment_labeling_priority_vec = priority_vec;
compartment_labeling_priority_vec = priority_vec_compartments;
end

if not(isempty(label_array))
n_labels = size(label_array,1);
ind_vec_aux = [1:n_labels]';
labeling_priority_vec_aux = subcompartment_labeling_priority_vec(label_array);
for i = 1 : ordinal_index-1
[priority_val priority_ind] = min(labeling_priority_vec_aux,[],2);
labeling_priority_vec_aux(ind_vec_aux + (priority_ind-1)*n_labels) = NaN; 
end
[priority_val priority_ind] = min(labeling_priority_vec_aux,[],2);
priority_ind = sub2ind(size(label_array),[1:size(label_array,1)]',priority_ind);
[domain_labels] = label_array(priority_ind);
end

[~, subcompartment_labeling_priority_vec] = sort(subcompartment_labeling_priority_vec);
subcompartment_labeling_priority_vec(subcompartment_labeling_priority_vec) = [1:length(subcompartment_labeling_priority_vec)];

[~, compartment_labeling_priority_vec] = sort(compartment_labeling_priority_vec);
compartment_labeling_priority_vec(compartment_labeling_priority_vec) = [1:length(compartment_labeling_priority_vec)];


end
