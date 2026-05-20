%Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%
%ZEF_FREESURFER_LOAD_FA
%
%Loads FreeSurfer dt_recon output FA (Fractional Anisotropy) map.
%This function loads the fa.nii.gz file directly from FreeSurfer's dt_recon output.
%
%FreeSurfer dt_recon outputs:
%  - fa.nii.gz: Fractional anisotropy map
%  - adc.nii.gz: Apparent diffusion coefficient
%  - lowb.nii.gz: Low b-value image
%  - register.dat: Registration matrix (use zef_freesurfer_read_register_dat)
%
%Inputs:
%   fa_file - Path to fa.nii.gz file (FreeSurfer dt_recon output)
%
%Outputs:
%   fa_data - [nx×ny×nz] FA values (0-1 range)
%   fa_info - NIfTI info structure (contains voxel-to-RAS transformation)
%
%Note: This function uses MATLAB's niftiread and niftiinfo (R2017b+).

function [fa_data, fa_info] = zef_freesurfer_load_fa(fa_file)

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
