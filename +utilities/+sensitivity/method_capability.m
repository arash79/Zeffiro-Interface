function capability = method_capability(method_id)
%METHOD_CAPABILITY Sensitivity-pipeline metadata for an inverse method id.
%
%   capability = utilities.sensitivity.method_capability(method_id)
%
% Resolves whether a registry method id (see
% utilities.cluster.inverse_method_registry) can be driven by the Monte-Carlo
% sensitivity loop, and how. The sensitivity loop synthesises 3 * n_active
% (source, direction) probes per realisation, reconstructs static methods in
% bounded batches, and treats probes as independent time frames; not every
% inverter is compatible with that semantic.
%
% Output struct fields:
%   strategy   - "linear_static"     : per-frame is T*f with T cached by
%                                      precompute(); bounded batches avoid
%                                      monolithic reconstruction output.
%              - "iterative_static"  : per-frame is independent but iterative
%                                      (no usable precompute()); bounded
%                                      batches are correct, just slower.
%              - "stateful_dynamic"  : per-frame mutates inverter state
%                                      (Kalman family); requires the
%                                      isolated-probe path so each (source,
%                                      direction) starts from a fresh state.
%              - "unsupported"       : legacy / GUI-coupled solvers that the
%                                      sensitivity pipeline cannot drive
%                                      reliably; rejected up front by
%                                      zef_sensitivity_run.
%   prep_hooks - String array of named pre-dispatch hooks the caller should
%                run. Currently recognised: "ramus_decomposition",
%                "halpr_decomposition", "grouplasso_decomposition".
%   notes      - One-line student-facing note explaining the strategy choice
%                and any caveats.
%
% Keeping this table outside utilities.cluster.inverse_method_registry keeps
% the registry focused on dispatcher metadata. Add new entries here whenever
% a new inverter class lands so the sensitivity pipeline can route it.

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
