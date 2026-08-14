function str = zef_string_from_source_model(input)
%ZEF_STRING_FROM_SOURCE_MODEL  Map a few ZefSourceModel members to strings.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Switch on core.types.ZefSourceModel: Error → 'Error', Whitney →
%   'Whitney', Hdiv → 'H(div)'. Any other member (StVenant, Continuous*,
%   …) warns and returns 'Error'. Live display names are
%   ZefSourceModel.to_string. No first-party callers in this tree.
%
%   str = zef_string_from_source_model(input)
%
%   Input
%     input - core.types.ZefSourceModel value.
%
%   Output
%     str - 'Whitney', 'H(div)', or 'Error'.
%
%   See also core.types.ZefSourceModel.
switch input
    case core.types.ZefSourceModel.Error
        str = 'Error';
    case core.types.ZefSourceModel.Whitney
        str = 'Whitney';
    case core.types.ZefSourceModel.Hdiv
        str = 'H(div)'
    otherwise
        warning("Did not receive a valid core.types.ZefSourceModel. Returning Error.")
        str = 'Error';
end
end
