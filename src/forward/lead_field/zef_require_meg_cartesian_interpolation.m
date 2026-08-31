function zef_require_meg_cartesian_interpolation(source_model)
%ZEF_REQUIRE_MEG_CARTESIAN_INTERPOLATION  Whitney or H(div) required for cartesian MEG.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Cartesian / normal MEG interpolation only maps Whitney (FI) and H(div)
%   (FI+EW) columns onto 3-column-per-source L. St. Venant and the
%   Continuous* models left L identically zero.
%
%   zef_require_meg_cartesian_interpolation(source_model)
%
%   See also zef_lead_field_meg_fem, zef_lead_field_meg_grad_fem.

    source_model = core.types.ZefSourceModel.from(source_model);
    ok = source_model == core.types.ZefSourceModel.Whitney ...
        || source_model == core.types.ZefSourceModel.Hdiv;
    if ~ok
        error('zef_lead_field_meg_fem:UnsupportedCartesianSourceModel', ...
            ['Cartesian/normal MEG interpolation is implemented for Whitney and H(div) only. ' ...
             'Source model "%s" would leave L identically zero.'], ...
            char(source_model.to_string()));
    end
end
