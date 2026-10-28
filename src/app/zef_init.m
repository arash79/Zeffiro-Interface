%ZEF_INIT  Start a session: drop stale caches, fill defaults, apply profiles.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script (not a function). Called from zef_start after GUI handles exist.
%   Requires zef in the caller workspace, including zef.font_size.
%
%   This is startup only. Opening a project must not run this script:
%   it clears import paths and reseeds compartments and sensors from the
%   active profile. Project load fills gaps with zef_fill_missing_defaults.
%
%   Side effects
%     Deletes original-surface and original-field caches.
%     Sets zef.file and zef.file_path to ''.
%     Calls zef_apply_init_profile, zef_init_compartments,
%     zef_init_sensors, and zef_apply_parameter_profile.
%
%   See also zef_start, zef_fill_missing_defaults, zef_session_defaults.

zef_delete_original_surface_meshes;
zef_delete_original_field;
zef = zef_fill_missing_defaults(zef);
zef.file = '';
zef.file_path = '';
zef_apply_init_profile;
zef_init_compartments;
zef_init_sensors;
zef = zef_apply_parameter_profile(zef);
