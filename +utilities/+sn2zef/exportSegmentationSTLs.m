function exportSegmentationSTLs(zef, inFolder, outFolder, inflation_parameter, freesurfer_subject_folder)
% --- Zeffiro documentation header ---
% utilities.sn2zef.exportSegmentationSTLs — Export Segmentation STLs.
%
% Purpose:
%   Export Segmentation STLs.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   zef
%   inFolder
%   outFolder
%   inflation_parameter
%   freesurfer_subject_folder
%
% Outputs:
%   See function signature and code below.
%
% Calls (project):
%   utilities.sn2zef.exportSegmentationSTLs
%   utilities.sn2zef.export_segmentation_meshes
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `utilities.sn2zef.exportSegmentationSTLs(zef, inFolder, outFolder, inflation_parameter, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header

    utilities.sn2zef.export_segmentation_meshes(zef, inFolder, outFolder, ...
        inflation_parameter, freesurfer_subject_folder, ...
        struct('alignment_mode', 'coregistration', 'verbose', false));

end % function
