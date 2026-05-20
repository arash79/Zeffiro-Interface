% --- Zeffiro documentation header ---
% tic; — Tic;.
%
% Purpose:
%   Tic;.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.aux_vec (read, write)
%   zef.brain_ind (read)
%   zef.imaging_method (read)
%   zef.lf_param (read)
%   zef.measurements (read)
%   zef.n_sources (read, write)
%   zef.n_sources_mod (read, write)
%   zef.n_sources_old (read, write)
%   zef.nodes (read)
%   zef.nodes_aux (read, write)
%   zef.non_source_ind (read)
%   zef.preconditioner (read, write)
%   zef.preconditioner_tolerance (read)
%   zef.rho (read)
%   zef.sensors (read)
%   … (7 more)
%
% Calls (project):
%   zef_compute_gravity_data
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `tic;` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

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
zef.nodes_aux = zef.nodes;

zef.sensors_aux(:,1:3) = zef.sensors_aux(:,1:3);

zef.lf_param.dipole_mode = 1;

if ismember(zef.imaging_method, [1 2 3 4])
    [zef.measurements] = zef_compute_gravity_data(zef.nodes_aux,zef.tetra,zef.rho(:,1),zef.sensors_aux,zef.brain_ind,zef.source_ind,zef.lf_param);
end

zef = rmfield(zef,{'nodes_aux','sensors_aux','aux_vec'});
