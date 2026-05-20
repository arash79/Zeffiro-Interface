%% DTI Structural Covariance Matrix — Test & Visualization
%
% This script demonstrates two approaches for building a structural
% covariance matrix from DTI imaging data for Kalman-filter-based EEG
% source localization:
%
%   1. FA-based:           Fractional anisotropy weighted spatial covariance
%   2. Tractography-based: Streamline-derived structural connectivity
%
% The script loads FreeSurfer dt_recon outputs, interpolates DTI data to
% source positions, builds both covariance matrices, and presents a clean
% side-by-side visualization.
%
% REQUIREMENTS:
%   - FreeSurfer dt_recon outputs:
%       fa.nii.gz      — Fractional anisotropy map
%       v1.nii.gz      — Principal eigenvector field
%       register.dat   — DWI-to-anatomy registration
%   - FreeSurfer reference MRI:
%       orig.mgz       — Anatomical reference (for coordinate transforms)
%   - FREESURFER_HOME environment variable set
%   - Either: existing Zeffiro project with mesh loaded (zef in workspace)
%        Or:  source positions will be generated from the FA volume
%
% HOW TO RUN:
%   1. Set your file paths in Section 1 below
%   2. Run the entire script (Ctrl+Enter or F5)
%   3. Examine the figure with both covariance matrices
%
% Copyright © 2024- Sampsa Pursiainen & ZI Development Team

%% ========================================================================
%  SECTION 1: CONFIGURATION — Set your file paths here
%  ========================================================================

% --- FreeSurfer dt_recon output files ---
fa_file       = '/Users/hsc476/freesurfer_subjects/Sub01FG/mri/dti/fa.nii.gz';  % e.g., '/path/to/dt_recon/fa.nii.gz'
v1_file       = '/Users/hsc476/freesurfer_subjects/Sub01FG/mri/dti/eigvec1.nii.gz';  % e.g., '/path/to/dt_recon/v1.nii.gz'
register_file = '/Users/hsc476/freesurfer_subjects/Sub01FG/mri/dti/register.dat';  % e.g., '/path/to/dt_recon/register.dat'

% --- FreeSurfer reference MRI ---
ref_mri_file  = '/Users/hsc476/freesurfer_subjects/Sub01FG/mri/orig.mgz';  % e.g., '/path/to/mri/orig.mgz'

% --- Interactive file selection (if paths are empty) ---
if isempty(fa_file) || ~isfile(fa_file)
    [fname, fpath] = uigetfile({'*.nii.gz;*.nii', 'NIfTI files'}, ...
        'Select FA file (fa.nii.gz)');
    if isequal(fname, 0), error('FA file selection cancelled.'); end
    fa_file = fullfile(fpath, fname);
end

if isempty(v1_file) || ~isfile(v1_file)
    [fname, fpath] = uigetfile({'*.nii.gz;*.nii', 'NIfTI files'}, ...
        'Select v1 file (v1.nii.gz)', fileparts(fa_file));
    if isequal(fname, 0), error('v1 file selection cancelled.'); end
    v1_file = fullfile(fpath, fname);
end

if isempty(register_file) || ~isfile(register_file)
    [fname, fpath] = uigetfile({'*.dat;*.*', 'register.dat'}, ...
        'Select register.dat', fileparts(fa_file));
    if isequal(fname, 0), error('register.dat selection cancelled.'); end
    register_file = fullfile(fpath, fname);
end

if isempty(ref_mri_file) || ~isfile(ref_mri_file)
    [fname, fpath] = uigetfile({'*.mgz;*.mgh;*.nii.gz;*.nii', 'MRI files'}, ...
        'Select reference MRI (orig.mgz)');
    if isequal(fname, 0), error('Reference MRI selection cancelled.'); end
    ref_mri_file = fullfile(fpath, fname);
end

fprintf('\n=== DTI Structural Covariance Test ===\n');
fprintf('  FA file:        %s\n', fa_file);
fprintf('  v1 file:        %s\n', v1_file);
fprintf('  register.dat:   %s\n', register_file);
fprintf('  Reference MRI:  %s\n\n', ref_mri_file);

%% ========================================================================
%  SECTION 2: LOAD DTI DATA
%  ========================================================================

fprintf('--- Loading DTI data ---\n');

% Load FA
fprintf('  Loading FA...\n');
[fa_data, fa_info] = zef_freesurfer_load_fa(fa_file);
fprintf('    FA volume size: [%d × %d × %d]\n', size(fa_data));
fprintf('    FA range: [%.3f, %.3f], mean=%.3f\n', ...
    min(fa_data(:)), max(fa_data(:)), mean(fa_data(:)));

% Load v1
fprintf('  Loading v1 (principal eigenvector)...\n');
[v1_data, ~] = zef_freesurfer_load_v1(v1_file);
fprintf('    v1 volume size: [%s]\n', mat2str(size(v1_data)));

% Load register.dat
fprintf('  Loading register.dat...\n');
T_register = zef_freesurfer_read_register_dat(register_file);
fprintf('    Registration matrix loaded (det=%.4f)\n', det(T_register));

% Read reference MRI geometry
fprintf('  Reading reference MRI geometry...\n');
ref_geom = zef_freesurfer_read_volume_geometry(ref_mri_file);
fprintf('    Reference dimensions: [%s]\n', mat2str(ref_geom.dimensions));
fprintf('    Reference center RAS: [%.2f, %.2f, %.2f]\n', ref_geom.center_ras);

%% ========================================================================
%  SECTION 3: SET UP ZEF STRUCT WITH DTI DATA
%  ========================================================================

fprintf('\n--- Setting up coordinate transforms ---\n');

% Check if zef exists in workspace (from a loaded Zeffiro project)
use_existing_zef = evalin('base', 'exist(''zef'', ''var'')');

if use_existing_zef
    fprintf('  Found existing zef in workspace. Using its mesh and sources.\n');
    zef_test = evalin('base', 'zef');
else
    fprintf('  No existing zef found. Creating standalone test struct.\n');
    zef_test = struct();
end

% Populate DTI fields
zef_test.freesurfer_fa_data = fa_data;
zef_test.freesurfer_fa_info = fa_info;
zef_test.freesurfer_fa_file = fa_file;
zef_test.freesurfer_v1_data = v1_data;
zef_test.freesurfer_register_transform = T_register;
zef_test.dti_ref_geometry = ref_geom;

% Also set the individual transform fields for zef_dti_get_mesh2voxel
zef_test.dti_ref_vox2ras     = ref_geom.vox2ras;
zef_test.dti_ref_vox2ras_tkr = ref_geom.vox2ras_tkr;
zef_test.dti_ref_center      = ref_geom.center_ras;

% Auto-extract FA vox2ras-tkr from the FA file geometry
fa_geom = zef_freesurfer_read_volume_geometry(fa_file);
zef_test.dti_dwi_vox2ras_tkr = fa_geom.vox2ras_tkr;

fprintf('  Coordinate transforms configured.\n');

% Verify transformation
T_mesh2voxel = zef_dti_get_mesh2voxel(zef_test);
fprintf('  mesh→voxel transform computed successfully (det=%.4f)\n', det(T_mesh2voxel));

%% ========================================================================
%  SECTION 4: SOURCE POSITIONS
%  ========================================================================

fprintf('\n--- Source positions ---\n');

if isfield(zef_test, 'source_positions') && ~isempty(zef_test.source_positions)
    source_positions = zef_test.source_positions;
    fprintf('  Using %d source positions from Zeffiro project\n', ...
        size(source_positions, 1));
else
    % Generate source positions from a grid within the brain (FA > 0.2)
    fprintf('  Generating source positions from FA volume (grid sampling)...\n');

    % Create a grid in FA voxel space, keep points with FA > 0.2
    [nx, ny, nz] = size(fa_data);
    grid_step = 4;  % Every 4th voxel for manageable size
    [gx, gy, gz] = ndgrid(1:grid_step:nx, 1:grid_step:ny, 1:grid_step:nz);
    grid_pts_vox_1based = [gx(:), gy(:), gz(:)];

    % Interpolate FA at grid points
    F_fa = griddedInterpolant({double(1:nx), double(1:ny), double(1:nz)}, ...
        double(fa_data), 'linear', 'nearest');
    fa_at_grid = F_fa(grid_pts_vox_1based(:,1), ...
                      grid_pts_vox_1based(:,2), ...
                      grid_pts_vox_1based(:,3));

    % Keep points in brain tissue (FA > 0.1)
    brain_mask = fa_at_grid > 0.1;
    grid_pts_brain = grid_pts_vox_1based(brain_mask, :);

    % Transform from FA voxel (1-based) to mesh display space
    % Inverse of T_mesh2voxel, accounting for 0-based offset
    T_voxel2mesh = inv(T_mesh2voxel);  %#ok<MINV>
    pts_vox_0based = [grid_pts_brain(:,1)-1, grid_pts_brain(:,2)-1, ...
                      grid_pts_brain(:,3)-1, ones(size(grid_pts_brain,1),1)];
    pts_mesh = (T_voxel2mesh * pts_vox_0based')';
    source_positions = pts_mesh(:, 1:3);

    zef_test.source_positions = source_positions;
    fprintf('  Generated %d source positions (from %d grid points, FA > 0.1)\n', ...
        size(source_positions, 1), size(grid_pts_vox_1based, 1));
end

N = size(source_positions, 1);
fprintf('  Total sources: %d\n', N);
fprintf('  Bounding box: [%.1f,%.1f] × [%.1f,%.1f] × [%.1f,%.1f] mm\n', ...
    min(source_positions(:,1)), max(source_positions(:,1)), ...
    min(source_positions(:,2)), max(source_positions(:,2)), ...
    min(source_positions(:,3)), max(source_positions(:,3)));

%% ========================================================================
%  SECTION 5: INTERPOLATE DTI TO SOURCES
%  ========================================================================

fprintf('\n--- Interpolating DTI to sources ---\n');

[fa_sources, v1_sources] = zef_dti_interpolate_to_sources(zef_test, source_positions);

fprintf('  FA at sources: min=%.3f, max=%.3f, mean=%.3f, std=%.3f\n', ...
    min(fa_sources), max(fa_sources), mean(fa_sources), std(fa_sources));

if ~isempty(v1_sources)
    fprintf('  v1 at sources: %d vectors interpolated and rotated to mesh space\n', ...
        size(v1_sources, 1));
end

%% ========================================================================
%  SECTION 6: BUILD FA-BASED COVARIANCE MATRIX
%  ========================================================================

fprintf('\n--- FA-based structural covariance ---\n');

tic;
Q_fa = zef_dti_fa_covariance(source_positions, fa_sources, v1_sources, ...
    'length_scale', 10, ...
    'k_neighbors', min(50, N), ...
    'use_direction', true, ...
    'normalize', true);
t_fa = toc;

fprintf('  Time: %.2f s\n', t_fa);
fprintf('  Size: %d × %d\n', size(Q_fa));
fprintf('  Non-zeros: %d (%.3f%% density)\n', nnz(Q_fa), 100*nnz(Q_fa)/N^2);
fprintf('  Diagonal: min=%.4f, max=%.4f\n', min(full(diag(Q_fa))), max(full(diag(Q_fa))));

% Eigenvalue analysis (sample for large matrices)
n_eigs = min(50, N-1);
if N > 200
    eig_fa = eigs(Q_fa, n_eigs, 'largestabs');
else
    eig_fa = sort(eig(full(Q_fa)), 'descend');
end
fprintf('  Top eigenvalues: %.4f, %.4f, %.4f, ..., %.4e\n', ...
    eig_fa(1), eig_fa(min(2,end)), eig_fa(min(3,end)), eig_fa(end));

%% ========================================================================
%  SECTION 7: BUILD TRACTOGRAPHY-BASED COVARIANCE MATRIX
%  ========================================================================

fprintf('\n--- Tractography-based structural covariance ---\n');

tic;
Q_tract = zef_dti_tractography_covariance(zef_test, source_positions, ...
    'fa_threshold', 0.15, ...
    'step_size', 0.5, ...
    'max_steps', 500, ...
    'proximity_radius', 3.0, ...
    'normalize', true);
t_tract = toc;

fprintf('  Time: %.2f s\n', t_tract);
fprintf('  Size: %d × %d\n', size(Q_tract));
fprintf('  Non-zeros: %d (%.3f%% density)\n', nnz(Q_tract), 100*nnz(Q_tract)/N^2);
fprintf('  Diagonal: min=%.4f, max=%.4f\n', min(full(diag(Q_tract))), max(full(diag(Q_tract))));

% Eigenvalue analysis
if N > 200
    eig_tract = eigs(Q_tract, n_eigs, 'largestabs');
else
    eig_tract = sort(eig(full(Q_tract)), 'descend');
end
fprintf('  Top eigenvalues: %.4f, %.4f, %.4f, ..., %.4e\n', ...
    eig_tract(1), eig_tract(min(2,end)), eig_tract(min(3,end)), eig_tract(end));

%% ========================================================================
%  SECTION 8: VISUALIZATION
%  ========================================================================

fprintf('\n--- Generating visualizations ---\n');

% --- Shared variables for subsampling large matrices ---
if N <= 2000
    sub_idx = 1:N;
else
    sub_idx = round(linspace(1, N, min(N, 1000)));
end

offdiag_fa = nonzeros(triu(Q_fa, 1));
offdiag_tract = nonzeros(triu(Q_tract, 1));
row_sum_fa = full(sum(Q_fa, 2)) - full(diag(Q_fa));
row_sum_tract = full(sum(Q_tract, 2)) - full(diag(Q_tract));

% ========================================================================
% FIGURE 1: FA-Based Covariance Matrix
% ========================================================================

figure('Name', 'FA-Based Covariance Matrix', ...
    'NumberTitle', 'off', 'Position', [50, 550, 700, 600], 'Color', 'w');
imagesc(full(Q_fa(sub_idx, sub_idx)));
colormap(parula(256));
cb = colorbar;
cb.Label.String = 'Covariance';
cb.Label.FontSize = 11;
title(sprintf('FA-Based Structural Covariance  Q_{FA}  (N = %d sources)', N), ...
    'FontSize', 14, 'FontWeight', 'bold');
xlabel('Source index', 'FontSize', 12);
ylabel('Source index', 'FontSize', 12);
axis square;
set(gca, 'FontSize', 11);

% ========================================================================
% FIGURE 2: Tractography-Based Covariance Matrix
% ========================================================================

figure('Name', 'Tractography-Based Covariance Matrix', ...
    'NumberTitle', 'off', 'Position', [770, 550, 700, 600], 'Color', 'w');
imagesc(full(Q_tract(sub_idx, sub_idx)));
colormap(parula(256));
cb = colorbar;
cb.Label.String = 'Covariance';
cb.Label.FontSize = 11;
title(sprintf('Tractography-Based Structural Covariance  Q_{Tract}  (N = %d sources)', N), ...
    'FontSize', 14, 'FontWeight', 'bold');
xlabel('Source index', 'FontSize', 12);
ylabel('Source index', 'FontSize', 12);
axis square;
set(gca, 'FontSize', 11);

% ========================================================================
% FIGURE 3: Eigenvalue Spectra
% ========================================================================

figure('Name', 'Eigenvalue Spectra', ...
    'NumberTitle', 'off', 'Position', [50, 50, 750, 500], 'Color', 'w');
n_show = min(n_eigs, min(length(eig_fa), length(eig_tract)));
semilogy(1:n_show, eig_fa(1:n_show), 'b-o', 'LineWidth', 2, ...
    'MarkerSize', 5, 'MarkerFaceColor', 'b', 'DisplayName', 'FA-based');
hold on;
semilogy(1:n_show, eig_tract(1:n_show), 'r-s', 'LineWidth', 2, ...
    'MarkerSize', 5, 'MarkerFaceColor', 'r', 'DisplayName', 'Tractography');
hold off;
grid on;
legend('Location', 'northeast', 'FontSize', 12);
title('Eigenvalue Spectrum Comparison', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Eigenvalue rank', 'FontSize', 12);
ylabel('Eigenvalue (log scale)', 'FontSize', 12);
xlim([1, n_show]);
set(gca, 'FontSize', 11);

% ========================================================================
% FIGURE 4: FA at Source Positions (3D scatter)
% ========================================================================

figure('Name', 'FA at Source Positions', ...
    'NumberTitle', 'off', 'Position', [820, 50, 700, 600], 'Color', 'w');
scatter3(source_positions(:,1), source_positions(:,2), source_positions(:,3), ...
    12, fa_sources, 'filled', 'MarkerFaceAlpha', 0.6);
colormap(hot(256));
cb = colorbar;
cb.Label.String = 'Fractional Anisotropy';
cb.Label.FontSize = 11;
title('Fractional Anisotropy at Source Positions', ...
    'FontSize', 14, 'FontWeight', 'bold');
xlabel('x (mm)', 'FontSize', 12);
ylabel('y (mm)', 'FontSize', 12);
zlabel('z (mm)', 'FontSize', 12);
axis equal tight;
view(3);
grid on;
set(gca, 'FontSize', 11);

% ========================================================================
% FIGURE 5: Coupling Strength (Row-Sum Profile)
% ========================================================================

figure('Name', 'Coupling Strength per Source', ...
    'NumberTitle', 'off', 'Position', [100, 300, 800, 450], 'Color', 'w');
plot(1:N, row_sum_fa, 'b-', 'LineWidth', 1.2, 'DisplayName', 'FA-based');
hold on;
plot(1:N, row_sum_tract, 'r-', 'LineWidth', 1.2, 'DisplayName', 'Tractography');
hold off;
legend('Location', 'best', 'FontSize', 12);
title('Off-Diagonal Row Sum — Structural Coupling Strength per Source', ...
    'FontSize', 14, 'FontWeight', 'bold');
xlabel('Source index', 'FontSize', 12);
ylabel('\Sigma_{j \neq i} Q(i,j)', 'FontSize', 12);
grid on;
set(gca, 'FontSize', 11);

% ========================================================================
% FIGURE 6: Distribution of Off-Diagonal Entries
% ========================================================================

figure('Name', 'Off-Diagonal Entry Distribution', ...
    'NumberTitle', 'off', 'Position', [200, 200, 800, 450], 'Color', 'w');
if ~isempty(offdiag_fa)
    histogram(full(offdiag_fa), 100, 'FaceColor', [0.2 0.4 0.8], ...
        'FaceAlpha', 0.6, 'EdgeColor', 'none', 'DisplayName', 'FA-based');
end
hold on;
if ~isempty(offdiag_tract)
    histogram(full(offdiag_tract), 100, 'FaceColor', [0.8 0.2 0.2], ...
        'FaceAlpha', 0.6, 'EdgeColor', 'none', 'DisplayName', 'Tractography');
end
hold off;
legend('Location', 'best', 'FontSize', 12);
title('Distribution of Non-Zero Off-Diagonal Covariance Entries', ...
    'FontSize', 14, 'FontWeight', 'bold');
xlabel('Covariance value', 'FontSize', 12);
ylabel('Count', 'FontSize', 12);
grid on;
set(gca, 'FontSize', 11);

% ========================================================================
% FIGURE 7: Sparsity Pattern — FA-Based
% ========================================================================

figure('Name', 'Sparsity Pattern — FA-Based', ...
    'NumberTitle', 'off', 'Position', [300, 100, 600, 600], 'Color', 'w');
spy(Q_fa(sub_idx, sub_idx), 1);
title(sprintf('Q_{FA} Sparsity Pattern  (nnz = %d,  density = %.3f%%)', ...
    nnz(Q_fa), 100*nnz(Q_fa)/N^2), 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Source index', 'FontSize', 12);
ylabel('Source index', 'FontSize', 12);
set(gca, 'FontSize', 11);

% ========================================================================
% FIGURE 8: Sparsity Pattern — Tractography-Based
% ========================================================================

figure('Name', 'Sparsity Pattern — Tractography-Based', ...
    'NumberTitle', 'off', 'Position', [920, 100, 600, 600], 'Color', 'w');
spy(Q_tract(sub_idx, sub_idx), 1);
title(sprintf('Q_{Tract} Sparsity Pattern  (nnz = %d,  density = %.3f%%)', ...
    nnz(Q_tract), 100*nnz(Q_tract)/N^2), 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Source index', 'FontSize', 12);
ylabel('Source index', 'FontSize', 12);
set(gca, 'FontSize', 11);

%% ========================================================================
%  SECTION 9: NUMERICAL SUMMARY TABLE
%  ========================================================================

fprintf('\n');
fprintf('╔══════════════════════════════════════════════════════════════╗\n');
fprintf('║         DTI Structural Covariance — Summary Report         ║\n');
fprintf('╠══════════════════════════════════════════════════════════════╣\n');
fprintf('║ Property                  │  FA-based   │ Tractography     ║\n');
fprintf('╟───────────────────────────┼─────────────┼──────────────────╢\n');
fprintf('║ Matrix size               │  %5d×%-5d│  %5d×%-10d║\n', ...
    size(Q_fa,1), size(Q_fa,2), size(Q_tract,1), size(Q_tract,2));
fprintf('║ Non-zeros                 │  %10d│  %15d ║\n', nnz(Q_fa), nnz(Q_tract));
fprintf('║ Density (%%)               │  %10.4f│  %15.4f ║\n', ...
    100*nnz(Q_fa)/N^2, 100*nnz(Q_tract)/N^2);
fprintf('║ Largest eigenvalue        │  %10.6f│  %15.6f ║\n', eig_fa(1), eig_tract(1));
fprintf('║ Smallest eigenvalue (est.)│  %10.2e│  %15.2e ║\n', eig_fa(end), eig_tract(end));
fprintf('║ Condition number (est.)   │  %10.2e│  %15.2e ║\n', ...
    abs(eig_fa(1)/eig_fa(end)), abs(eig_tract(1)/eig_tract(end)));
fprintf('║ Mean off-diag coupling    │  %10.6f│  %15.6f ║\n', ...
    mean(full(offdiag_fa)), mean(full(offdiag_tract)));
fprintf('║ Max off-diag coupling     │  %10.6f│  %15.6f ║\n', ...
    max(full(offdiag_fa)), max(full(offdiag_tract)));
fprintf('║ Computation time (s)      │  %10.2f│  %15.2f ║\n', t_fa, t_tract);
fprintf('╚══════════════════════════════════════════════════════════════╝\n');

fprintf('\n--- Integration with Kalman filter ---\n');
fprintf('  To use FA-based Q in Kalman filter:\n');
fprintf('    zef.kf_structural_Q_type = 1;\n');
fprintf('    zef = zef_KF(zef);\n\n');
fprintf('  To use tractography-based Q:\n');
fprintf('    zef.kf_structural_Q_type = 2;\n');
fprintf('    zef = zef_KF(zef);\n\n');
fprintf('  To revert to standard diagonal Q:\n');
fprintf('    zef.kf_structural_Q_type = 0;\n');
fprintf('    zef = zef_KF(zef);\n');

fprintf('\nDone.\n');
