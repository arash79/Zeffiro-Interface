function is_int = float_is_int ( float )
%FLOAT_IS_INT Test if numeric values are integers within floating-point precision.
%
% IS_INT = float_is_int(FLOAT) returns true only if every element of FLOAT
% is finite, non-NaN, and equals its floor (i.e. is an integer in the
% mathematical sense, subject to double-precision representation).
%
% Input:
%   float - (:,:) double
%           Array of values to test (any size).
%
% Output:
%   is_int - (1,1) logical
%            True if all elements are integer-valued; false if any are NaN,
%            non-finite, or fractional.
%

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
