%ZEF_SYNTHETIC_EIT_DATA  EIT forward into zef.measurements with ROI bumps.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Find synthetic EIT data → Compute. Copies ROI edits via
%   zef_update_find_synthetic_eit_data (caller), scales nodes mm→m, then
%   zef.measurements = zef_compute_eit_data(...). Needs nodes, tetra,
%   sigma, sensors, current_pattern. ROI spheres in zef_compute_eit_data
%   are mm→m; the mesh must therefore already be metres.
%
%   See also zef_compute_eit_data, zef_find_synthetic_eit_data.

tic;

if zef.source_direction_mode == 1
    zef.lf_param.direction_mode = 'cartesian';
end
if zef.source_direction_mode == 2
    zef.lf_param.direction_mode = 'normal';
end
if zef.source_direction_mode == 3
    zef.lf_param.direction_mode = 'basis';
end
if isfield(zef,'preconditioner')
    if zef.preconditioner == 1
        zef.lf_param.precond = 'cholinc';
    elseif zef.preconditioner == 2
        zef.lf_param.precond = 'ssor';
    end
end
if isfield(zef,'preconditioner_tolerance')
    zef.lf_param.cholinc_tol = zef.preconditioner_tolerance;
else
    zef.lf_param.cholinc_tol = 0.001;
end
if isfield(zef,'solver_tolerance')
    zef.lf_param.pcg_tol = zef.solver_tolerance;
else
    zef.lf_param.pcg_tol = 1e-8;
end
zef.aux_vec = [];
if isempty(zef.source_ind) || not(zef.n_sources == zef.n_sources_old) || not(zef.wm_sources == zef.wm_sources_old)
    if isempty(zef.non_source_ind)
        zef.aux_vec = zef.brain_ind;
    else
        zef.aux_vec = setdiff(zef.brain_ind,zef.non_source_ind);
    end
    zef.aux_vec = zef.aux_vec(randperm(length(zef.aux_vec)));
    zef.n_sources_old = zef.n_sources;
    zef.wm_sources_old = zef.wm_sources;
    zef.source_ind = zef.aux_vec(1:min(zef.n_sources,length(zef.aux_vec)));
    zef.n_sources_mod = 0;
end
zef.sensors_aux = zef.sensors;
zef.nodes_aux = zef.nodes/1000;

attached = [];
if isfield(zef, 'sensors_attached_volume')
    attached = zef.sensors_attached_volume;
end
lf_type = [];
if isfield(zef, 'lead_field_type')
    lf_type = zef.lead_field_type;
end
if isfield(zef, 'imaging_method') && ismember(zef.imaging_method, [4 9])
    lf_type = zef.imaging_method;
elseif isempty(lf_type) || ~ismember(lf_type, [4 9])
    lf_type = 4;
end
if size(zef.sensors, 2) == 3 && isempty(attached)
    zef.sensors_aux = zef.sensors(:, 1:3) / 1000;
else
    zef.sensors_aux = zef_lead_field_sensors_aux(lf_type, zef.sensors, attached);
end

zef.lf_param.dipole_mode = 1;

% This script is the EIT Compute button: always run. Also honour
% imaging_method / lead_field_type 4 or 9 when those fields exist.
[zef.measurements] = zef_compute_eit_data(zef.nodes_aux,zef.tetra,zef.sigma(:,1),zef.sensors_aux,zef.brain_ind,zef.source_ind,zef.lf_param);

zef = rmfield(zef,{'nodes_aux','sensors_aux','aux_vec'});
