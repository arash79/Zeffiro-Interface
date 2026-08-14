function out = is_eof ( in )
%IS_EOF  True iff the token is the ASCII "-1" end-of-file sentinel.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   FreeSurfer ASCII surfaces/labels in fs2zef readers terminate counts with
%   a line "-1". in is a scalar string.
%
%   out = is_eof(in)
%
%   See also read_ascii_segmentation_file, float_is_int.

    arguments

        in (1,1) string

    end

    out = in == "-1" ;

end % function
