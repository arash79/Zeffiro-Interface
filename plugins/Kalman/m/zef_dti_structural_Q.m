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
%   Name-values are forwarded to the covariance builders. FA: length_scale
%   (mm, 10), k_neighbors (50), use_direction. Tractography: fa_threshold
%   (0.15), step_size (0.5), max_steps (500), proximity_radius (3 voxels).
%   Common: normalize (true), source_direction_mode (override). Sparse Q
%   still densifies P after the first KF update.
%
%   See also zef_KF, zef_dti_fa_covariance, zef_dti_tractography_covariance,
%   zef_dti_interpolate_to_sources.

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
%   Mode 1 (Cartesian): blocked [X-block, Y-block, Z-block] from
%   zef_processLeadfields → dim = 3*N, Q = kron(I_3, Q_source).
%   Mode 2 (Normal):    [s1,s2,...,sN]            → dim = N
%   Mode 3 (Face):      [s1,s2,...,sN]            → dim = N

if sdm == 1
    Q = zef_dti_expand_source_covariance(Q_source, 1);
    fprintf('  Expanded Q from %d×%d to %d×%d (blocked 3-component L)\n', ...
        N, N, 3*N, 3*N);
else
    Q = zef_dti_expand_source_covariance(Q_source, sdm);
    fprintf('  Q size: %d×%d (1-component mode)\n', N, N);
end

fprintf('  Q: nnz=%d, density=%.4f%%, max=%.3e, trace=%.3e\n', ...
    nnz(Q), 100*nnz(Q)/numel(Q), full(max(Q(:))), full(trace(Q)));

end
