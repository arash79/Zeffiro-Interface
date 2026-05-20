%Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%
%ZEF_FREESURFER_LOAD_V1
%
%Loads FreeSurfer dt_recon output v1.nii.gz (principal eigenvector).
%This is needed for streamline visualization.

function [v1_data, v1_info] = zef_freesurfer_load_v1(v1_file)

arguments
    v1_file (1,1) string
end

% Check if file exists
if ~isfile(v1_file)
    error('v1 file not found: %s', v1_file);
end

try
    % Read v1 data (principal eigenvector, 3 components)
    v1_data = niftiread(v1_file);
    
    % Read NIfTI info
    v1_info = niftiinfo(v1_file);
    
    % Convert to single precision
    v1_data = single(v1_data);
    
    % Validate dimensions - should be [nx, ny, nz, 3] for vector field
    v1_dims = size(v1_data);
    if length(v1_dims) == 3
        % Single component - this shouldn't happen for v1, but handle it
        error('v1 file appears to be scalar (3D), expected vector field (4D with 3 components)');
    elseif length(v1_dims) == 4 && v1_dims(4) == 3
        % Correct format: [nx, ny, nz, 3]
        % Normalize vectors efficiently using vectorized operations
        [nx, ny, nz, ~] = size(v1_data);
        v1_reshaped = reshape(v1_data, [nx*ny*nz, 3]);
        v1_norms = sqrt(sum(v1_reshaped.^2, 2));
        v1_norms(v1_norms < 1e-6) = 1;  % Avoid division by zero
        v1_reshaped = v1_reshaped ./ v1_norms;
        v1_data = reshape(v1_reshaped, [nx, ny, nz, 3]);
    else
        error('v1 file has unexpected dimensions: [%s]. Expected [nx, ny, nz, 3].', mat2str(v1_dims));
    end
    
catch ME
    error('Failed to load v1 file %s: %s', v1_file, ME.message);
end

end
