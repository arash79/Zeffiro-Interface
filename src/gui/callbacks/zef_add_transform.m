function zef = zef_add_transform(zef)
%ZEF_ADD_TRANSFORM  Append one identity transform step on the current tag.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Right-click the Transform UITable → **Add transform**
%   (h_menu_add_transform; MenuSelectedFcn "zef_add_transform;").
%   current_tag is the selected compartment or sensor set (set by the
%   matching table-selection callback). Does nothing when
%   zef.lock_transforms_on is true.
%
%   Each step is one layer later multiplied in zef_process_meshes:
%   name "Transform k", scaling 1, xyz correction 0, xy/yz/zx rotation 0
%   (degrees), affine_transform{k} = eye(4). Then zef_init_transform
%   rebuilds the two-column table (Index, Name).
%
%   zef = zef_add_transform(zef)
%   zef_add_transform          % nargout 0 → assignin base
%
%   Input
%     zef  - session. Omitted → evalin('base','zef').
%
%   See also zef_delete_transform, zef_apply_transform, zef_process_meshes.

if nargin == 0
    zef = evalin('base','zef');
end

if not(eval('zef.lock_transforms_on'))

    zef_i = 1 + eval(['length(zef.' zef.current_tag '_transform_name)']);

    eval(['zef.' zef.current_tag '_transform_name = [zef.' zef.current_tag '_transform_name, ''Transform ' num2str(zef_i) '''];']);
    eval(['zef.' zef.current_tag '_scaling = [zef.' zef.current_tag '_scaling, 1];']);
    eval(['zef.' zef.current_tag '_x_correction = [zef.' zef.current_tag '_x_correction, 0];']);
    eval(['zef.' zef.current_tag '_y_correction = [zef.' zef.current_tag '_y_correction, 0];']);
    eval(['zef.' zef.current_tag '_z_correction = [zef.' zef.current_tag '_z_correction, 0];']);
    eval(['zef.' zef.current_tag '_xy_rotation = [zef.' zef.current_tag '_xy_rotation, 0];']);
    eval(['zef.' zef.current_tag '_yz_rotation = [zef.' zef.current_tag '_yz_rotation, 0];']);
    eval(['zef.' zef.current_tag '_zx_rotation = [zef.' zef.current_tag '_zx_rotation, 0];']);
    eval(['zef.' zef.current_tag '_affine_transform(zef_i) = {eye(4)};']);
    clear zef_i;

    zef_init_transform;

end

if nargout == 0
    assignin('base','zef',zef);
end

end
