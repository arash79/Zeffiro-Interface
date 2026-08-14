function out_reduced_interpolation_matrix = zef_kron_reduction( ...
    in_interpolation_matrix, ...
    in_schur_complement, ...
    in_electrode_model, ...
    in_source_model ...
    )

%ZEF_KRON_REDUCTION  Apply Schur complement to interpolation G for CEM Whitney/H(div).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   If the electrode model is CEM and the source model is Whitney or Hdiv,
%   returns inv(Schur)*G. PEM is a no-op. St. Venant is left unchanged
%   (TODO in source). Used when forming a reduced interpolation for
%   multiresolution / CEM lead fields.
%
%   out = zef_kron_reduction(in_interpolation_matrix, in_schur_complement, ...
%       in_electrode_model, in_source_model)
%
%   Input
%     in_interpolation_matrix - G
%     in_schur_complement     - square Schur block from zef_transfer_matrix
%     in_electrode_model      - 'CEM' or 'PEM'
%     in_source_model         - core.types.ZefSourceModel
%
%   See also zef_lead_field_eeg_fem, core.types.ZefSourceModel.


arguments
    in_interpolation_matrix
    in_schur_complement
    in_electrode_model { mustBeText, mustBeMember(in_electrode_model, {'CEM', 'PEM'}) }
    in_source_model { mustBeA(in_source_model, ["core.types.ZefSourceModel"]) }
end

out_reduced_interpolation_matrix = in_interpolation_matrix;

schur_size = size(in_schur_complement);

if strcmp(in_electrode_model,'CEM')

    switch in_source_model

        case { core.types.ZefSourceModel.Whitney, core.types.ZefSourceModel.Hdiv }

            inv_schur_complement = in_schur_complement \ eye(schur_size);

            out_reduced_interpolation_matrix = ...
                inv_schur_complement ...
                * ...
                in_interpolation_matrix ...
                ;

        case core.types.ZefSourceModel.StVenant

            % Do nothing. TODO: check whether St. Venant should also
            % trigger the reduction.

        otherwise

            error("Unknown source model. Should be one of core.types.ZefSourceModel.{Whitney, Hdiv, StVenant}");

    end
end
end
