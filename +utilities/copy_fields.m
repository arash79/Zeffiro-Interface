function to_out = copy_fields ( from, to, kwargs )
%COPY_FIELDS Copy fields from one struct into another.
%
% TO_OUT = copy_fields(FROM, TO, kwargs) copies every field of FROM into TO
% and returns the modified struct. If kwargs.error_on_overwrite is true and
% TO already has a field with the same name, the function returns a struct
% containing only the key "copy_fields_error__" with an error message instead
% of overwriting.
%
% Inputs:
%   from  - (1,1) struct
%            Source struct whose fields are copied.
%   to    - (1,1) struct
%            Destination struct; modified in place (conceptually) and returned.
%   kwargs.error_on_overwrite - (1,1) logical, default false
%            If true, any existing field in TO with the same name as a field
%            in FROM triggers an early return with copy_fields_error__ set.
%
% Outputs:
%   to_out - (1,1) struct
%            Either TO with all fields from FROM added, or a struct with
%            single field copy_fields_error__ (string) on overwrite conflict.
%

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
