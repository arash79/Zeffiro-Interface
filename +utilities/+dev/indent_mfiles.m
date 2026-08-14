function indent_mfiles(folder)
%INDENT_MFILES  Smart-indent every .m file under folder recursively.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   indent_mfiles(folder)
%
%   Discovers paths via get_mfile_paths and applies indent_mfile to each.

    arguments

        folder (1,1) string { mustBeFolder }

    end

    mfile_paths = utilities.dev.get_mfile_paths( folder ) ;

    for fi = 1 : numel ( mfile_paths )

        fp = mfile_paths ( fi ) ;

        utilities.dev.indent_mfile ( fp ) ;

    end % for

end % function
