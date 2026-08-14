%ZEF_DELETE_ORIGINAL_SURFACE_MESHES  Drop all *_original_surface_mesh backup fields.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Unused from menus. Real caller: zef_init (with zef_delete_original_field)
%   so a new session does not keep resample/transform caches from a previous
%   zef. zef_downsample_surfaces and zef_apply_transform *write* those
%   fields; this script only rmfields them.
%
%   Script. fieldnames containing 'original_surface_mesh' are removed,
%   then the temporary zef.fieldnames field is removed.
%
%   See also zef_delete_original_field, zef_apply_transform, zef_init.

zef.fieldnames = fieldnames(zef);
zef = rmfield(zef,zef.fieldnames(find(contains(zef.fieldnames, 'original_surface_mesh'))));
zef = rmfield(zef,{'fieldnames'});
