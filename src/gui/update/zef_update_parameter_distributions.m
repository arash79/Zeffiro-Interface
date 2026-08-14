function zef = zef_update_parameter_distributions(zef)
%ZEF_UPDATE_PARAMETER_DISTRIBUTIONS  Expand per-compartment scalars onto tetra labels.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Function. For each parameter_profile row with type Segmentation,
%   Scalar, and column 6 On, allocates zef.<param> as n_tetra-by-2:
%   column 2 = zef.domain_labels, column 1 = that compartment's
%   zef.<tag>_<param> on matching labels. Used by Visualize volume when
%   volumetric_distribution_mode is a profile parameter (2/3). Does not
%   plot.
%
%   See also zef_init_parameter_profile, zef_plot_volume.
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
