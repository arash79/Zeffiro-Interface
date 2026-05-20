%Copyright © 2026 ZI Development Team
%
%ZEF_MRI_MESH_TETRA_HISTOGRAM_SNR
%
%Maps FEM tetrahedron centres to MRI voxel indices, samples a scalar volume,
%groups samples by zef.domain_labels, estimates background ("air") power from
%voxels not covered by the mesh sampling footprint, and reports histograms,
%mean squared power, SNR, and the rescale factor r = 1 - 10^(-SNR/20).
%
%Typical workflow (mesh already built in Zeffiro):
%   1) tetra_c = mean of the four corner nodes of each tetra (lab / mesh mm).
%   2) Map lab -> voxel indices (your affine A,b or a 4x4 NIfTI-style matrix).
%   3) Read intensity at each voxel; attach to compartment via domain_labels.
%   4) Air / noise: voxels inside a padded bounding box around sampled voxels
%      that are not hit by any tetra centre mapping (tissue was meshed; these
%      voxels approximate exterior / air). Optional user-supplied air_mask.
%   5) P_tissue = mean(I.^2) over all tetra samples; P_noise = mean(I.^2) over air.
%      SNR = 10*log10(P_tissue / P_noise);  r = 1 - 10^(-SNR/20).
%
%Coordinate conventions:
%   - zef.nodes is Nx3, zef.tetra is Mx4 (node indices per row).
%   - For 3x3 A and 3x1 b with lab coordinates as ROWS [x y z]:
%         voxel_row = ceil( tetra_lab * A.' + b(:).' );
%     which matches A * (tetra_c.') + b when tetra_c is 3 x M (column points).
%
%NIfTI / Zeffiro slice overlay convention (same as zef_visualize_nii_slices):
%   lab_row (1x4) = vox_row (1x4) * T,  with vox_row = [i j k 1].
%   Hence vox_row = lab_row * inv(T).  Pass this T as 'T_voxel_to_lab'.
%
%Inputs:
%   zef        - Struct with .nodes, .tetra, .domain_labels (and optionally
%                .compartment_tags for names in the output table).
%   mri_volume - 3-D numeric array [nx ny nz], same indexing as (i,j,k) from
%                the affine, OR a char/string path to .nii / .nii.gz (uses
%                niftiread; optional transform must then be supplied or taken
%                from niftiinfo if 'use_nifti_transform' is true).
%
%Name-value pairs:
%   'A','b'                  - 3x3 and 3x1 (or 1x3) lab->voxel linear map + shift
%                              (mutually exclusive with T_voxel_to_lab).
%   'T_voxel_to_lab'         - 4x4: voxel row [i j k 1] maps to lab [x y z 1].
%   'use_nifti_transform'    - If mri_volume is a file path and this is true
%                              (default for path input), T is taken from
%                              niftiinfo (Transform.T, double). You may still
%                              need freesurfer-style c_ras handling for FS meshes;
%                              see zef_visualize_nii_slices.
%   'freesurfer_coords'      - If true and using NIfTI transform, subtract c_ras
%                              from translation row like zef_visualize_nii_slices.
%                              Default false.
%   'index_origin'           - 0 or 1 (default 1). Added to voxel indices after
%                              ceil/round so 0-based affines map into MATLAB arrays.
%   'round_voxel'            - @ceil (default), @floor, @round.
%   'air_definition'         - 'uncovered_bbox' (default), 'uncovered_full',
%                              or 'mask' (requires air_mask).
%   'bbox_padding'           - Integer voxel margin around covered voxels for
%                              'uncovered_bbox'. Default 12.
%   'air_mask'               - Logical [nx ny nz], true = air voxels for P_noise.
%   'num_histogram_bins'     - Default 64.
%   'plot'                   - If true, figure with histograms per domain.
%                              Default false.
%
%Outputs:
%   out - Struct: tetra_centres, voxel_indices, intensities, domain_labels,
%         compartment_names, P_mean_sq_per_domain, P_mean_sq_tissue_total,
%         P_mean_sq_air, SNR_total_dB, SNR_per_domain_dB, r_total, r_per_domain,
%         histogram_edges, histogram_counts_per_domain, air_voxel_count, ...
%
%Example:
%   V = niftiread('T1.nii.gz');
%   info = niftiinfo('T1.nii.gz');
%   T = double(info.Transform.T);
%   out = zef_mri_mesh_tetra_histogram_snr(zef, V, 'T_voxel_to_lab', T, ...
%       'freesurfer_coords', true, 'plot', true);
%
%   If you already have T_mesh2voxel from zef_dti_get_mesh2voxel (mesh row -> voxel
%   row, homogeneous), then lab_row * T_mesh2voxel = vox_row implies
%       T_voxel_to_lab = inv(T_mesh2voxel)
%   for use with the NIfTI row convention above.
%
%See also: zef_visualize_nii_slices, zef_dti_get_mesh2voxel

function out = zef_mri_mesh_tetra_histogram_snr(zef, mri_volume, varargin)
% --- Zeffiro documentation header ---
% zef_mri_mesh_tetra_histogram_snr — Zef mri mesh tetra histogram snr.
%
% Purpose:
%   Zef mri mesh tetra histogram snr.
%   Folder: FEM mesh generation, surface processing, refinement, and barycentric operators.
%
% Inputs:
%   zef
%   mri_volume
%   varargin
%
% Outputs:
%   out
%
% Zef fields (observed):
%   zef.compartment_tags (read)
%   zef.domain_labels (read)
%   zef.nodes (read)
%   zef.tetra (read)
%
% Calls (project):
%   zef_mri_mesh_tetra_histogram_snr
%
% Side effects:
%   - creates/updates figures
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[out] = zef_mri_mesh_tetra_histogram_snr(zef, mri_volume, varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header


p = inputParser;
addParameter(p, 'A', [], @(x) isnumeric(x) && (isempty(x) || isequal(size(x), [3 3])));
addParameter(p, 'b', [], @(x) isnumeric(x) && (isempty(x) || numel(x) == 3));
addParameter(p, 'T_voxel_to_lab', [], @(x) isnumeric(x) && (isempty(x) || isequal(size(x), [4 4])));
addParameter(p, 'use_nifti_transform', [], @(x) isempty(x) || (isscalar(x) && (x==0 || x==1)));
addParameter(p, 'freesurfer_coords', false, @(x) islogical(x) || x==0 || x==1);
addParameter(p, 'index_origin', 1, @(x) isscalar(x) && (x==0 || x==1));
addParameter(p, 'round_voxel', @ceil, @(x) isa(x, 'function_handle'));
addParameter(p, 'air_definition', 'uncovered_bbox', @ischar);
addParameter(p, 'bbox_padding', 12, @(x) isnumeric(x) && isscalar(x) && x >= 0);
addParameter(p, 'air_mask', [], @(x) isempty(x) || (islogical(x) && ndims(x) == 3)); %#ok<ISMAT>
addParameter(p, 'num_histogram_bins', 64, @(x) isnumeric(x) && isscalar(x) && x > 1);
addParameter(p, 'plot', false, @(x) islogical(x) || x==0 || x==1);
parse(p, varargin{:});
opt = p.Results;

if ischar(mri_volume) || isstring(mri_volume)
    nii_path = char(mri_volume);
    if ~isfile(nii_path)
        error('zef_mri_mesh_tetra_histogram_snr:fileNotFound', 'MRI file not found: %s', nii_path);
    end
    mri_volume = niftiread(nii_path);
    if isempty(opt.use_nifti_transform)
        use_T = true;
    else
        use_T = logical(opt.use_nifti_transform);
    end
    if use_T && isempty(opt.T_voxel_to_lab)
        nii_info = niftiinfo(nii_path);
        if ~isfield(nii_info, 'Transform')
            error('zef_mri_mesh_tetra_histogram_snr:noTransform', ...
                'niftiinfo has no Transform for %s', nii_path);
        end
        T = double(nii_info.Transform.T);
        if logical(opt.freesurfer_coords)
            nx = size(mri_volume, 1);
            ny = size(mri_volume, 2);
            nz = size(mri_volume, 3);
            ctr_vox = [floor(nx/2)+1, floor(ny/2)+1, floor(nz/2)+1];
            c_ras_w = local_vox2world_row(ctr_vox, T);
            T(4, 1:3) = T(4, 1:3) - c_ras_w;
        end
        opt.T_voxel_to_lab = T;
    end
end

if ~isfield(zef, 'nodes') || isempty(zef.nodes)
    error('zef_mri_mesh_tetra_histogram_snr:noNodes', 'zef.nodes is missing or empty.');
end
if ~isfield(zef, 'tetra') || isempty(zef.tetra)
    error('zef_mri_mesh_tetra_histogram_snr:noTetra', 'zef.tetra is missing or empty.');
end
if ~isfield(zef, 'domain_labels') || isempty(zef.domain_labels)
    error('zef_mri_mesh_tetra_histogram_snr:noDomainLabels', 'zef.domain_labels is missing or empty.');
end

nodes = double(zef.nodes);
tetra = double(zef.tetra);
dom = double(zef.domain_labels);
if size(dom, 2) > 1
    dom = dom(:, 1);
end
if size(tetra, 1) ~= numel(dom)
    error('zef_mri_mesh_tetra_histogram_snr:sizeMismatch', ...
        'domain_labels length (%d) must match number of tetra (%d).', numel(dom), size(tetra, 1));
end

% Tetra centres (lab / mesh coordinates), M x 3
nc = (nodes(tetra(:, 1), :) + nodes(tetra(:, 2), :) + nodes(tetra(:, 3), :) + nodes(tetra(:, 4), :)) / 4;

Tvl = opt.T_voxel_to_lab;
hasT = ~isempty(Tvl);
hasA = ~isempty(opt.A);

if hasT && hasA
    error('zef_mri_mesh_tetra_histogram_snr:ambiguousTransform', ...
        'Supply either T_voxel_to_lab or (A,b), not both.');
end
if ~hasT && ~hasA
    error('zef_mri_mesh_tetra_histogram_snr:noTransform', ...
        'Provide T_voxel_to_lab (voxel row -> lab) or A and b (lab row -> voxel).');
end

if hasA
    A = double(opt.A);
    b = double(opt.b(:)).';
    vox = opt.round_voxel(nc * A.' + b) + opt.index_origin;
else
    Tvl = double(Tvl);
    T_inv = inv(Tvl);
    hom = [nc ones(size(nc, 1), 1)];
    vox_h = hom * T_inv;
    vox = opt.round_voxel(vox_h(:, 1:3)) + opt.index_origin;
end

nx = size(mri_volume, 1);
ny = size(mri_volume, 2);
nz = size(mri_volume, 3);

oob = vox(:,1) < 1 | vox(:,1) > nx | vox(:,2) < 1 | vox(:,2) > ny | vox(:,3) < 1 | vox(:,3) > nz;
if any(oob)
    warning('zef_mri_mesh_tetra_histogram_snr:clampOob', ...
        'Clamping %d / %d tetra centres to volume bounds.', sum(oob), size(vox, 1));
    vox(:,1) = min(max(vox(:,1), 1), nx);
    vox(:,2) = min(max(vox(:,2), 1), ny);
    vox(:,3) = min(max(vox(:,3), 1), nz);
end

ii = vox(:, 1);
jj = vox(:, 2);
kk = vox(:, 3);
lin = sub2ind([nx, ny, nz], ii, jj, kk);
intensity = mri_volume(lin);

% Compartment names for active "on" compartments in domain-label order
comp_names = local_domain_index_to_names(zef, max(dom));

% --- Air / noise mask ---
air_key = lower(strrep(opt.air_definition, '_', ''));
switch air_key
    case 'uncoveredbbox'
        covered = false(nx, ny, nz);
        covered(lin) = true;
        [ci, cj, ck] = ind2sub([nx, ny, nz], lin);
        pad = round(opt.bbox_padding);
        i1 = max(1, min(ci) - pad);
        i2 = min(nx, max(ci) + pad);
        j1 = max(1, min(cj) - pad);
        j2 = min(ny, max(cj) + pad);
        k1 = max(1, min(ck) - pad);
        k2 = min(nz, max(ck) + pad);
        bbox_mask = false(nx, ny, nz);
        bbox_mask(i1:i2, j1:j2, k1:k2) = true;
        air_mask = bbox_mask & ~covered;
    case 'uncoveredfull'
        covered = false(nx, ny, nz);
        covered(lin) = true;
        air_mask = ~covered;
    case 'mask'
        if isempty(opt.air_mask)
            error('zef_mri_mesh_tetra_histogram_snr:noAirMask', ...
                'air_definition ''mask'' requires air_mask.');
        end
        if ~isequal(size(opt.air_mask), [nx, ny, nz])
            error('zef_mri_mesh_tetra_histogram_snr:airMaskSize', ...
                'air_mask must match size(mri_volume).');
        end
        air_mask = opt.air_mask;
    otherwise
        error('zef_mri_mesh_tetra_histogram_snr:badAir', ...
            'Unknown air_definition ''%s''.', opt.air_definition);
end

if ~any(air_mask(:))
    error('zef_mri_mesh_tetra_histogram_snr:emptyAir', ...
        'No air voxels found; increase bbox_padding or use air_definition ''uncovered_full'' or supply air_mask.');
end

P_noise = mean(double(mri_volume(air_mask)).^2, 'all', 'omitnan');

uniq_dom = unique(dom);
n_dom = numel(uniq_dom);
P_mean_sq = zeros(n_dom, 1);
hist_edges = [];
hist_counts = zeros(opt.num_histogram_bins, n_dom);
all_sq = double(intensity).^2;
P_mean_sq_tissue_total = mean(all_sq, 'omitnan');

for k = 1:n_dom
    d = uniq_dom(k);
    msk = (dom == d);
    vals = double(intensity(msk));
    P_mean_sq(k) = mean(vals.^2, 'omitnan');
    if isempty(hist_edges)
        [hist_counts(:, k), hist_edges] = histcounts(vals, opt.num_histogram_bins);
    else
        hist_counts(:, k) = histcounts(vals, hist_edges);
    end
end

SNR_per = 10 * log10(P_mean_sq / P_noise);
SNR_total = 10 * log10(P_mean_sq_tissue_total / P_noise);

r_per = 1 - 10 .^ (-SNR_per / 20);
r_total = 1 - 10 ^ (-SNR_total / 20);

out.tetra_centres = nc;
out.voxel_indices = vox;
out.intensities = intensity;
out.domain_labels = dom;
out.compartment_names = comp_names;
out.domain_index_list = uniq_dom;
out.P_mean_sq_per_domain = P_mean_sq;
out.P_mean_sq_tissue_total = P_mean_sq_tissue_total;
out.P_mean_sq_air = P_noise;
out.SNR_total_dB = SNR_total;
out.SNR_per_domain_dB = SNR_per;
out.r_total = r_total;
out.r_per_domain = r_per;
out.histogram_edges = hist_edges;
out.histogram_counts_per_domain = hist_counts;
out.air_voxel_count = nnz(air_mask);
out.air_mask = air_mask;

if logical(opt.plot)
    figure('Name', 'MRI intensity by compartment (tetra samples)', 'Color', 'w');
    tiledlayout(min(4, n_dom), ceil(n_dom / min(4, n_dom)), 'Padding', 'compact');
    for k = 1:n_dom
        nexttile;
        histogram('BinEdges', hist_edges, 'BinCounts', hist_counts(:, k), 'FaceAlpha', 0.85);
        d = uniq_dom(k);
        nm = comp_names{d};
        title(sprintf('%s  (SNR=%.1f dB, r=%.3f)', nm, SNR_per(k), r_per(k)), 'Interpreter', 'none');
        xlabel('Intensity');
        ylabel('Count');
    end
    sgtitle(sprintf('Total tissue SNR = %.2f dB,  r_{total} = %.3f', SNR_total, r_total));
end

end

%% ------------------------------------------------------------------------
function w = local_vox2world_row(vox_row, T)
    pts = double(vox_row);
    if size(pts, 2) ~= 3
        error('internal');
    end
    hom = [pts ones(size(pts, 1), 1)];
    w = hom * T;
    w = w(:, 1:3);
end

function names = local_domain_index_to_names(zef, max_label)
    n = max_label;
    names = cell(n, 1);
    for i = 1:n
        names{i} = sprintf('domain_%d', i);
    end
    if ~isfield(zef, 'compartment_tags') || isempty(zef.compartment_tags)
        return;
    end
    aux = zeros(length(zef.compartment_tags), 1);
    ii = 0;
    for k = 1:length(zef.compartment_tags)
        tag = zef.compartment_tags{k};
        if isfield(zef, [tag '_on']) && zef.([tag '_on'])
            ii = ii + 1;
            aux(k) = ii;
        end
    end
    for k = 1:length(zef.compartment_tags)
        if aux(k) >= 1 && aux(k) <= n
            names{aux(k)} = zef.compartment_tags{k};
        end
    end
end
