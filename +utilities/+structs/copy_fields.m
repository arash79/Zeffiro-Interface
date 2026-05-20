function to_out = copy_fields ( from, to, kwargs )
% --- Zeffiro documentation header ---
% utilities.structs.copy_fields — Copy fields.
%
% Purpose:
%   Copy fields.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   from
%   to
%   kwargs
%
% Outputs:
%   to_out
%
% Calls (project):
%   utilities.structs.copy_fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[to_out] = utilities.structs.copy_fields(from, to, kwargs)` with project root and `src` on the path.
% --- End Zeffiro documentation header

    arguments
        from                        (1,1)   struct
        to                          (1,1)   struct
        kwargs.error_on_overwrite   (1,1)   logical = false
    end

    fns = string ( fieldnames ( from ) ) ;

    for fi = 1 : numel ( fns )

        fn = fns ( fi ) ;

        if kwargs.error_on_overwrite && isfield ( to, fn )

            to_out.copy_fields_error__ = "The given struct already contains a field called '" + fn + "'." ;

            return

        end

        to.(fn) = from.(fn) ;

    end % for

    to_out = to ;

end % function
