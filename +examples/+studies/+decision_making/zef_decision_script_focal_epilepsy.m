% --- Zeffiro documentation header ---
% examples.studies.decision_making.examples.studies.decision_making — Example or study script demonstrating examples.studies.decision_making.
%
% Purpose:
%   Example or study script demonstrating examples.studies.decision_making.
%   Folder: Runnable examples and study scripts that exercise meshing, forward lead fields, inverse solvers, importing, and published workflows.
%
% Calls (project):
%   zef_dataBank_get_reconstructions
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `examples.studies.decision_making.examples.studies.decision_making` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

examples.studies.decision_making.zef_parameters_focal_epilepsy;
[z_inverse_results, z_inverse_info] = zef_dataBank_get_reconstructions(zef, frame_number);
examples.studies.decision_making.helpers.zef_cluster_reconstructions_focal_epilepsy;
examples.studies.decision_making.helpers.zef_final_reconstruction_focal_epilepsy;
examples.studies.decision_making.helpers.zef_show_results_focal_epilepsy;
