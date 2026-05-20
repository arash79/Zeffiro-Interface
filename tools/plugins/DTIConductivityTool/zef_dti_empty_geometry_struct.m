%Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%
%ZEF_DTI_EMPTY_GEOMETRY_STRUCT
%
%Returns an empty geometry struct with the same fields as
%zef_freesurfer_read_volume_geometry. Used to initialize dti_fa_geometry
%and dti_ref_geometry so that dot-indexing (e.g. zef.dti_fa_geometry.voxel_sizes)
%does not error before any volume is loaded.
%
%Outputs:
%   geom - Struct with fields: vox2ras, vox2ras_tkr, center_ras,
%          dimensions, voxel_sizes, source (all empty).
%
%See also: zef_freesurfer_read_volume_geometry, zef_dti_conductivity_init

function geom = zef_dti_empty_geometry_struct()

geom = struct( ...
    'vox2ras', [], ...
    'vox2ras_tkr', [], ...
    'center_ras', [], ...
    'dimensions', [], ...
    'voxel_sizes', [], ...
    'source', '');

end
