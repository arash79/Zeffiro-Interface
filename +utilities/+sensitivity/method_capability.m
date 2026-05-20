function capability = method_capability(method_id)
% --- Zeffiro documentation header ---
% utilities.sensitivity.method_capability — Method capability.
%
% Purpose:
%   Method capability.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   method_id
%
% Outputs:
%   capability
%
% Calls (project):
%   utilities.sensitivity.method_capability
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[capability] = utilities.sensitivity.method_capability(method_id)` with project root and `src` on the path.
% --- End Zeffiro documentation header

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
        capability.prep_hooks = "halpr_decomposition";
        capability.notes = "Hierarchical adaptive Lp regression; sensitivity preflight auto-builds the multiresolution decomposition when use_multiresolution is true.";

    case {"grouplasso", "group_lasso"}
        capability.strategy = "iterative_static";
        capability.prep_hooks = "grouplasso_decomposition";
        capability.notes = "Group Lasso IAS iterations; sensitivity preflight auto-builds the multiresolution decomposition when use_multiresolution is true.";

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
