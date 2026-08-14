function varargout = with_zef_in_base(zef_struct, callback)
%WITH_ZEF_IN_BASE  Temporarily assign zef in base workspace for legacy inverters.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   varargout = with_zef_in_base(zef_struct, callback)
%
%   Saves any existing base-workspace zef, assigns zef_struct as zef, invokes
%   callback (typically a legacy inverse feval), then restores or clears zef.
%   Used by dispatch_inverse for legacy methods that read global zef instead of
%   accepting a struct argument.

arguments
    zef_struct (1,1) struct
    callback (1,1) function_handle
end

had_zef = evalin('base', 'exist(''zef'',''var'') == 1');
old_zef = struct;
if had_zef
    old_zef = evalin('base', 'zef');
end

assignin('base', 'zef', zef_struct);
cleanup_obj = onCleanup(@() i_restore_base_zef(had_zef, old_zef));

[varargout{1:nargout}] = callback();

clear cleanup_obj;

end

function i_restore_base_zef(had_zef, old_zef)
if had_zef
    assignin('base', 'zef', old_zef);
else
    evalin('base', 'clear zef');
end
end
