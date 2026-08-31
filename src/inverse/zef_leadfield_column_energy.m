function energy = zef_leadfield_column_energy(L, source_direction_mode)
%ZEF_LEADFIELD_COLUMN_ENERGY  Per-column lead-field energy for depth weights.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   energy = zef_leadfield_column_energy(L)
%   energy = zef_leadfield_column_energy(L, source_direction_mode)
%
%   Class-path L after zef_inverse_extract_bundle is interleaved xyz for
%   source_direction_mode 1 and 2: columns 3k-2:3k belong to source k.
%   Energy of that location is ||L_x||^2+||L_y||^2+||L_z||^2, replicated
%   across the three columns (Dale/Lin depth weight).
%
%   Mode 3 is one column per location. Using reshape(...,3,[]) on that
%   layout groups unrelated sources whenever n_cols happens to be a
%   multiple of 3. This helper uses per-column energy instead.
%
%   See also zef_inverse_extract_bundle, inverse.MNEInverter.

if nargin < 2 || isempty(source_direction_mode)
    source_direction_mode = 1;
end

col = sum(abs(L).^2, 1);
n = size(L, 2);
if ismember(source_direction_mode, [1, 2])
    if mod(n, 3) ~= 0
        error('zef:LeadFieldNotTriplets', ...
            ['L has %d columns; source_direction_mode %g requires ' ...
            'Cartesian triples (class-path interleaved xyz).'], ...
            n, source_direction_mode);
    end
    energy = repelem(sum(reshape(col, 3, []), 1), 3);
else
    energy = col;
end
if isempty(energy)
    return
end
if isa(energy, 'gpuArray')
    floor_val = gpuArray(eps(classUnderlying(energy)));
else
    floor_val = eps(class(energy));
end
energy = max(energy, floor_val);

end
