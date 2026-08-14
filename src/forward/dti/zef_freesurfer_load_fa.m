function [fa_data, fa_info] = zef_freesurfer_load_fa(fa_file)
%ZEF_FREESURFER_LOAD_FA  Load FreeSurfer fa.nii.gz fractional anisotropy volume.
%
%   Zeffiro Interface.
%   Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   niftiread + niftiinfo. Converts to single. Clamps slightly negative FA
%   to 0 and warns if values exceed ~1. Called from DTI Conductivity Tool
%   Load (zef_dti_conductivity_load_freesurfer).
%
%   [fa_data, fa_info] = zef_freesurfer_load_fa(fa_file)
%
%   Input  fa_file - path to fa.nii.gz
%   Output fa_data - [nx ny nz] single; fa_info - niftiinfo struct (affine)
%
%   See also zef_freesurfer_load_v1, zef_dti_apply_to_sigma.




arguments
    fa_file (1,1) string
end

% Check if file exists
if ~isfile(fa_file)
    error('FA file not found: %s', fa_file);
end

try
    % Read FA data
    fa_data = niftiread(fa_file);
    
    % Read NIfTI info (contains transformation matrix)
    fa_info = niftiinfo(fa_file);
    
    % Convert to single precision to save memory
    fa_data = single(fa_data);
    
    % Validate FA range (typically 0-1, but can be slightly higher)
    fa_min = min(fa_data(:));
    fa_max = max(fa_data(:));
    
    % FA should be in [0,1] range, but allow slight overflow and normalize
    if fa_min < -0.01
        warning('FA values have negative values: min=%.3f. Clamping to [0,1].', fa_min);
        fa_data = max(0, fa_data);
    end
    if fa_max > 1.01
        warning('FA values exceed 1.0: max=%.3f. Normalizing to [0,1] range.', fa_max);
        % Normalize to [0,1] instead of clamping
        fa_data = fa_data / fa_max;
    end
    
catch ME
    error('Failed to load FA file %s: %s', fa_file, ME.message);
end

end
