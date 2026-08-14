function out = zef_mri_mesh_tetra_histogram_snr(zef, mri_volume, varargin)
%ZEF_MRI_MESH_TETRA_HISTOGRAM_SNR  Sample an MRI at tet centroids; SNR by domain.
%
%   Zeffiro Interface.
%   Copyright © 2026 ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Maps each FEM tet centre (mean of four vertices) to a voxel, reads a
%   scalar MRI, groups samples by zef.domain_labels, and estimates noise
%   power from "air" voxels that the mesh does not cover. Reports
%   histograms, mean-square intensity, SNR in dB, and r = 1 − 10^(−SNR/20).
%
%   No first-party caller in this tree (analysis helper). Needs Image
%   Processing Toolbox niftiread/niftiinfo if mri_volume is a file path.
%
%   out = zef_mri_mesh_tetra_histogram_snr(zef, mri_volume)
%   out = zef_mri_mesh_tetra_histogram_snr(zef, mri_volume, Name, Value, ...)
%
%   Inputs
%     zef         - session with nodes (V×3 lab frame), tetra (T×4),
%                   domain_labels (T×1). Optional compartment_tags for names.
%     mri_volume  - 3-D numeric array, or path to a NIfTI file.
%
%   Name-value pairs
%     'T_voxel_to_lab'     - 4×4, voxel row (homogeneous) → lab. From
%                            niftiinfo.Transform.T when a file is passed
%                            and use_nifti_transform is not 0.
%     'A','b'              - 3×3 and 1×3, lab row → voxel:
%                            round_voxel(nc*A.' + b) + index_origin.
%                            Mutually exclusive with T_voxel_to_lab.
%     'use_nifti_transform'- [] (default: true when reading a file), 0, or 1.
%     'freesurfer_coords'  - if true, subtract the NIfTI world coordinate of
%                            the volume centre voxel from T(4,1:3) (c_ras).
%     'index_origin'       - added after rounding, default 1 (MATLAB 1-based).
%     'round_voxel'        - function handle, default @ceil.
%     'air_definition'     - 'uncovered_bbox' (default): air = bbox of
%                            covered voxels padded by bbox_padding, minus
%                            covered voxels. 'uncovered_full': all uncovered.
%                            'mask': use air_mask.
%     'bbox_padding'       - voxels, default 12.
%     'air_mask'           - logical 3-D, same size as the volume.
%     'num_histogram_bins' - default 64; shared edges from the first domain.
%     'plot'               - if true, one histogram tile per domain.
%
%   Output struct
%     tetra_centres, voxel_indices, intensities, domain_labels,
%     compartment_names (cell, index = domain id), domain_index_list,
%     P_mean_sq_per_domain, P_mean_sq_tissue_total, P_mean_sq_air,
%     SNR_total_dB, SNR_per_domain_dB, r_total, r_per_domain,
%     histogram_edges, histogram_counts_per_domain, air_voxel_count, air_mask.
%
%   Transform convention: T_voxel_to_lab is applied as [vox 1]*T (row
%   vectors). Inverse maps lab centres to voxel. Out-of-bounds centres are
%   clamped with a warning.
%
%   See also zef_visualize_nii_slices, zef_dti_get_mesh2voxel.

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
%LOCAL_VOX2WORLD_ROW  Apply 4×4 T as [vox 1]*T and drop the homogeneous 1.
    pts = double(vox_row);
    if size(pts, 2) ~= 3
        error('internal');
    end
    hom = [pts ones(size(pts, 1), 1)];
    w = hom * T;
    w = w(:, 1:3);
end

function names = local_domain_index_to_names(zef, max_label)
%LOCAL_DOMAIN_INDEX_TO_NAMES  Map domain id 1..max_label to compartment tags.
%
%   Default names are domain_k. Active (_on) compartment_tags are assigned
%   in on-order to ids 1,2,... which matches how create/postprocess number
%   domain_labels for compartments without submeshes.
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
