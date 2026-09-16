function [payload, report] = run(source)
%RUN  Convert a DUNEuro file or export folder to native Zeffiro fields (no session).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Same conversion as convert(). Use import_duneuro_project or File →
%   Open project to merge the result into a live session.
%
%   [payload, report] = run(path_or_struct)
%
%   See also convert, import_duneuro_project.

    if nargin < 1 || isempty(source)
        error('duneuro2zef:EmptyProject', 'A DUNEuro file, folder, or struct is required.');
    end
    [payload, report] = utilities.duneuro2zef.convert(source);
end
