function method_info = inverse_method_registry(method_id)
%INVERSE_METHOD_REGISTRY  Map inverse method id to class or legacy dispatch info.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   method_info = inverse_method_registry(method_id)
%
%   method_id is case-insensitive. Returns struct with fields method_id,
%   execution_kind ("class" or "legacy"), class_name (e.g. "inverse.CSMInverter"),
%   and legacy_function (e.g. "zef_CSM_iteration"). Aliases include csm/dspm/
%   sloreta/sbl → CSMInverter; mne/wmne → MNEInverter; kalman/kf → KalmanInverter;
%   ukfnmm/ukf_nmm → UKFNMMInverter; dipolescan/dipole_scan → DipoleScanInverter;
%   grouplasso/group_lasso → GroupLassoInverter; legacy_* ids map to historical
%   zef_* entry points.
%
%   Errors if method_id is unknown.

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
elseif any(id == ["ukfnmm", "ukf_nmm"])
    method_info.execution_kind = "class";
    method_info.class_name = "inverse.UKFNMMInverter";
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
