function exportSegmentationSTLs(zef, inFolder, outFolder, inflation_parameter, freesurfer_subject_folder)
%EXPORTSEGMENTATIONSTLS  Wrapper intending coregistration-mode STL export.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Calls export_segmentation_meshes with a 6th positional struct
%   alignment_mode='coregistration'. The worker expects name-value options,
%   not a positional struct — prefer export_segmentation_meshes(...,
%   'alignment_mode','coregistration') or utilities.sn2zef.run.
%


    utilities.sn2zef.export_segmentation_meshes(zef, inFolder, outFolder, ...
        inflation_parameter, freesurfer_subject_folder, ...
        struct('alignment_mode', 'coregistration', 'verbose', false));

end % function
