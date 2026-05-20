function out = is_eof ( in )
% --- Zeffiro documentation header ---
% utilities.io.is_eof — Is eof.
%
% Purpose:
%   Is eof.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   in
%
% Outputs:
%   out
%
% Calls (project):
%   utilities.io.is_eof
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[out] = utilities.io.is_eof(in)` with project root and `src` on the path.
% --- End Zeffiro documentation header

    arguments

        in (1,1) string

    end

    out = in == "-1" ;

end % function
