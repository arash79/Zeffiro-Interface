function to_out = copy_fields ( from, to, kwargs )
%COPY_FIELDS  Copy all fields from one struct into another.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   to_out = copy_fields(from, to, kwargs)
%
%   Overwrites matching field names on to. When kwargs.error_on_overwrite is
%   true and a field already exists on to, returns early with
%   to_out.copy_fields_error__ describing the conflict instead of copying.

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
