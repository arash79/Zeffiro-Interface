function out_reduced_interpolation_matrix = zef_kron_reduction( ...
% --- Zeffiro documentation header ---
% out_reduced_interpolation_matrix — Out reduced interpolation matrix.
%
% Purpose:
%   Out reduced interpolation matrix.
%   Folder: Sensor lead-field matrices (EEG, MEG, EIT, TES, gravity) and `zef_lead_field_matrix` dispatch on `core.types.ZefSourceModel`.
%
% Inputs:
%   in_interpolation_matrix
%   in_schur_complement
%   in_electrode_model
%   in_source_model
%
% Calls (project):
%   zef_kron_reduction
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `out_reduced_interpolation_matrix(in_interpolation_matrix, in_schur_complement, in_electrode_model, in_source_model)` with project root and `src` on the path.
% --- End Zeffiro documentation header
    in_interpolation_matrix, ...
    in_schur_complement, ...
    in_electrode_model, ...
    in_source_model ...
    )

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
