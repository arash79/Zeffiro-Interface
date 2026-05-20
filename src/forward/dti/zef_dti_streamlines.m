%Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%
%ZEF_DTI_STREAMLINES
%
%Generates DTI streamlines from principal directions and fractional anisotropy.
%This function is generic and works with any DTI data format, including
%FreeSurfer dt_recon outputs (v1.nii.gz for directions, fa.nii.gz for anisotropy).
%
%Inputs:
%   dti_directions - [nx×ny×nz×3] Principal eigenvector directions (normalized)
%   dti_anisotropy - [nx×ny×nz] Fractional anisotropy values
%   seed_point     - [1×3] Seed point in voxel coordinates
%   roi_radius     - Radius for initial direction sphere (default: 15)
%   n_dir          - Number of streamlines to generate (default: 10000)
%   step_size      - Step size in voxels (default: 1)
%   max_steps      - Maximum steps per streamline (default: 1000)
%   fa_thresh      - FA threshold for stopping (default: 0.15)
%
%Outputs:
%   dti_streamlines - Cell array of streamlines, each [N×3] points in voxel space

function dti_streamlines = zef_dti_streamlines(dti_directions,dti_anisotropy,seed_point,roi_radius,n_dir,step_size,max_steps,fa_thresh);

if nargin < 4
    roi_radius = 15;
end
if nargin < 5
n_dir = 10000;
end
if nargin < 6
step_size = 1;
end
if nargin < 7
max_steps = 1000;
end
if nargin < 8
fa_thresh = 0.15;
end

nx = size(dti_directions,1);
ny = size(dti_directions,2);
nz = size(dti_directions,3);

dirs = generate_sphere_directions(n_dir,roi_radius);

dti_streamlines = cell(n_dir,1);

for k = 1:n_dir
    init_dir = dirs(k,:);
    stream  = trace_streamline(seed_point, dti_directions, dti_anisotropy, step_size, max_steps, fa_thresh, init_dir);
    dti_streamlines{k} = stream;
end

end

function dirs = generate_sphere_directions(N,roi_radius)
    dirs = zeros(N,3);
    phi = (1 + sqrt(5)) / 2;
    for k = 0:N-1
        z  = 1 - 2*(k + 0.5)/N;
        r  = sqrt(max(0, 1 - z^2));
        theta = 2*pi * k/phi;
        x = r * cos(theta);
        y = r * sin(theta);
        dirs(k+1,:) = roi_radius*[x, y, z];
    end
end

function xyz = trace_streamline(seed_point, dti_directions, dti_anisotropy, step_size, max_steps, fa_thresh, init_dir)
    [nx,ny,nz,~] = size(dti_directions);
    
    pos = double(seed_point(:)');
    xyz = zeros(max_steps, 3);
    
    d0 = init_dir(:)';
    % Normalize initial direction for consistency with subsequent directions
    d0_norm = norm(d0);
    if d0_norm > 0
        d0_normalized = d0 / d0_norm;
    else
        d0_normalized = d0;
    end
    
    % Move from seed point using initial direction, but don't include seed point in output
    % This prevents all streamlines from starting at the same point (which creates a blob)
    pos = pos + d0;
    xyz(1,:) = pos;
    
    prev_dir = d0_normalized;
    k = 1;
    
    while k < max_steps
        ix = round(pos(1));
        iy = round(pos(2));
        iz = round(pos(3));
        
        if ix < 1 || ix > nx || iy < 1 || iy > ny || iz < 1 || iz > nz
            xyz = xyz(1:k,:);
            return;
        end
        
        v = squeeze(dti_directions(ix,iy,iz,:)).';
        fa = dti_anisotropy(ix,iy,iz);
        
        nrm = norm(v);
        if nrm == 0 || fa < fa_thresh
            xyz = xyz(1:k,:);
            return;
        end
        
        v = v / nrm;
        
        if dot(v, prev_dir) < 0
            v = -v;
        end
        prev_dir = v;
        
        pos = pos + step_size * v;
        k = k + 1;
        xyz(k,:) = pos;
    end
    
    xyz = xyz(1:k,:);

end
