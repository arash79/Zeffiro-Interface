function capability = method_capability(method_id)
%METHOD_CAPABILITY  Sensitivity-study strategy metadata per inverse method id.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   capability = method_capability(method_id)
%
%   Returns struct with method_id, strategy (linear_static, iterative_static,
%   stateful_dynamic, unsupported), optional prep_hooks, and notes describing
%   how run_monte_carlo should batch and initialize each inverter.

arguments
    method_id (1,1) string {mustBeNonempty}
end

id = lower(strtrim(method_id));

capability = struct( ...
    "method_id",  method_id, ...
    "strategy",   "unsupported", ...
    "prep_hooks", strings(1, 0), ...
    "notes",      "" ...
);

switch id
    case {"csm", "dspm", "sloreta", "sloreta3d", "sbl", "mne", "wmne", "eloreta"}
        capability.strategy = "linear_static";
        capability.notes = "Linear inverter with cached operator; sensitivity uses bounded batches and preserves full-run initialization statistics.";

    case {"dipolescan", "dipole_scan"}
        capability.strategy = "iterative_static";
        capability.notes = "Per-source SVDs cached by precompute(); sensitivity uses bounded batches and preserves full-run initialization statistics.";

    case "beamformer"
        capability.strategy = "iterative_static";
        capability.notes = "Per-source weights recomputed each call; bounded batches are correct but cost scales with n_active per probe.";

    case "ias"
        capability.strategy = "iterative_static";
        capability.notes = "Per-frame IAS iterations; bounded batches are correct.";

    case "ramus"
        capability.strategy = "iterative_static";
        capability.prep_hooks = "ramus_decomposition";
        capability.notes = "Multiresolution + IAS per frame; sensitivity preflight auto-builds the multiresolution decomposition if it is empty.";

    case "halpr"
        capability.strategy = "iterative_static";
        capability.notes = "Hierarchical adaptive Lp regression; bounded batches are correct.";

    case {"grouplasso", "group_lasso"}
        capability.strategy = "iterative_static";
        capability.notes = "Group Lasso IAS iterations; bounded batches are correct.";

    case {"kalman", "kf"}
        capability.strategy = "stateful_dynamic";
        capability.notes = "Kalman state mutates between frames; sensitivity loop dispatches one probe per frame with a fresh inverter (slower but correct).";

    case {"legacy_csm", "legacy_mne", "legacy_kalman", "legacy_ias", ...
            "legacy_ramus", "legacy_dipolescan", "legacy_beamformer", ...
            "legacy_sl1", "legacy_relax", "legacy_sesame", "legacy_hb", ...
            "legacy_mcmc", "legacy_music", "legacy_rap_music", "legacy_exp"}
        capability.strategy = "unsupported";
        capability.notes = "Legacy GUI-coupled solver; use the modern class-based equivalent (see utilities.cluster.inverse_method_registry).";

    otherwise
        capability.strategy = "unsupported";
        capability.notes = sprintf( ...
            "Unknown or unsupported method id '%s'; add a row to utilities.sensitivity.method_capability before driving it from zef_sensitivity_run.", ...
            method_id);
end

end
