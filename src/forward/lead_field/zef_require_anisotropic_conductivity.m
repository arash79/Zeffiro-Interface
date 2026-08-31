function zef_require_anisotropic_conductivity(zef)
%ZEF_REQUIRE_ANISOTROPIC_CONDUCTIVITY  Guard anisotropic lead-field types 6–10.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Types 6–10 read zef.sigma(:,3:8). Missing tensor columns would otherwise
%   throw a MATLAB index error. This check tells the user to apply DTI
%   (Forward tools → DTI Conductivity Tool) or otherwise fill those columns.
%
%   zef_require_anisotropic_conductivity(zef)
%
%   See also zef_lead_field_matrix, zef_dti_apply_to_sigma.

if nargin < 1 || ~isstruct(zef)
    error('zef:MissingAnisotropicConductivity', ...
        'Anisotropic lead field needs a Zeffiro session struct.');
end
if ~isfield(zef, 'sigma') || isempty(zef.sigma) || size(zef.sigma, 2) < 8
    error('zef:MissingAnisotropicConductivity', [ ...
        'Anisotropic lead field needs zef.sigma(:,3:8) ' ...
        '(six conductivity-tensor components per tetrahedron).\n' ...
        'Open Forward tools → DTI Conductivity Tool, load FA / v1 / ' ...
        'register.dat, click Apply to Mesh, then run this script.']);
end

end
