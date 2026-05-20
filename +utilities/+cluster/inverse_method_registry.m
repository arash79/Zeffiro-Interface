function method_info = inverse_method_registry(method_id)
% --- Zeffiro documentation header ---
% utilities.cluster.inverse_method_registry — Inverse method registry.
%
% Purpose:
%   Inverse method registry.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   method_id
%
% Outputs:
%   method_info
%
% Calls (project):
%   utilities.cluster.inverse_method_registry
%
% Side effects:
%   - parallel/cluster
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[method_info] = utilities.cluster.inverse_method_registry(method_id)` with project root and `src` on the path.
% --- End Zeffiro documentation header

arguments
    method_id (1,1) string {mustBeNonempty}
end

id = lower(strtrim(method_id));
method_info = struct( ...
    "method_id", method_id, ...
    "execution_kind", "", ...
    "class_name", "", ...
    "legacy_function", "" ...
);

if any(id == ["csm", "dspm", "sloreta", "sloreta3d", "sbl"])
    method_info.execution_kind = "class";
    method_info.class_name = "inverse.CSMInverter";
elseif any(id == ["mne", "wmne"])
    method_info.execution_kind = "class";
    method_info.class_name = "inverse.MNEInverter";
elseif id == "eloreta"
    method_info.execution_kind = "class";
    method_info.class_name = "inverse.ELORETAInverter";
elseif any(id == ["kalman", "kf"])
    method_info.execution_kind = "class";
    method_info.class_name = "inverse.KalmanInverter";
elseif id == "beamformer"
    method_info.execution_kind = "class";
    method_info.class_name = "inverse.BeamformerInverter";
elseif any(id == ["dipolescan", "dipole_scan"])
    method_info.execution_kind = "class";
    method_info.class_name = "inverse.DipoleScanInverter";
elseif id == "ias"
    method_info.execution_kind = "class";
    method_info.class_name = "inverse.IASInverter";
elseif id == "ramus"
    method_info.execution_kind = "class";
    method_info.class_name = "inverse.RAMUSInverter";
elseif any(id == ["grouplasso", "group_lasso"])
    method_info.execution_kind = "class";
    method_info.class_name = "inverse.GroupLassoInverter";
elseif id == "halpr"
    method_info.execution_kind = "class";
    method_info.class_name = "inverse.HALpRInverter";
elseif id == "legacy_csm"
    method_info.execution_kind = "legacy";
    method_info.legacy_function = "zef_CSM_iteration";
elseif id == "legacy_mne"
    method_info.execution_kind = "legacy";
    method_info.legacy_function = "zef_find_mne_reconstruction";
elseif id == "legacy_kalman"
    method_info.execution_kind = "legacy";
    method_info.legacy_function = "zef_KF";
elseif id == "legacy_ias"
    method_info.execution_kind = "legacy";
    method_info.legacy_function = "zef_ias_iteration";
elseif id == "legacy_ramus"
    method_info.execution_kind = "legacy";
    method_info.legacy_function = "zef_ramus_iteration";
elseif id == "legacy_dipolescan"
    method_info.execution_kind = "legacy";
    method_info.legacy_function = "zef_dipoleScan";
elseif id == "legacy_beamformer"
    method_info.execution_kind = "legacy";
    method_info.legacy_function = "zef_beamformer";
elseif id == "legacy_sl1"
    method_info.execution_kind = "legacy";
    method_info.legacy_function = "zef_sl1_iteration";
elseif id == "legacy_relax"
    method_info.execution_kind = "legacy";
    method_info.legacy_function = "zef_relax_iteration";
elseif id == "legacy_sesame"
    method_info.execution_kind = "legacy";
    method_info.legacy_function = "SESAME_inversion";
elseif any(id == ["legacy_hb", "legacy_mcmc"])
    method_info.execution_kind = "legacy";
    method_info.legacy_function = "zef_mcmc";
elseif id == "legacy_music"
    method_info.execution_kind = "legacy";
    method_info.legacy_function = "MUSIC_iteration";
elseif id == "legacy_rap_music"
    method_info.execution_kind = "legacy";
    method_info.legacy_function = "RAP_MUSIC_iteration";
elseif id == "legacy_exp"
    method_info.execution_kind = "legacy";
    method_info.legacy_function = "exp_iteration";
else
    error("utilities.cluster:UnknownInverseMethod", ...
        "Unknown inverse method id '%s'.", method_id);
end

end
