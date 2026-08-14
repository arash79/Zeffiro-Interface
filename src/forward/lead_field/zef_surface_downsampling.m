%ZEF_SURFACE_DOWNSAMPLING  Mesh-tool "Resample surfaces": decimate surfaces, re-interpolate sources.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Bound to h_surface_downsampling. Runs zef_downsample_surfaces,
%   zef_process_meshes, zef_source_interpolation, zef_update. Distinct from
%   the Create FEM mesh checkbox "Resample surf." which only downsamples
%   before volume meshing.
%
%   See also zef_downsample_surfaces, zef_source_interpolation.

zef_downsample_surfaces; zef_process_meshes; zef_source_interpolation; zef_update;
