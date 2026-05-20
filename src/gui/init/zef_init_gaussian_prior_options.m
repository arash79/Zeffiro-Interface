% --- Zeffiro documentation header ---
% if not(isfield(zef,'inv_hyperprior_tail_length_db')); — If not(isfield(zef,'inv hyperprior tail length db'));.
%
% Purpose:
%   If not(isfield(zef,'inv hyperprior tail length db'));.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.inv_amplitude_db (read, write)
%   zef.inv_evolution_prior (read, write)
%   zef.inv_hyperprior (read, write)
%   zef.inv_hyperprior_tail_length_db (read, write)
%   zef.inv_hyperprior_weight (read, write)
%   zef.inv_prior_over_measurement_db (read, write)
%   zef.inv_snr (read, write)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if not(isfield(zef,'inv_hyperprior_tail_length_db'));` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

if not(isfield(zef,'inv_hyperprior_tail_length_db'));
    zef.inv_hyperprior_tail_length_db = 10;
end;
if not(isfield(zef,'inv_prior_over_measurement_db'));
    zef.inv_prior_over_measurement_db = 0;
end;

if not(isfield(zef,'inv_snr'));
    zef.inv_snr = 30;
end;

if not(isfield(zef,'inv_hyperprior'));
    zef.inv_hyperprior = 1;
end;

if not(isfield(zef,'inv_amplitude_db'));
    zef.inv_amplitude_db = 20;
end;

if not(isfield(zef,'inv_hyperprior_weight'));
    zef.inv_hyperprior_weight = 0;
end;

if not(isfield(zef,'inv_evolution_prior'));
    zef.inv_evolution_prior = -34;
end;
