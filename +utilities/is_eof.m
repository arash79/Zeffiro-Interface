function out = is_eof ( in )
%IS_EOF Test if a value represents end-of-file from legacy file read functions.
%
% OUT = is_eof(IN) returns true when IN is the string "-1", which some older
% MATLAB file-reading routines return upon reaching end of file; otherwise
% returns false. Useful for readable EOF checks in loops (e.g. fgetl-style).
%
% Input:
%   in  - (1,1) string
%         Value returned by the read function (e.g. line or -1 as string).
%
% Output:
%   out - (1,1) logical
%         True if IN indicates end of file; false otherwise.
%

    arguments

        in (1,1) string

    end

    out = in == "-1" ;

end % function
