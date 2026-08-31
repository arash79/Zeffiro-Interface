function geom = zef_dti_empty_geometry_struct()
%ZEF_DTI_EMPTY_GEOMETRY_STRUCT  Empty vox2ras geometry placeholder.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Same fields as zef_freesurfer_read_volume_geometry, all empty, so
%   zef.dti_fa_geometry.voxel_sizes (etc.) can be indexed before Load.
%   Called from zef_dti_conductivity_init.
%
%   geom fields: vox2ras, vox2ras_tkr, center_ras, dimensions,
%   voxel_sizes, source (char).
%
%   See also zef_freesurfer_read_volume_geometry, zef_dti_conductivity_init.

geom = struct( ...
    'vox2ras', [], ...
    'vox2ras_tkr', [], ...
    'center_ras', [], ...
    'dimensions', [], ...
    'voxel_sizes', [], ...
    'source', '');

end
