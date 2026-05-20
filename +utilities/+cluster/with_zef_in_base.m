function varargout = with_zef_in_base(zef_struct, callback)
% --- Zeffiro documentation header ---
% utilities.cluster.with_zef_in_base — With zef in base.
%
% Purpose:
%   With zef in base.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   zef_struct
%   callback
%
% Outputs:
%   varargout
%
% Calls (project):
%   utilities.cluster.with_zef_in_base
%   zef_struct
%
% Side effects:
%   - base/caller workspace
%   - parallel/cluster
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[varargout] = utilities.cluster.with_zef_in_base(zef_struct, callback)` with project root and `src` on the path.
% --- End Zeffiro documentation header

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
