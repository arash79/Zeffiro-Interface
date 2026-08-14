function h_struct = zef_gather_object_handles(zef,window_name)
%ZEF_GATHER_OBJECT_HANDLES  Nested struct of graphics handles by window Name.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   findall(groot,'-regexp','Name',window_name) then zef_find_object_handles
%   on that figure and on each child's Children. Default window_name is
%   'ZEFFIRO Interface'. No first-party GUI caller; zef_find_object_handles
%   exists only for this helper.
%
%   h_struct = zef_gather_object_handles(zef)
%   h_struct = zef_gather_object_handles(zef, window_name)
%
%   See also zef_find_object_handles.

if nargin == 1
    window_name = 'ZEFFIRO Interface';
end

h_groot = findall(groot,'-regexp','Name',window_name);
h_struct = zef_find_object_handles(zef, h_groot);

fields = fieldnames(h_struct);

for i = 1 : length(fields)
    if ismember('Children',properties(h_struct.(fields{i})))
        h_struct_aux = zef_find_object_handles(zef, cat(1,h_struct.(fields{i}).Children));
        h_struct.(fields{i}) = h_struct_aux;
    end
end

end
