function zef = zef_add_transform(zef)
% --- Zeffiro documentation header ---
% zef_add_transform — Zef add transform.
%
% Purpose:
%   Zef add transform.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.current_tag (read)
%   zef.lock_transforms_on (read)
%
% Calls (project):
%   zef_add_transform
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_add_transform(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header



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
