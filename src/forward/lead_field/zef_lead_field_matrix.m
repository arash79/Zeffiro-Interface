function zef = zef_lead_field_matrix(zef)
%ZEF_LEAD_FIELD_MATRIX  Dispatch lead-field assembly for EEG, MEG, EIT, TES (types 1–10).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Central entry for sensor lead fields that inverse methods later read as
%   zef.L. Does not build a mesh. Callers: modality wrappers
%   (zef_eeg_lead_field_isotropic and siblings), examples.forward.lead_field_example,
%   and (indirectly) Mesh tool → Run script.
%
%   zef.lead_field_type
%     1 EEG isotropic sigma(:,1)     → zef_lead_field_eeg_fem
%     2 MEG magnetometers            → zef_lead_field_meg_fem
%     3 MEG gradiometers             → zef_lead_field_meg_grad_fem
%     4 EIT                          → zef_lead_field_eit_fem
%     5 TES / tES                    → zef_lead_field_tes_fem
%     6–10 same modalities with anisotropic sigma(:,3:8)
%   Unknown types are ignored (no otherwise error); zef.L is left unchanged.
%
%   Source model: core.types.ZefSourceModel.from(zef.source_model). Continuous
%   Whitney/H(div)/St. Venant keep nearest_source_neighbour_inds; discrete
%   models clear them. Direction mode 1/2/3 → cartesian/normal/face_based.
%   Preconditioner 1/2 → lf_param.precond 'cholinc'/'ssor'. On CPU that
%   selects ichol(nofill) vs SSOR inside zef_transfer_matrix (EEG/TES) and
%   the inlined MEG/EIT PCG. GPU always uses Jacobi (1./diag(A)) and
%   ignores precond. solver_tolerance → pcg_tol (zef_init default 1e-6;
%   missing-field fallback here is 1e-8). preconditioner_tolerance is
%   copied to cholinc_tol but is not read by the PCG (ichol is nofill).
%
%   Coordinates: copies nodes to nodes_aux /1000 (metres). Sensor scaling
%   is zef_lead_field_sensors_aux for types 1–10: PEM EEG/EIT/TES (1,4,5
%   and anisotropic 6,9,10) use attached xyz/1000; MEG (2,3 and anisotropic
%   7,8) use zef.sensors xyz/1000; CEM attachment tables stay unscaled.
%   After the solve, location_unit 1/2/3 scales source_positions back to
%   mm/cm/m. If source_interpolation_on, calls zef_source_interpolation.
%
%   zef = zef_lead_field_matrix(zef)
%
%   Input / output
%     zef  - session struct. If omitted, read from base; if nargout is 0,
%            assigned back to base.
%
%   Fields written
%     L, source_positions, source_directions, source_ind, brain_activity_inds,
%     lead_field_time, lead_field_id. EIT also inv_bg_data, eit_ind, eit_count.
%     TES also S, eit_ind, eit_count. Temporary nodes_aux/sensors_aux removed.
%
%   See also zef_lead_field_eeg_fem, zef_source_interpolation, zef_run_forward_simulation.




if nargin == 0
    zef = evalin('base','zef');
end

zef.brain_ind = zef_find_active_compartment_ind(zef);
zef.active_compartment_ind = zef.brain_ind;

[zef.lead_field_id, zef.lead_field_id_max]  = zef_update_lead_field_id(zef.lead_field_id,zef.lead_field_id_max,'create');

tic;

if zef.source_direction_mode == 1
    zef.lf_param.direction_mode = 'cartesian';
end

if zef.source_direction_mode == 2
    zef.lf_param.direction_mode = 'normal';
end

if zef.source_direction_mode == 3
    zef.lf_param.direction_mode = 'face_based';
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

zef.brain_activity_inds = [];

if isempty(zef.non_source_ind)
    zef.brain_activity_inds = zef.brain_ind;
else
    zef.brain_activity_inds = setdiff(zef.brain_ind,zef.non_source_ind);
end

%% Determine which tetra are to be used as sources
%
% Start by limiting ourselves to tetra deep enough in the gray matter. The
% depth of 0 mm is used by default, but the below requirement for having at
% least 4 neighbours makes sure that we are not directly on the surface.

if ~ isfield(zef, 'acceptable_source_depth')
    warning(['Using default acceptable depth of ' num2str(0) ' mm for source tetra.'])
    zef.acceptable_source_depth = 0; % mm
end

% Interior source tetrahedra are those with four brain-face neighbours.
% This is the same occupancy test as sum(T_fi,1)==4 from zef_fi_dipoles,
% but only the neighbour count is needed here (G_fi is discarded).

valid_source_inds_builder = tets_with_four_brain_neighbours(zef.tetra, zef.brain_ind);

[~, ~, ~, zef.brain_activity_inds] = zef_deep_nodes_and_tetra( ...
    zef.nodes, ...
    zef.tetra, ...
    zef.brain_activity_inds, ...
    zef.acceptable_source_depth ...
    );

zef.brain_activity_inds = intersect(zef.brain_activity_inds, valid_source_inds_builder);

clear valid_source_inds_builder;

zef.n_sources_old = zef.n_sources;

for zef_i = 1 : length(zef.compartment_tags)
    eval(['zef.' zef.compartment_tags{zef_i} '_sources_old = zef.' zef.compartment_tags{zef_i} '_sources;']);
end

clear zef_i;

% Decompose source space into a rectangular lattice and extract the indices of
% the source tetra in this frame of reference. Nearest source neighbour inds
% will be empty when discrete source models are used.

[zef.nearest_source_neighbour_inds, zef.source_ind] = decomposition_and_source_index_fn( ...
    zef.nodes, ...
    zef.tetra, ...
    zef.brain_activity_inds, ...
    zef.source_model, ...
    zef.n_sources, ...
    zef.source_space_creation_iterations ...
    );

% Determine which tetra are to be used as sources in their own frame of
% reference.

zef.source_ind = zef.brain_activity_inds(zef.source_ind);
zef.n_sources_mod = 0;

zef.sensors_aux = zef.sensors;
zef.nodes_aux = zef.nodes/1000;

attached = [];
if isfield(zef, 'sensors_attached_volume')
    attached = zef.sensors_attached_volume;
end
zef.sensors_aux = zef_lead_field_sensors_aux(zef.lead_field_type, zef.sensors, attached);

zef.lf_param.dipole_mode = 1;

% Set wanted optimization system type. Default value is 'pbo'.

if isfield(zef, 'optimization_system_type')
    % Do nothing
else
    zef.optimization_system_type = 'pbo';
end

%% Call one of the lead field routines.

if zef.lead_field_type == 1

    if size(zef.sensors,2) == 6
        zef.lf_param.impedances = zef.sensors(:,6);
    end

    [zef.L, zef.source_positions, zef.source_directions] = zef_lead_field_eeg_fem( ...
        zef, ...
        zef.nodes_aux, ...
        {zef.tetra,zef.prisms}, ...
        {zef.sigma(:,1), zef.sigma_prisms}, ...
        zef.sensors_aux, ...
        zef.nearest_source_neighbour_inds, ...
        zef.optimization_system_type, ...
        zef.brain_ind, ...
        zef.source_ind, ...
        zef.lf_param ...
        );
end

if zef.lead_field_type == 2

    [zef.L, zef.source_positions, zef.source_directions] = zef_lead_field_meg_fem( ...
        zef, ...
        zef.nodes_aux, ...
        {zef.tetra,zef.prisms}, ...
        {zef.sigma(:,1),zef.sigma_prisms}, ...
        zef.sensors_aux, ...
        zef.nearest_source_neighbour_inds, ...
        zef.brain_ind, ...
        zef.source_ind, ...
        zef.lf_param ...
        );

end

if zef.lead_field_type == 3

    [zef.L, zef.source_positions, zef.source_directions] = zef_lead_field_meg_grad_fem( ...
        zef, ...
        zef.nodes_aux, ...
        {zef.tetra,zef.prisms}, ...
        {zef.sigma(:,1),zef.sigma_prisms}, ...
        zef.sensors_aux, ...
        zef.nearest_source_neighbour_inds, ...
        zef.brain_ind, ...
        zef.source_ind, ...
        zef.lf_param ...
        );

end

if zef.lead_field_type == 4

    if size(zef.sensors,2) == 6
        zef.lf_param.impedances = zef.sensors(:,6);
    end

    [zef.L, zef.inv_bg_data, zef.source_positions, zef.source_directions, zef.eit_ind, zef.eit_count] = zef_lead_field_eit_fem( ...
        zef, ...
        zef.nodes_aux, ...
        {zef.tetra,zef.prisms}, ...
        {zef.sigma(:,1),zef.sigma_prisms}, ...
        zef.sensors_aux, ...
        zef.nearest_source_neighbour_inds, ...
        zef.brain_ind, ...
        zef.source_ind, ...
        zef.lf_param ...
        );

end

if zef.lead_field_type == 5

    if size(zef.sensors,2) == 6
        zef.lf_param.impedances = zef.sensors(:,6);
    end


    [zef.L, zef.S, zef.source_positions, zef.source_directions, zef.eit_ind, zef.eit_count] = zef_lead_field_tes_fem( ...
        zef, ...
        zef.nodes_aux, ...
        {zef.tetra,zef.prisms}, ...
        {zef.sigma(:,1),zef.sigma_prisms}, ...
        zef.sensors_aux, ...
        zef.nearest_source_neighbour_inds, ...
        zef.brain_ind, ...
        zef.source_ind, ...
        zef.lf_param ...
        );

end

%%%SP 11/2025 START: anisotropic lead fields
if ismember(zef.lead_field_type, 6:10)
    zef_require_anisotropic_conductivity(zef);
end
if zef.lead_field_type == 6

    if size(zef.sensors,2) == 6
        zef.lf_param.impedances = zef.sensors(:,6);
    end

    [zef.L, zef.source_positions, zef.source_directions] = zef_lead_field_eeg_fem( ...
        zef, ...
        zef.nodes_aux, ...
        {zef.tetra,zef.prisms}, ...
        {zef.sigma(:,3:8), zef.sigma_prisms}, ...
        zef.sensors_aux, ...
        zef.nearest_source_neighbour_inds, ...
        zef.optimization_system_type, ...
        zef.brain_ind, ...
        zef.source_ind, ...
        zef.lf_param ...
        );
end

if zef.lead_field_type == 7

    [zef.L, zef.source_positions, zef.source_directions] = zef_lead_field_meg_fem( ...
        zef, ...
        zef.nodes_aux, ...
        {zef.tetra,zef.prisms}, ...
        {zef.sigma(:,3:8),zef.sigma_prisms}, ...
        zef.sensors_aux, ...
        zef.nearest_source_neighbour_inds, ...
        zef.brain_ind, ...
        zef.source_ind, ...
        zef.lf_param ...
        );

end

if zef.lead_field_type == 8

    [zef.L, zef.source_positions, zef.source_directions] = zef_lead_field_meg_grad_fem( ...
        zef, ...
        zef.nodes_aux, ...
        {zef.tetra,zef.prisms}, ...
        {zef.sigma(:,3:8),zef.sigma_prisms}, ...
        zef.sensors_aux, ...
        zef.nearest_source_neighbour_inds, ...
        zef.brain_ind, ...
        zef.source_ind, ...
        zef.lf_param ...
        );

end

if zef.lead_field_type == 9

    if size(zef.sensors,2) == 6
        zef.lf_param.impedances = zef.sensors(:,6);
    end

    [zef.L, zef.inv_bg_data, zef.source_positions, zef.source_directions, zef.eit_ind, zef.eit_count] = zef_lead_field_eit_fem( ...
        zef, ...
        zef.nodes_aux, ...
        {zef.tetra,zef.prisms}, ...
        {zef.sigma(:,3:8),zef.sigma_prisms}, ...
        zef.sensors_aux, ...
        zef.nearest_source_neighbour_inds, ...
        zef.brain_ind, ...
        zef.source_ind, ...
        zef.lf_param ...
        );

end

if zef.lead_field_type == 10

    if size(zef.sensors,2) == 6
        zef.lf_param.impedances = zef.sensors(:,6);
    end


    [zef.L, zef.S, zef.source_positions, zef.source_directions, zef.eit_ind, zef.eit_count] = zef_lead_field_tes_fem( ...
        zef, ...
        zef.nodes_aux, ...
        {zef.tetra,zef.prisms}, ...
        {zef.sigma(:,3:8),zef.sigma_prisms}, ...
        zef.sensors_aux, ...
        zef.nearest_source_neighbour_inds, ...
        zef.brain_ind, ...
        zef.source_ind, ...
        zef.lf_param ...
        );

end
%%%SP 11/2025 END: anisotropic lead fields

if ~ismember(zef.lead_field_type, 1:10)
    warning('zef_lead_field_matrix:UnknownType', ...
        'lead_field_type %g is not in 1–10; zef.L was not updated.', ...
        zef.lead_field_type);
end

zef = rmfield(zef,{'nodes_aux','sensors_aux'});

clear optimization_system_type;

zef.lead_field_time = toc;

%% Perform final unit conversions and source interpolation.

if zef.location_unit == 1
    zef.source_positions = 1000*zef.source_positions;
    zef.location_unit_current = 1;
end

if zef.location_unit == 2
    zef.source_positions = 100*zef.source_positions;
    zef.location_unit_current = 2;
end

if zef.location_unit == 3
    zef.location_unit_current = 3;
end

if zef.source_interpolation_on
    zef = zef_source_interpolation(zef);
end

if nargout == 0
    assignin('base','zef',zef);
end

end

%% Local helper functions

function [nearest_source_neighbour_inds, source_inds] = decomposition_and_source_index_fn( ...
    nodes, ...
    tetra, ...
    restricted_brain_inds, ...
    source_model, ...
    wanted_n_of_sources, ...
    source_space_creation_iterations ...
    )

% Documentation
%
% Generates (extrapolated) node (degree of freedom) and source indices for
% a node space.
%
% Input:
%
% - nodes
%
%   The finite element node cloud of the model under observation.
%
% - tetra
%
%   The tetrahedra (4-tuples of node indices) that are formed from the
%   above nodes.
%
% - restricted_brain_inds
%
%   The subset of tetra that dipolar sources can be placed into.
%
% - wanted_n_of_sources
%
%   The number of sources one wishes to generate.
%
% - source_space_creation_iterations
%
%   The number of extrapolation iterations performed to make sure that we
%   get as close to the wanted number of sources as was wanted.
%
% Output:
%
% - nearest_source_neighbour_inds
%
%   The indices that denote the node decomposition positions in the FEM
%   mesh.
%
% - source_inds
%
%   The tetrahedra that will be used as sources, based on the generated
%   decomposition.

arguments
    nodes (:,3) double
    tetra (:,4) double { mustBeInteger, mustBePositive }
    restricted_brain_inds (:,1) double { mustBeInteger, mustBePositive }
    source_model
    wanted_n_of_sources (1,1) double { mustBeInteger, mustBePositive }
    source_space_creation_iterations (1,1) double { mustBeInteger, mustBePositive }
end

% Create initial decomposition of node (degree of freedom, DOF) space.

[nearest_source_neighbour_inds, ~, ~, source_inds] = zef_decompose_dof_space( ...
    nodes, ...
    tetra, ...
    restricted_brain_inds, ...
    [], ...
    wanted_n_of_sources, ...
    2 ...
    );

% Extrapolate, if we have less sources than we wanted.

n_of_sources = wanted_n_of_sources;

for ind = 1 : source_space_creation_iterations

    n_of_sources = round(wanted_n_of_sources * n_of_sources / length(source_inds));

    [nearest_source_neighbour_inds, ~, ~, source_inds] = zef_decompose_dof_space( ...
        nodes, ...
        tetra, ...
        restricted_brain_inds, ...
        [], ...
        n_of_sources, ...
        2 ...
        );

end

% Set empty decomposition indices, if source model is not continuous.

switch core.types.ZefSourceModel.from(source_model)

    case core.types.ZefSourceModel.Error

        error('Received and erraneous source model.')

    case { ...
            core.types.ZefSourceModel.ContinuousWhitney, ...
            core.types.ZefSourceModel.ContinuousHdiv, ...
            core.types.ZefSourceModel.ContinuousStVenant ...
            }

        % Do nothing

    otherwise

        nearest_source_neighbour_inds = [];

end % switch

end % function

function valid = tets_with_four_brain_neighbours(tetrahedra, brain_ind)
% Interior brain tetrahedra: every face is shared with another brain tet.
% Equivalent to full(find(sum(T_fi,1)==4))' from zef_fi_dipoles.

if isempty(brain_ind)
    valid = zeros(0, 1);
    return
end

n_tet = size(tetrahedra, 1);
n_brain = numel(brain_ind);
face_opp = [
    2 3 4
    1 3 4
    1 2 4
    1 2 3
    ];

keys = zeros(4 * n_brain, 3);
owners = zeros(4 * n_brain, 1);
for f = 1:4
    sl = (f - 1) * n_brain + (1:n_brain);
    keys(sl, :) = sort(tetrahedra(brain_ind, face_opp(f, :)), 2);
    owners(sl) = brain_ind;
end

[~, ~, ic] = unique(keys, 'rows');
counts = accumarray(ic, 1);

if any(counts > 2)
    error('Non-manifold tetrahedral mesh: a face belongs to more than two brain tetrahedra.');
end

pair_owners = owners(counts(ic) == 2);
n_neighbours = accumarray(pair_owners, 1, [n_tet, 1]);
valid = find(n_neighbours == 4);
end
