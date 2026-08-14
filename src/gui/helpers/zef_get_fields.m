function zef_data = zef_get_fields(fieldnames_aux, zef)
%ZEF_GET_FIELDS  Intended to copy named fields of zef into a struct.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Starts from an empty struct and, for each name in fieldnames_aux,
%   assigns zef_data.(name) = zef_data.(name). That does not read zef
%   (the second argument, or base-workspace zef when nargin==1) and
%   errors on the first missing field. No first-party callers in this
%   tree.
%
%   zef_data = zef_get_fields(fieldnames_aux)
%   zef_data = zef_get_fields(fieldnames_aux, zef)
%
%   Inputs
%     fieldnames_aux - cellstr of field names.
%     zef            - optional session (unused by the loop as written).
%
%   Output
%     zef_data - struct; would be empty if the loop never ran.
if nargin == 1
    zef = evalin('base','zef');
end

zef_data = struct;
for zef_i = 1 : length(fieldnames_aux)
    zef_data.(fieldnames_aux{zef_i}) = zef_data.(fieldnames_aux{zef_i});
end

end
