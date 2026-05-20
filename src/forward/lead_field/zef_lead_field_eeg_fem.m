%%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% function [L_eeg, dipole_locations, dipole_directions] = lead_field_eeg_fem( ... — Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
%
% Purpose:
%   Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
%   Folder: Sensor lead-field matrices (EEG, MEG, EIT, TES, gravity) and `zef_lead_field_matrix` dispatch on `core.types.ZefSourceModel`.
%
% Zef fields (observed):
%   zef.lf_param (read)
%   zef.sigma (read)
%   zef.source_model (read)
%   zef.use_gpu (read, write)
%
% Calls (project):
%   core.types.ZefSourceModel.from
%   zef_build_electrodes
%   zef_lead_field_interpolation
%   zef_pem2cem
%   zef_stiffness_matrix
%   zef_tetra_volume
%   zef_transfer_matrix
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `function [L_eeg, dipole_locations, dipole_directions] = lead_field_eeg_fem( ...` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header
function [L_eeg, dipole_locations, dipole_directions] = lead_field_eeg_fem( ...
    zef, ...
    nodes, ...
    elements, ...
    sigma, ...
    electrodes, ...
    p_nearest_neighbour_inds, ...
    optimization_system_type, ...
    varargin ...
    )

n_of_nodes = size(nodes,1);
source_model = eval('zef.source_model');

if iscell(elements)
    tetrahedra = elements{1};
    prisms = [];
    K2 = size(tetrahedra,1);
    waitbar_length = 4;
    if length(elements)>1
        prisms = elements{2};
        waitbar_length = 10;
    end
else
    tetrahedra = elements;
    prisms = [];
    K2 = size(tetrahedra,1);
    waitbar_length = 4;
end

clear elements;

if iscell(sigma)
    sigma{1} = sigma{1}';
    if size(sigma{1},1) == 1
        sigma_tetrahedra = [repmat(sigma{1},3,1) ; zeros(3,size(sigma{1},2))];
    else
        sigma_tetrahedra = sigma{1};
    end
    sigma_prisms = [];
    if length(sigma)>1
        sigma{2} = sigma{2}';
        if size(sigma{2},1) == 1
            sigma_prisms = [repmat(sigma{2},3,1) ; zeros(3,size(sigma{2},2))];
        else
            sigma_prisms = sigma{2};
        end
    end
else
    sigma = sigma';
    if size(sigma,1) == 1
        sigma_tetrahedra = [repmat(sigma,3,1) ; zeros(3,size(sigma,2))];
    else
        sigma_tetrahedra = sigma;
    end
    sigma_prisms = [];
end
clear elements;

tol_val = 1e-6;
m_max = 3*floor(sqrt(n_of_nodes));
precond = 'cholinc';
permutation = 'symamd';
direction_mode = 'mesh based';
dipole_mode = 1;
brain_ind = [1:size(tetrahedra,1)]';
source_ind = [1:size(tetrahedra,1)]';
cholinc_tol = 1e-3;

impedance_inf = 1;

if size(electrodes,2) == 4
    electrode_model = 'CEM';
    n_of_electrodes = max(electrodes(:,1));
    ele_ind = electrodes;
    impedance_vec = ones(max(electrodes(:,1)),1);
else
    electrode_model = 'PEM';
    n_of_electrodes = size(electrodes,1);
    ele_ind = zeros(n_of_electrodes,1);
    for i = 1 : n_of_electrodes
        [min_val, min_ind] = min(sum((repmat(electrodes(i,:),n_of_nodes,1)' - nodes').^2));
        ele_ind(i) = min_ind;
    end
    impedance_vec = ones(length(electrodes(:, 1)), 1);
end

n_varargin = length(varargin);
if n_varargin >= 1
    if not(isstruct(varargin{1}))
        brain_ind = varargin{1};
    end
end
if n_varargin >= 2
    if not(isstruct(varargin{2}))
        source_ind = varargin{2};
    end
end
if n_varargin >= 1
    if isstruct(varargin{n_varargin})
        if isfield(varargin{n_varargin},'pcg_tol');
            tol_val = varargin{n_varargin}.pcg_tol;
        end
        if  isfield(varargin{n_varargin},'maxit');
            m_max = varargin{n_varargin}.maxit;
        end
        if  isfield(varargin{n_varargin},'precond');
            precond = varargin{n_varargin}.precond;
        end
        if isfield(varargin{n_varargin},'direction_mode');
            direction_mode = varargin{n_varargin}.direction_mode;
        end
        if isfield(varargin{n_varargin},'dipole_mode');
            dipole_mode = varargin{n_varargin}.dipole_mode;
        end
        if isfield(varargin{n_varargin},'impedances') & size(electrodes,2) == 4;
            if length(varargin{n_varargin}.impedances)==1;
                impedance_vec = varargin{n_varargin}.impedances*ones(max(electrodes(:,1)),1);
                impedance_inf = 0;
            else
                impedance_vec = varargin{n_varargin}.impedances;
                impedance_inf = 0;
            end
        end
        if isfield(varargin{n_varargin},'cholinc_tol')
            cholinc_tol = varargin{n_varargin}.cholinc_tol;
        end
        if isfield(varargin{n_varargin},'permutation')
            permutation = varargin{n_varargin}.permutation;
        end
    end
end
K = length(brain_ind);

if not(isequal(lower(direction_mode),'cartesian') || isequal(lower(direction_mode),'normal'))
    source_model = 1;
end

% Convert source model to new format.

source_model = core.types.ZefSourceModel.from(source_model);

% Volume

tilavuus = zef_tetra_volume(nodes, tetrahedra, true);

% Stiffness matrix calculation

A = zef_stiffness_matrix(nodes, tetrahedra, tilavuus, sigma_tetrahedra);

% Build electrode matrices B and C based on A

if isequal(electrode_model,'CEM')
    ele_ind = zef_pem2cem(ele_ind,tetrahedra);
end

[A, B, C] = zef_build_electrodes( ...
    nodes, ...
    electrode_model, ...
    impedance_vec, ...
    impedance_inf, ...
    ele_ind, ...
    A ...
    );

% Transfer matrix T with preconditioned conjugate gradient (PCG) iteration

if impedance_inf == 0
    Schur_expression = @(Tcol, ind) B'* Tcol - C(:,ind);
else
    Schur_expression = @(Tcol, ind) - C(:,ind);
end

[T, Schur_complement, ~] = zef_transfer_matrix(...
    zef                                         ...
    ,                                               ...
    A                                           ...
    ,                                               ...
    B                                           ...
    ,                                               ...
    C                                           ...
    ,                                               ...
    n_of_nodes                                  ...
    ,                                               ...
    n_of_electrodes                             ...
    ,                                               ...
    electrode_model                             ...
    ,                                               ...
    permutation                                 ...
    ,                                               ...
    precond                                     ...
    ,                                               ...
    impedance_vec                               ...
    ,                                               ...
    impedance_inf                               ...
    ,                                               ...
    tol_val                                     ...
    ,                                               ...
    m_max                                       ...
    ,                                               ...
    Schur_expression                            ...
    );

% Guard: transfer matrix must be non-empty.  zef_transfer_matrix returns
% T = [] when the PCG solver does not converge (e.g. the stiffness matrix
% is non-positive-definite due to invalid conductivity tensors).  Detecting
% this here avoids a confusing "dimension mismatch" error later.
if isempty(T)
    error('zef_lead_field_eeg_fem:pcg_failed', ...
        ['PCG iteration did not converge: the transfer matrix is empty.\n' ...
         'Possible causes:\n' ...
         '  1. The conductivity tensor in zef.sigma(:,3:8) is not positive-definite\n' ...
         '     for one or more tetrahedra (e.g. non-zero off-diagonal terms σ12/σ13/σ23\n' ...
         '     left over from a DTI run mixed with new NIfTI diagonal values).\n' ...
         '  2. Some tetrahedra have zero conductivity (check fallback_val and FOV coverage\n' ...
         '     of your NIfTI file, or re-run zef_nii_conductivity_to_sigma).\n' ...
         '  3. The PCG tolerance (zef.lf_param.pcg_tol = %g) may be too tight for this\n' ...
         '     system.  Try loosening it to 1e-6 or switching to CPU (zef.use_gpu = 0)\n' ...
         '     which uses incomplete-Cholesky preconditioning.'], ...
        tol_val);
end

% Interpolation.

if isequal(lower(direction_mode),'cartesian') || isequal(lower(direction_mode),'normal')

    dipole_locations = [];
    dipole_directions = [];

    % Set regularization parameter based on literature.
    % TODO: allow passing this in as a parameter.

    regparam = 1e-6;

    [G, dipole_locations] = zef_lead_field_interpolation( ...
        nodes, ...
        tetrahedra, ...
        brain_ind, ...
        source_model, ...
        source_ind, ...
        p_nearest_neighbour_inds, ...
        optimization_system_type, ...
        regparam ...
        );

    % Construct lead field with transfer matrix, Schur complement and
    % interpolation matrix G.

    L_eeg = Schur_complement \ (T' * G);

    % Set "correct" zero potential level. Corresponds to multiplying L_eeg with
    % restriction matrix R, seen in relevant articles such as
    % <https://iopscience.iop.org/article/10.1088/0031-9155/57/4/999/pdf>.

    L_eeg = L_eeg - mean(L_eeg, 1);

end % if
end % function
