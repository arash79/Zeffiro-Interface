function is_int = float_is_int ( float )
%FLOAT_IS_INT  True iff every finite element equals floor(element).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Any NaN or Inf → false. Used by fs2zef ASCII readers to check node/face
%   counts and integer connectivity before casting.
%
%   is_int = float_is_int(float)   % 2-D double

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
