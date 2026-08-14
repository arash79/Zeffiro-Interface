%ZEF_REMOVE_OBJECT_FIELDS  Drop graphics/object fields from zef_data (script).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script: expects zef_data in the caller workspace. fieldnames that
%   isobject() are rmfield'd, then the helper fields fieldnames and
%   remove_fieldnames. Used when stripping handles before save/export.
%   Nested structs are not walked (top-level objects only).

zef_data.fieldnames = fieldnames(zef_data);
zef_data.remove_fieldnames = cell(0);
zef_j = 0;
for zef_i = 1 : length(zef_data.fieldnames)
    if isobject(eval(['zef_data.' zef_data.fieldnames{zef_i}]))
        zef_j = zef_j + 1;
        zef_data.remove_fieldnames{zef_j} = zef_data.fieldnames{zef_i};
    end
end
zef_data = rmfield(zef_data,zef_data.remove_fieldnames);
zef_data = rmfield(zef_data,{'remove_fieldnames','fieldnames'});
clear zef_i zef_j
