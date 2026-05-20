%Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%
%ZEF_FREESURFER_FA_TO_CONDUCTIVITY
%
%Converts FreeSurfer FA (fractional anisotropy) volume to a conductivity
%tensor volume [nx×ny×nz×6]. Optional v1 (principal eigenvector) defines
%the direction of anisotropy; conductivity and diffusion share the same
%eigenvectors (Tuch et al., PNAS 2002).
%
%Models (academic references):
%  1 = Volume fraction (Tuch-style): Isotropic base from two-phase mixture
%      sigma_iso = f*sigma_intra + (1-f)*sigma_extra; anisotropy from FA
%      with same eigenvectors as DTI. FA-based eigenvalue scaling preserves
%      trace and gives sigma_par/sigma_perp ratio increasing with FA.
%      Ref: Tuch et al., Conductivity tensor mapping of the human brain
%      using diffusion tensor MRI, PNAS 99(10):6667-6672, 2002.
%  2 = Effective medium (Tuch linear): sigma_nu = k*(d_nu - d_epsilon).
%      Uses Tuch's experimental linear fit (k ≈ 0.844 S·s/mm³, d_ε ≈ 0.124
%      μm²/ms). Diffusion eigenvalues d_nu are approximated from FA and
%      mean diffusivity when full DTI tensor is not available.
%      Ref: Same Tuch et al. PNAS 2002.
%  3 = Direct scaling: sigma = scale * (isotropic + anisotropy from FA).
%      Simple scaling of an FA-derived tensor; no biophysical parameters.
%
%Inputs:
%   fa_data    - [nx×ny×nz] FA values in [0,1]
%   model_type - 1, 2, or 3 (see above)
%   Optional name-value pairs:
%     'volume_fraction'      - scalar (default 0.7)
%     'extra_conductivity'   - scalar S/m (default 1.0)
%     'intra_conductivity'   - scalar S/m (default 0.6)
%     'scale_factor'        - scalar (default 0.33)
%     'anisotropy_threshold' - FA below this → isotropic (default 0.2)
%     'principal_direction'  - [nx×ny×nz×3] or empty (default [])
%     'mean_diffusivity'     - scalar μm²/ms, for model 2 only (default 0.7)
%
%Outputs:
%   conductivity_tensor - [nx×ny×nz×6] symmetric tensor (11,22,33,12,13,23)

function conductivity_tensor = zef_freesurfer_fa_to_conductivity(fa_data, model_type, varargin)

p = inputParser;
addRequired(p, 'fa_data', @isnumeric);
addRequired(p, 'model_type', @(x) isscalar(x) && ismember(x, [1 2 3]));
addParameter(p, 'volume_fraction', 0.7, @(x) isscalar(x) && isnumeric(x));
addParameter(p, 'extra_conductivity', 1.0, @(x) isscalar(x) && isnumeric(x));
addParameter(p, 'intra_conductivity', 0.6, @(x) isscalar(x) && isnumeric(x));
addParameter(p, 'scale_factor', 0.33, @(x) isscalar(x) && isnumeric(x));
addParameter(p, 'anisotropy_threshold', 0.2, @(x) isscalar(x) && isnumeric(x));
addParameter(p, 'principal_direction', [], @(x) isempty(x) || isnumeric(x));
addParameter(p, 'mean_diffusivity', 0.7, @(x) isscalar(x) && isnumeric(x) && x > 0);
parse(p, fa_data, model_type, varargin{:});

vf   = p.Results.volume_fraction;
sig_e = p.Results.extra_conductivity;
sig_i = p.Results.intra_conductivity;
scale = p.Results.scale_factor;
fa_min = p.Results.anisotropy_threshold;
v1    = p.Results.principal_direction;
md    = p.Results.mean_diffusivity;

fa_data = single(fa_data);
[nx, ny, nz] = size(fa_data);
N = nx * ny * nz;

% Principal direction: [nx,ny,nz,3] unit vectors (same as diffusion tensor)
if ~isempty(v1) && numel(v1) >= N * 3
    if ndims(v1) == 4 && size(v1,4) == 3
        v1 = reshape(v1, [], 3);
    else
        v1 = reshape(v1, [], 3);
    end
    nrm = sqrt(sum(v1.^2, 2)) + 1e-12;
    v1 = v1 ./ nrm;
else
    v1 = repmat([1 0 0], N, 1);
end

fa_flat = fa_data(:);
fa_flat = min(1, max(0, fa_flat));
low_fa = fa_flat < fa_min;

% Model 1: Volume fraction (Tuch-style). Isotropic base from mixture;
% anisotropy from FA with same eigenvectors; trace = 3*sigma_iso preserved.
if model_type == 1
    sigma_iso = vf * sig_i + (1 - vf) * sig_e;
    sigma_par = sigma_iso .* (1 + 2 * fa_flat);
    sigma_perp = sigma_iso .* (1 - fa_flat);
    sigma_par(low_fa) = sigma_iso;
    sigma_perp(low_fa) = sigma_iso;
end

% Model 2: Effective medium — Tuch linear relation sigma_nu = k*(d_nu - d_epsilon).
% k = 0.844 S·s/mm³, d_epsilon = 0.124 μm²/ms (Tuch et al. PNAS 2002).
% Proxy for d when only FA available: d_par = MD*(1+2*FA), d_perp = MD*(1-FA).
k_tuch = 0.844;   % S·s/mm³ → with d in μm²/ms gives sigma in S/m: 0.844 (d_um2_ms)
d_eps = 0.124;    % μm²/ms
if model_type == 2
    d_par = md .* (1 + 2 * fa_flat);
    d_perp = md .* (1 - fa_flat);
    sigma_par = k_tuch .* (d_par - d_eps);
    sigma_perp = k_tuch .* (d_perp - d_eps);
    sigma_par(low_fa) = k_tuch * (md - d_eps);
    sigma_perp(low_fa) = k_tuch * (md - d_eps);
    % Clamp to small positive for numerical stability (Tuch: conductivity can be low)
    sigma_min = 1e-4;
    sigma_par = max(sigma_par, sigma_min);
    sigma_perp = max(sigma_perp, sigma_min);
end

% Model 3: Direct scaling
if model_type == 3
    sigma_par = scale .* (1 + 2 * fa_flat);
    sigma_perp = scale .* (1 - fa_flat);
    sigma_par(low_fa) = scale;
    sigma_perp(low_fa) = scale;
end

% Build 3×3 tensor in voxel coordinates: T = sigma_par * v1*v1' + sigma_perp * (I - v1*v1')
% Then output as [s11 s22 s33 s12 s13 s23]
s11 = sigma_par .* (v1(:,1).^2) + sigma_perp .* (1 - v1(:,1).^2);
s22 = sigma_par .* (v1(:,2).^2) + sigma_perp .* (1 - v1(:,2).^2);
s33 = sigma_par .* (v1(:,3).^2) + sigma_perp .* (1 - v1(:,3).^2);
s12 = (sigma_par - sigma_perp) .* v1(:,1) .* v1(:,2);
s13 = (sigma_par - sigma_perp) .* v1(:,1) .* v1(:,3);
s23 = (sigma_par - sigma_perp) .* v1(:,2) .* v1(:,3);

conductivity_tensor = zeros(nx, ny, nz, 6, 'single');
conductivity_tensor(:,:,:,1) = reshape(s11, nx, ny, nz);
conductivity_tensor(:,:,:,2) = reshape(s22, nx, ny, nz);
conductivity_tensor(:,:,:,3) = reshape(s33, nx, ny, nz);
conductivity_tensor(:,:,:,4) = reshape(s12, nx, ny, nz);
conductivity_tensor(:,:,:,5) = reshape(s13, nx, ny, nz);
conductivity_tensor(:,:,:,6) = reshape(s23, nx, ny, nz);

end
