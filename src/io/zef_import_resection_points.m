%ZEF_IMPORT_RESECTION_POINTS  Load resection point coordinates from disk.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   uigetfile for *.dat or *.mat. Numeric arrays load directly; struct
%   files use the first field. Result is stored in zef.resection_points.
%
%   See also zef_import_parcellation_points.

[zef.file,zef.file_path] = uigetfile({'*.dat;*.mat'});

if not(isequal(zef.file,0))

    zef.aux_field_1 = load([zef.file_path '/' zef.file]);
    zef.aux_field_2 = [];

    if isstruct(zef.aux_field_1)
        zef.aux_field_2 = fieldnames(zef.aux_field_1);
        zef.resection_points = zef.aux_field_1.(zef.aux_field_2{1});
    else
        zef.resection_points = zef.aux_field_1;
    end

    zef = rmfield(zef,{'aux_field_1','aux_field_2'});

end
