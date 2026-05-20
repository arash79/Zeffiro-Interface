function [L, measurements] = zef_lead_field_whitening_diagonal_identity(lf_bank_index)
% --- Zeffiro documentation header ---
% zef_lead_field_whitening_diagonal_identity — Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
%
% Purpose:
%   Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   lf_bank_index
%
% Outputs:
%   L
%   measurements
%
% Zef fields (observed):
%   zef.lf_bank_storage (read)
%
% Calls (project):
%   zef_lead_field_whitening_diagonal_identity
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[L, measurements]] = zef_lead_field_whitening_diagonal_identity(lf_bank_index)` with project root and `src` on the path.
% --- End Zeffiro documentation header

%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%This function normalizes the lead field data for a given lead
%field bank entry.
%Description: Lead field whitening via noise data (diagonal set to identity)

L = evalin('base',['zef.lf_bank_storage{' num2str(lf_bank_index) '}.L']);
measurements = evalin('base',['zef.lf_bank_storage{' num2str(lf_bank_index) '}.measurements']);
noise_data = evalin('base',['zef.lf_bank_storage{' num2str(lf_bank_index) '}.noise_data']);

aux_mat_1 = cov(noise_data');
aux_mat_2 = inv(diag(sqrt(diag(aux_mat_1))));
aux_mat_1 = aux_mat_2*aux_mat_1*aux_mat_2;
inv_C = inv(sqrtm(aux_mat_1));

L = inv_C*L;
measurements = inv_C*measurements;

end
