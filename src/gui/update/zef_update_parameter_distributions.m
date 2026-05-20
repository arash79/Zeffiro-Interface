function zef = zef_update_parameter_distributions(zef)
% --- Zeffiro documentation header ---
% zef_update_parameter_distributions — Syncs GUI control values into `zef` for parameter_distributions.
%
% Purpose:
%   Syncs GUI control values into `zef` for parameter_distributions.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.compartment_tags (read)
%   zef.domain_labels (read, write)
%   zef.parameter_profile (read)
%
% Calls (project):
%   zef_update_parameter_distributions
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_update_parameter_distributions(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


parameter_profile = eval('zef.parameter_profile');

for zef_j = 1 : size(parameter_profile,1)
    if isequal(parameter_profile{zef_j,8},'Segmentation') && isequal(parameter_profile{zef_j,3},'Scalar') && isequal(parameter_profile{zef_j,6},'On')
        eval(['zef.' parameter_profile{zef_j,2} '= zeros(size(zef.domain_labels,1),2);']);
        eval(['zef.' parameter_profile{zef_j,2} '(:,2) = zef.domain_labels;';]);
        for zef_i = 1 : length(zef.compartment_tags)
            I = find(zef.domain_labels == zef_i);
            eval(['zef.' parameter_profile{zef_j,2} '(I,1) = zef.' zef.compartment_tags{zef_i} '_' parameter_profile{zef_j,2} ';']);
        end
    end
end

end
