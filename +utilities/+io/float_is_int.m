function is_int = float_is_int ( float )
% --- Zeffiro documentation header ---
% utilities.io.float_is_int — Float is int.
%
% Purpose:
%   Float is int.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   float
%
% Outputs:
%   is_int
%
% Calls (project):
%   utilities.io.float_is_int
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[is_int] = utilities.io.float_is_int(float)` with project root and `src` on the path.
% --- End Zeffiro documentation header

    arguments

        float (:,:) double

    end

    is_int = true ;

    if any ( isnan ( float (:) ) )
        is_int = false ;
    end

    if not ( all ( isfinite ( float (:) ) ) )
        is_int = false ;
    end

    if any ( float (:) ~= floor ( float (:) ) )
        is_int = false ;
    end

end % function
