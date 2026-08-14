function Q = zef_dti_structural_Q(zef, q_value, method, varargin)
%ZEF_DTI_STRUCTURAL_Q  DTI-informed Kalman Q from FA or tractography.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Q = zef_dti_structural_Q(zef, q_value, method)
%   Q = zef_dti_structural_Q(zef, q_value, method, Name, Value, ...)
%
%   Called from zef_KF when zef.kf_structural_Q_type is 1 (method 'fa') or 2
%   ('tractography'). THIS PLUGIN PATH ONLY — inverse.KalmanInverter does
%   not call these files. Interpolates zef.freesurfer_fa_data / v1 onto
%   zef.source_positions, then scales by q_value. Expands with kron(Q,I_3)
%   when source_direction_mode == 1.
%

%
%ZEF_DTI_STRUCTURAL_Q
%
%Builds a structurally informed process noise covariance matrix Q for the
%Kalman filter using DTI imaging data. Replaces the default diagonal
%Q = q_value * I with a matrix that encodes white matter connectivity.
%
%This is the top-level bridge function between the DTI conductivity
%pipeline and the Kalman filter inverse solver. It:
%  1. Interpolates DTI data (FA, v1) to Kalman source positions
%  2. Builds a structural covariance matrix using the chosen method
%  3. Scales by q_value (from find_evolution_prior)
%  4. Expands to full state dimension based on source_direction_mode
%
%Two methods are available:
%  'fa'            — FA-based covariance: uses fractional anisotropy values
%                    and optionally principal eigenvector directions to
%                    weight spatial correlations. Fast, sparse output.
%  'tractography'  — Tractography-based covariance: traces deterministic
%                    streamlines through the v1 field and builds connectivity
%                    from co-traversal. Requires v1 data. Slower but captures
%                    long-range connectivity.
%
%State dimension expansion:
%  source_direction_mode = 1 (Cartesian): state has 3 components per source
%    Q_full = kron(Q_source, I_3)  — same structural coupling for x,y,z
%  source_direction_mode = 2 or 3 (Normal/Face): 1 component per source
%    Q_full = Q_source
%
%Memory note:
%  Both methods produce sparse Q matrices. However, in the standard Kalman
%  filter, the state covariance P becomes dense after the first update step
%  regardless of Q's sparsity. For large source counts (>5000 in 3-component
%  mode), consider using the Ensemble Kalman Filter (filter_type=2) which
%  represents P through samples and handles structured Q naturally.
%
%Inputs:
%   zef      - Zeffiro struct with DTI data and source model
%   q_value  - Scalar scaling factor (typically from find_evolution_prior)
%   method   - 'fa' or 'tractography'
%
%Name-value options (passed through to covariance builders):
%   For FA method:
%     'length_scale'   - Spatial decay in mm (default: 10)
%     'k_neighbors'    - Nearest neighbors (default: 50)
%     'use_direction'  - Directional weighting (default: auto)
%   For tractography method:
%     'fa_threshold'      - Min FA for seeds (default: 0.15)
%     'step_size'         - Voxel step size (default: 0.5)
%     'max_steps'         - Max steps per direction (default: 500)
%     'proximity_radius'  - Max snap distance (default: 3 voxels)
%   Common:
%     'normalize'                - Normalize diagonal (default: true)
%     'source_direction_mode'    - Override zef.source_direction_mode
%
%Output:
%   Q - Sparse process noise covariance matrix, properly dimensioned
%       for the Kalman filter state vector
%
%Example:
%   % In zef_KF.m, replace Q = q_value*eye(size(L,2)) with:
%   Q = zef_dti_structural_Q(zef, q_value, 'fa');
%
%See also: zef_KF, zef_dti_fa_covariance, zef_dti_tractography_covariance,
%          zef_dti_interpolate_to_sources
%
arguments
    zef (1,1) struct
    q_value (1,1) double
    method (1,:) char {mustBeMember(method, {'fa', 'tractography'})}
end

arguments (Repeating)
    varargin
end

% ========================================================================
% PARSE OPTIONS
% ========================================================================

ip = inputParser;
ip.KeepUnmatched = true;
addParameter(ip, 'source_direction_mode', [], ...
    @(x) isempty(x) || ismember(x, [1 2 3]));
parse(ip, varargin{:});

sdm = ip.Results.source_direction_mode;
if isempty(sdm)
    if isfield(zef, 'source_direction_mode')
        sdm = zef.source_direction_mode;
    else
        sdm = 1;  % Default: Cartesian 3-component
    end
end

% Collect unmatched parameters to pass through to covariance builders
passthrough_fields = fieldnames(ip.Unmatched);
passthrough_values = struct2cell(ip.Unmatched);
passthrough = {};
for k = 1:length(passthrough_fields)
    passthrough = [passthrough, passthrough_fields(k), passthrough_values(k)]; %#ok<AGROW>
end

% ========================================================================
% VALIDATE SOURCE POSITIONS
% ========================================================================

if ~isfield(zef, 'source_positions') || isempty(zef.source_positions)
    error('zef_dti_structural_Q:noSources', ...
        'zef.source_positions not available. Run lead field computation first.');
end

source_positions = zef.source_positions;
N = size(source_positions, 1);

fprintf('Building structural Q (%s method) for %d sources (direction mode %d)\n', ...
    method, N, sdm);

% ========================================================================
% STEP 1: INTERPOLATE DTI DATA TO SOURCE POSITIONS
% ========================================================================

fprintf('  Step 1: Interpolating DTI data to source positions...\n');
[fa_sources, v1_sources] = zef_dti_interpolate_to_sources(zef, source_positions);

fprintf('  FA range at sources: [%.3f, %.3f], mean=%.3f\n', ...
    min(fa_sources), max(fa_sources), mean(fa_sources));

% ========================================================================
% STEP 2: BUILD STRUCTURAL COVARIANCE (N×N in source space)
% ========================================================================

fprintf('  Step 2: Building %s covariance matrix...\n', method);

switch method
    case 'fa'
        Q_source = zef_dti_fa_covariance(source_positions, fa_sources, ...
            v1_sources, passthrough{:});

    case 'tractography'
        Q_source = zef_dti_tractography_covariance(zef, source_positions, ...
            passthrough{:});
end

% ========================================================================
% STEP 3: SCALE BY Q_VALUE
% ========================================================================

Q_source = q_value * Q_source;

% ========================================================================
% STEP 4: EXPAND TO FULL STATE DIMENSION
% ========================================================================
% The Kalman filter state vector dimension depends on source_direction_mode:
%   Mode 1 (Cartesian): [x1,y1,z1,x2,y2,z2,...] → dim = 3*N
%   Mode 2 (Normal):    [s1,s2,...,sN]            → dim = N
%   Mode 3 (Face):      [s1,s2,...,sN]            → dim = N

if sdm == 1
    % 3-component mode: expand Q_source using Kronecker product
    % Q_full(3i+a, 3j+b) = Q_source(i,j) * delta(a,b)
    % This applies the same structural coupling to all 3 components
    Q = kron(Q_source, speye(3));
    fprintf('  Expanded Q from %d×%d to %d×%d (3-component mode)\n', ...
        N, N, 3*N, 3*N);
else
    % 1-component mode: Q_source is already the correct dimension
    Q = Q_source;
    fprintf('  Q size: %d×%d (1-component mode)\n', N, N);
end

fprintf('  Q: nnz=%d, density=%.4f%%, max=%.3e, trace=%.3e\n', ...
    nnz(Q), 100*nnz(Q)/numel(Q), full(max(Q(:))), full(trace(Q)));

end
