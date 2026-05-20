% --- Zeffiro documentation header ---
% zef.inv_hyperprior_weight = str2num(get(zef — Zef.inv hyperprior weight = str2num(get(zef.
%
% Purpose:
%   Zef.inv hyperprior weight = str2num(get(zef.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.h_inv_amplitude_db (read)
%   zef.h_inv_evolution_prior (read)
%   zef.h_inv_hyperprior (read)
%   zef.h_inv_hyperprior_tail_length_db (read)
%   zef.h_inv_prior_over_measurement_db (read)
%   zef.h_inv_snr (read)
%   zef.inv_amplitude_db (read, write)
%   zef.inv_evolution_prior (read, write)
%   zef.inv_hyperprior (read, write)
%   zef.inv_hyperprior_tail_length_db (read, write)
%   zef.inv_prior_over_measurement_db (read, write)
%   zef.inv_snr (read, write)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef.inv_hyperprior_weight = str2num(get(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef.inv_hyperprior_weight = str2num(get(zef.h_inv_hyperprior_weight,'Value'));
zef.inv_hyperprior = get(zef.h_inv_hyperprior,'Value');
zef.inv_hyperprior_tail_length_db = str2num(get(zef.h_inv_hyperprior_tail_length_db,'Value'));
zef.inv_snr = str2num(get(zef.h_inv_snr,'Value'));
zef.inv_prior_over_measurement_db = str2num(get(zef.h_inv_prior_over_measurement_db,'Value'));
zef.inv_amplitude_db = -str2num(get(zef.h_inv_amplitude_db,'Value'));
zef.inv_evolution_prior = str2num(get(zef.h_inv_evolution_prior, 'Value'));
