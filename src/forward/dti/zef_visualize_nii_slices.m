%Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%
%ZEF_VISUALIZE_NII_SLICES
%
%Loads a NIfTI file and overlays three orthogonal (axial, coronal, sagittal)
%slices onto the Zeffiro figure-tool axes so you can visually check whether
%the NIfTI world-coordinate system aligns with the mesh.
%
%The figure-tool axes (zef.h_axes1) display mesh surfaces in the same
%physical / world-coordinate space as the NIfTI file, so no additional
%registration is needed — the surfaces and the slices should coincide if
%the coordinate systems already match.
%
%Inputs (positional):
%   nii_file     - Path to .nii or .nii.gz file (string)
%
%Inputs (name-value pairs):
%   zef          - Zeffiro struct (default: read from base workspace).
%                  Only needed to locate the figure-tool axes and mesh centre.
%   slice_world  - [1×3] world-space [x y z] coordinate at which to cut the
%                  three planes (default: centre of zef.nodes bounding box),
%                  specified in the SAME coordinate system as zef.nodes.
%   alpha        - Transparency of the slices, 0 (invisible) to 1 (opaque).
%                  Default: 0.6.
%   colormap_name- Colormap string for the NIfTI image (default: 'gray').
%   axes_handle  - Target axes handle. Default: zef.h_axes1 (figure tool).
%   freesurfer_coords - Logical (default: true).
%                  When true the function converts the NIfTI world coordinates
%                  from FreeSurfer scanner-RAS to tkRAS (surface RAS) by
%                  subtracting the c_ras vector — the scanner-RAS position of
%                  the centre voxel of the volume.
%
%                  Zeffiro builds its mesh from FreeSurfer surfaces, which
%                  are stored in tkRAS.  NIfTI sform/qform headers store
%                  scanner RAS.  The two differ by c_ras, which for typical
%                  FreeSurfer subjects is on the order of tens of mm, so the
%                  slices appear shifted even though the voxel-to-RAS matrices
%                  look identical.
%
%                  Set to false only if your NIfTI is already in tkRAS/mesh
%                  space (e.g. written by code that already applied -c_ras).
%
%Outputs:
%   h  - Struct with fields .axial, .coronal, .sagittal — surf handles for
%        each overlay plane. Delete them with structfun(@delete, h) to clean up.
%
%Usage examples:
%   % Basic (FreeSurfer NIfTI + Zeffiro mesh — default, corrects c_ras):
%   h = zef_visualize_nii_slices('FA.nii.gz');
%
%   % NIfTI already in tkRAS / mesh space (no c_ras correction needed):
%   h = zef_visualize_nii_slices('already_in_mesh_space.nii.gz', ...
%       'freesurfer_coords', false);
%
%   % Custom slice position (mesh / tkRAS mm), transparency and colormap
%   h = zef_visualize_nii_slices('conductivity.nii.gz', ...
%       'slice_world', [0 0 50], ...
%       'alpha', 0.7, ...
%       'colormap_name', 'jet');
%
%   % Remove the overlay later
%   structfun(@delete, h);
%
%See also: zef_nii_conductivity_to_sigma, zef_freesurfer_load_fa

function h = zef_visualize_nii_slices(nii_file, varargin)
% --- Zeffiro documentation header ---
% zef_visualize_nii_slices — Renders or updates a visualize_nii_slices figure from current `zef` state.
%
% Purpose:
%   Renders or updates a visualize_nii_slices figure from current `zef` state.
%   Folder: Forward modeling: lead-field FEM assembly, DTI conductivity, NSE, wave models, and PCG solvers.
%
% Inputs:
%   nii_file
%   varargin
%
% Outputs:
%   h
%
% Calls (project):
%   zef_visualize_nii_slices
%
% Side effects:
%   - base/caller workspace
%   - filesystem I/O
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[h] = zef_visualize_nii_slices(nii_file, varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header


arguments
    nii_file (1,:) char
end

arguments (Repeating)
    varargin
end

% -------------------------------------------------------------------------
% Parse optional name-value arguments
% -------------------------------------------------------------------------
p = inputParser;
addParameter(p, 'zef',                struct(),  @isstruct);
addParameter(p, 'slice_world',        [],        @(x) isnumeric(x) && numel(x)==3);
addParameter(p, 'alpha',              0.6,       @(x) isnumeric(x) && isscalar(x));
addParameter(p, 'colormap_name',      'gray',    @ischar);
addParameter(p, 'axes_handle',        [],        @(x) isempty(x) || isgraphics(x,'axes'));
addParameter(p, 'freesurfer_coords',  true,      @(x) islogical(x) || x==0 || x==1);
parse(p, varargin{:});

zef_s         = p.Results.zef;
slice_world   = p.Results.slice_world(:)';
alpha_val     = p.Results.alpha;
cmap_name     = p.Results.colormap_name;
hax           = p.Results.axes_handle;
use_fs_coords = logical(p.Results.freesurfer_coords);

% Get zef from base workspace if caller did not supply it
if isempty(fieldnames(zef_s))
    try
        zef_s = evalin('base', 'zef');
    catch
        zef_s = struct();
    end
end

% -------------------------------------------------------------------------
% Locate target axes
% -------------------------------------------------------------------------
if isempty(hax)
    if isfield(zef_s, 'h_axes1') && isgraphics(zef_s.h_axes1, 'axes')
        hax = zef_s.h_axes1;
    else
        h_fig = findobj(0, 'Tag', 'figure_tool');
        if ~isempty(h_fig)
            hax = findobj(h_fig(1).Children, 'Tag', 'axes1');
        end
        if isempty(hax)
            hax = gca;
            warning('zef_visualize_nii_slices:noFigureTool', ...
                'Could not find Zeffiro figure-tool axes; using current axes.');
        end
    end
end

% -------------------------------------------------------------------------
% Load NIfTI
% -------------------------------------------------------------------------
if ~isfile(nii_file)
    error('zef_visualize_nii_slices:fileNotFound', ...
        'NIfTI file not found: %s', nii_file);
end

fprintf('Loading NIfTI: %s\n', nii_file);
nii_info = niftiinfo(nii_file);
nii_vol  = double(niftiread(nii_info));

if ndims(nii_vol) ~= 3
    error('zef_visualize_nii_slices:badDims', ...
        'Expected a 3-D NIfTI volume; got %d dimensions.', ndims(nii_vol));
end

sz = size(nii_vol);
nx = sz(1);
ny = sz(2);
nz = sz(3);
fprintf('  Volume size : [%d × %d × %d]\n', nx, ny, nz);

% -------------------------------------------------------------------------
% Extract voxel→world affine (row-vector convention, 1-based voxel indices)
%   [xw yw zw 1] = [iv jv kv 1] * T
% -------------------------------------------------------------------------
if isfield(nii_info, 'Transform')
    if isa(nii_info.Transform, 'affine3d')
        T = nii_info.Transform.T;
    elseif isstruct(nii_info.Transform) && isfield(nii_info.Transform, 'T')
        T = nii_info.Transform.T;
    else
        error('zef_visualize_nii_slices:noTransform', ...
            'Cannot extract affine transform from niftiinfo.Transform.');
    end
else
    error('zef_visualize_nii_slices:noTransform', ...
        'Cannot find Transform in niftiinfo.');
end

T     = double(T);

% -------------------------------------------------------------------------
% FreeSurfer coordinate correction: scanner RAS → tkRAS
%
% The NIfTI sform encodes scanner RAS. Zeffiro meshes built from FreeSurfer
% surfaces are in tkRAS (surface RAS) = scanner RAS − c_ras, where c_ras is
% the scanner-RAS coordinate of the centre voxel (floor(N/2)+1 in 1-based).
% Subtracting c_ras from the affine translation column brings the slices into
% the same coordinate frame as the Zeffiro mesh.
% -------------------------------------------------------------------------
if use_fs_coords
    ctr_vox = [floor(nx/2)+1, floor(ny/2)+1, floor(nz/2)+1];
    c_ras_w = nii_slices_vox2world(ctr_vox, T);   % scanner-RAS of centre
    % Modify the translation part of T (row-vector convention: row 4, cols 1:3)
    T(4, 1:3) = T(4, 1:3) - c_ras_w;
    fprintf('  FreeSurfer c_ras     : [%.4f  %.4f  %.4f] mm (subtracted)\n', ...
        c_ras_w(1), c_ras_w(2), c_ras_w(3));
    fprintf('  Coordinates now in   : tkRAS (FreeSurfer surface / mesh space)\n');
else
    fprintf('  freesurfer_coords=false: using raw scanner RAS from NIfTI sform.\n');
end

T_inv = inv(T); %#ok<MINV>

% -------------------------------------------------------------------------
% Build colormap LUT (256 levels) once
% -------------------------------------------------------------------------
cmap = nii_slices_get_colormap(cmap_name);

% -------------------------------------------------------------------------
% Determine slice position in world space
% -------------------------------------------------------------------------
if isempty(slice_world)
    if isfield(zef_s, 'nodes') && ~isempty(zef_s.nodes)
        nd = double(zef_s.nodes);
        slice_world = (min(nd) + max(nd)) / 2;
        fprintf('  Slice position (mesh centre): [%.1f  %.1f  %.1f] mm\n', ...
            slice_world(1), slice_world(2), slice_world(3));
    else
        centre_vox = ([nx, ny, nz] + 1) / 2;
        sw = [centre_vox, 1] * T;
        slice_world = sw(1:3);
        fprintf('  Slice position (NIfTI FOV centre): [%.1f  %.1f  %.1f] mm\n', ...
            slice_world(1), slice_world(2), slice_world(3));
    end
end

% Map world slice position → voxel index
pt_vox = [slice_world, 1] * T_inv;
iv_c = max(1, min(nx, round(pt_vox(1))));
jv_c = max(1, min(ny, round(pt_vox(2))));
kv_c = max(1, min(nz, round(pt_vox(3))));
fprintf('  Voxel indices: i=%d  j=%d  k=%d\n', iv_c, jv_c, kv_c);

% -------------------------------------------------------------------------
% Set up axes
% -------------------------------------------------------------------------
prev_fig = get(0, 'CurrentFigure');
set(0, 'CurrentFigure', ancestor(hax, 'figure'));
set(ancestor(hax, 'figure'), 'CurrentAxes', hax);
hold(hax, 'on');

% -------------------------------------------------------------------------
% AXIAL slice  (constant k = kv_c)
% -------------------------------------------------------------------------
[Jg, Ig] = meshgrid(1:ny, 1:nx);
Kg = kv_c * ones(nx, ny);
pts_w = nii_slices_vox2world([Ig(:), Jg(:), Kg(:)], T);
Xax = reshape(pts_w(:,1), nx, ny);
Yax = reshape(pts_w(:,2), nx, ny);
Zax = reshape(pts_w(:,3), nx, ny);
cdata_ax = nii_slices_scalar2rgb(nii_slices_norm(nii_vol(:,:,kv_c)), cmap);

h_axial = surf(hax, Xax, Yax, Zax, cdata_ax, ...
    'EdgeColor', 'none', ...
    'FaceColor', 'texturemap', ...
    'FaceAlpha', alpha_val, ...
    'DisplayName', sprintf('NIfTI axial  k=%d', kv_c));

% -------------------------------------------------------------------------
% CORONAL slice  (constant j = jv_c)
% -------------------------------------------------------------------------
[Kg2, Ig2] = meshgrid(1:nz, 1:nx);
Jg2 = jv_c * ones(nx, nz);
pts_w = nii_slices_vox2world([Ig2(:), Jg2(:), Kg2(:)], T);
Xcor = reshape(pts_w(:,1), nx, nz);
Ycor = reshape(pts_w(:,2), nx, nz);
Zcor = reshape(pts_w(:,3), nx, nz);
cdata_cor = nii_slices_scalar2rgb(nii_slices_norm(squeeze(nii_vol(:,jv_c,:))), cmap);

h_coronal = surf(hax, Xcor, Ycor, Zcor, cdata_cor, ...
    'EdgeColor', 'none', ...
    'FaceColor', 'texturemap', ...
    'FaceAlpha', alpha_val, ...
    'DisplayName', sprintf('NIfTI coronal j=%d', jv_c));

% -------------------------------------------------------------------------
% SAGITTAL slice  (constant i = iv_c)
% -------------------------------------------------------------------------
[Kg3, Jg3] = meshgrid(1:nz, 1:ny);
Ig3 = iv_c * ones(ny, nz);
pts_w = nii_slices_vox2world([Ig3(:), Jg3(:), Kg3(:)], T);
Xsag = reshape(pts_w(:,1), ny, nz);
Ysag = reshape(pts_w(:,2), ny, nz);
Zsag = reshape(pts_w(:,3), ny, nz);
cdata_sag = nii_slices_scalar2rgb(nii_slices_norm(squeeze(nii_vol(iv_c,:,:))), cmap);

h_sagittal = surf(hax, Xsag, Ysag, Zsag, cdata_sag, ...
    'EdgeColor', 'none', ...
    'FaceColor', 'texturemap', ...
    'FaceAlpha', alpha_val, ...
    'DisplayName', sprintf('NIfTI sagittal i=%d', iv_c));

% -------------------------------------------------------------------------
% Restore figure state
% -------------------------------------------------------------------------
if ~isempty(prev_fig) && isgraphics(prev_fig)
    set(0, 'CurrentFigure', prev_fig);
end
drawnow;

% -------------------------------------------------------------------------
% Coordinate alignment report
% -------------------------------------------------------------------------
corners_vox = [1 1 1; nx 1 1; 1 ny 1; 1 1 nz; nx ny nz];
corners_w   = nii_slices_vox2world(corners_vox, T);
coord_label = 'scanner RAS';
if use_fs_coords; coord_label = 'tkRAS (mesh space)'; end
fprintf('\n--- Coordinate alignment check ---\n');
fprintf('  NIfTI extent in %s:\n', coord_label);
fprintf('    X: [%.1f, %.1f] mm\n', min(corners_w(:,1)), max(corners_w(:,1)));
fprintf('    Y: [%.1f, %.1f] mm\n', min(corners_w(:,2)), max(corners_w(:,2)));
fprintf('    Z: [%.1f, %.1f] mm\n', min(corners_w(:,3)), max(corners_w(:,3)));
if isfield(zef_s, 'nodes') && ~isempty(zef_s.nodes)
    nd = double(zef_s.nodes);
    fprintf('  Mesh node extent:\n');
    fprintf('    X: [%.1f, %.1f] mm\n', min(nd(:,1)), max(nd(:,1)));
    fprintf('    Y: [%.1f, %.1f] mm\n', min(nd(:,2)), max(nd(:,2)));
    fprintf('    Z: [%.1f, %.1f] mm\n', min(nd(:,3)), max(nd(:,3)));
end
fprintf('-----------------------------------\n');
fprintf('  Overlay added to axes (Tag: ''%s'').\n', hax.Tag);
fprintf('  To remove: structfun(@delete, h)\n');

h.axial    = h_axial;
h.coronal  = h_coronal;
h.sagittal = h_sagittal;

end % zef_visualize_nii_slices

% =========================================================================
% Local subfunctions (no shared workspace with the main function)
% =========================================================================

function pts_w = nii_slices_vox2world(pts_v, T)
% Transform N×3 array of 1-based voxel coords to world coords using T.
pts_w = [pts_v, ones(size(pts_v,1),1)] * T;
pts_w = pts_w(:,1:3);
end

function img_n = nii_slices_norm(img)
% Normalise image values to [0,1].
lo = min(img(:));
hi = max(img(:));
if hi > lo
    img_n = (img - lo) / (hi - lo);
else
    img_n = zeros(size(img));
end
end

function cmap = nii_slices_get_colormap(name)
% Return an N×3 colormap matrix without touching any figure.
try
    cmap = feval(name, 256);
catch
    cmap = gray(256);
    warning('zef_visualize_nii_slices:badColormap', ...
        'Colormap ''%s'' not found; using gray.', name);
end
end

function rgb = nii_slices_scalar2rgb(img_n, cmap)
% Convert a 2-D [0,1] image to an [m×n×3] RGB array using cmap.
n_levels = size(cmap, 1);
idx = max(1, min(n_levels, round(img_n * (n_levels-1)) + 1));
sz  = size(img_n);
rgb = reshape(cmap(idx(:), :), [sz, 3]);
end
