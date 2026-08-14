%ZEF_DECISION_SCRIPT_FOCAL_EPILEPSY  Cluster live databank reconstructions and plot.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. zef_parameters_focal_epilepsy then
%   [z_inverse_results, z_inverse_info] =
%   zef_dataBank_get_reconstructions(zef, frame_number). Then helpers
%   zef_cluster_reconstructions_focal_epilepsy,
%   zef_final_reconstruction_focal_epilepsy,
%   zef_show_results_focal_epilepsy. Needs workspace zef with a populated
%   dataBank and (if supervised_clustering is 'on') the credibility .mat
%   named by credibility_data_file_name.
%
%   See also zef_find_reconstructions_focal_epilepsy,
%   zef_cluster_reconstructions_focal_epilepsy.

examples.studies.decision_making.zef_parameters_focal_epilepsy;
[z_inverse_results, z_inverse_info] = zef_dataBank_get_reconstructions(zef, frame_number);
examples.studies.decision_making.helpers.zef_cluster_reconstructions_focal_epilepsy;
examples.studies.decision_making.helpers.zef_final_reconstruction_focal_epilepsy;
examples.studies.decision_making.helpers.zef_show_results_focal_epilepsy;
