function mode = zef_strip_burr_mode(operation)
%ZEF_STRIP_BURR_MODE  Map a user operation to the burr-hole execution path.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   The choice follows the operation, not whether a volumetric mesh
%   happens to be stored. 'generate' and 'regenerate' rebuild conductivity
%   from surfaces and then apply the lead specification ('fresh').
%   'apply' updates the active volume in place ('reapply').
%
%   mode = zef_strip_burr_mode(operation)
%
%   See also zef_strip_apply_burr_holes, zef_postprocess_fem_mesh.

operation = lower(strtrim(char(string(operation))));
switch operation
    case {'generate', 'regenerate', 'fresh'}
        mode = 'fresh';
    case {'apply', 'update', 'reapply'}
        mode = 'reapply';
    otherwise
        error('zef:BurrHoleMode', ...
            'Unknown burr-hole operation ''%s''.', operation);
end

end
