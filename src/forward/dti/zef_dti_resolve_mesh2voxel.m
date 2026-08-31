function T_mesh2voxel = zef_dti_resolve_mesh2voxel(zef)
%ZEF_DTI_RESOLVE_MESH2VOXEL  FreeSurfer mesh→voxel map, or [] if none required.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Calls zef_dti_get_mesh2voxel. If that fails and register.dat is present,
%   errors instead of falling back to T_register * T_nifti (tkRAS mixed with
%   scanner RAS). If register.dat is absent, returns [] so the interpolator
%   can use a NIfTI-only path.
%
%   T_mesh2voxel = zef_dti_resolve_mesh2voxel(zef)
%
%   See also zef_dti_get_mesh2voxel, zef_dti_apply_to_sigma,
%            zef_dti_tensor_interpolate_mesh_space.

arguments
    zef (1, 1) struct
end

try
    T_mesh2voxel = zef_dti_get_mesh2voxel(zef);
catch ME
    has_register = isfield(zef, "freesurfer_register_transform") ...
        && ~isempty(zef.freesurfer_register_transform);
    if has_register
        error("Zeffiro:DTI:IncompleteFreeSurferChain", ...
            "Cannot mix register.dat with scanner-space NIfTI (%s). Load orig.mgz (or dti_reference_nifti) so mesh→voxel uses the FreeSurfer vox2ras-tkr chain.", ...
            ME.message);
    end
    T_mesh2voxel = [];
end

end
