function [L_meg, dipole_locations, dipole_directions] = lead_field_meg_fem( ...
    zef, ...
    nodes, ...
    elements, ...
    sigma, ...
    sensors, ...
    p_nearest_neighbour_inds, ...
    varargin ...
    )
%LEAD_FIELD_MEG_FEM  FEM MEG magnetometer lead field (types 2, 7).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called as zef_lead_field_meg_fem from zef_lead_field_matrix. Assembles the
%   conductivity stiffness, interpolates dipoles with G (Whitney / H(div) /
%   St. Venant), and forms B-field columns at magnetometer locations.
%   Sensor rows: positions(:,1:3) metres, orientations(:,4:6). Isotropic
%   sigma(:,1) or anisotropic sigma(:,3:8).
%
%   PCG for the stiffness system is inlined here (same Jacobi / SSOR /
%   ichol-nofill loops as zef_transfer_matrix). This file does not call
%   zef_transfer_matrix.
%
%   [L_meg, dipole_locations, dipole_directions] = zef_lead_field_meg_fem( ...
%       zef, nodes, elements, sigma, sensors, p_nearest_neighbour_inds, ...
%       brain_ind, source_ind, lf_param)
%
%   Output
%     L_meg              - [n_sensors × n_source_columns]
%     dipole_locations   - [n × 3] metres
%     dipole_directions  - [n × 3] or empty depending on direction_mode
%
%   See also zef_lead_field_matrix, zef_lead_field_meg_grad_fem.



N = size(nodes,1);
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
    K3 = size(prisms,1);
else
    tetrahedra = elements;
    prisms = [];
    K2 = size(tetrahedra,1);
    waitbar_length = 4;
    K3 = size(prisms,1);
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

[min_val, min_ind] = min(sum((repmat(sensors(1,1:3),N,1) - nodes).^2,2));
zero_ind = min_ind;
sensors = sensors';
sensors(4:6,:) = sensors(4:6,:)./repmat(sqrt(sum(sensors(4:6,:).^2)),3,1);
L = size(sensors,2);

tol_val = 1e-6;
m_max = 3*floor(sqrt(N));
precond = 'cholinc';
permutation = 'symamd';
direction_mode = 'face normals';
dipole_mode = 1;
brain_ind = [1:size(tetrahedra,1)]';
source_ind = [1:size(tetrahedra,1)]';
cholinc_tol = 1e-3;

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

% Calculate volume tilavuus

tilavuus = zef_tetra_volume(nodes, tetrahedra, true);

% Calculate stiffness matrix A

A = zef_stiffness_matrix(nodes, tetrahedra, tilavuus, sigma_tetrahedra);

% Calculate MEG load vector matrix B

ind_m = [ 2 3 4 ;
    3 4 1 ;
    4 1 2 ;
    1 2 3 ];

h=zef_waitbar(0,1,'MEG load vectors.');
waitbar_ind = 0;

% Biot–Savart-style MEG load B: for each tet node i and magnetometer j,
% (σ ∇ψ_i) × (r_sensor − r_centroid) / |r|^3, dotted with the coil
% orientation. tetra_c is the tet centroid. sensors rows 1:3 position
% (metres), 4:6 unit orientation (normalized above).
B = zeros(N,L);
tetra_c = (1/4)*(nodes(tetrahedra(:,1),:)+nodes(tetrahedra(:,2),:)+nodes(tetrahedra(:,3),:)+nodes(tetrahedra(:,4),:))';

tic;
load_vec_count = 0;
for i = 1 : 4

    grad_1 = cross(nodes(tetrahedra(:,ind_m(i,2)),:)'-nodes(tetrahedra(:,ind_m(i,1)),:)', nodes(tetrahedra(:,ind_m(i,3)),:)'-nodes(tetrahedra(:,ind_m(i,1)),:)')/2;
    grad_1 = repmat(sign(dot(grad_1,(nodes(tetrahedra(:,i),:)'-nodes(tetrahedra(:,ind_m(i,1)),:)'))),3,1).*grad_1;

    % σ∇ψ_i is independent of the magnetometer index j.
    cross_mat_aux = zeros(size(tetra_c));
    cross_mat_aux(1,:) = sigma_tetrahedra(1,:).*grad_1(1,:) + sigma_tetrahedra(4,:).*grad_1(2,:) + sigma_tetrahedra(5,:).*grad_1(3,:);
    cross_mat_aux(2,:) = sigma_tetrahedra(4,:).*grad_1(1,:) + sigma_tetrahedra(2,:).*grad_1(2,:) + sigma_tetrahedra(6,:).*grad_1(3,:);
    cross_mat_aux(3,:) = sigma_tetrahedra(5,:).*grad_1(1,:) + sigma_tetrahedra(6,:).*grad_1(2,:) + sigma_tetrahedra(3,:).*grad_1(3,:);
    tet_i = tetrahedra(:,i);

    for j = 1 : L

        sensor_mat_aux = sensors(1:3,j) - tetra_c;
        cross_mat = cross(cross_mat_aux, sensor_mat_aux);
        power_vec = sqrt(sum(sensor_mat_aux.^2, 1));
        power_vec = (power_vec.^2).*power_vec;
        ori = sensors(4:6,j);
        dot_vec = (ori(1)*cross_mat(1,:) + ori(2)*cross_mat(2,:) + ori(3)*cross_mat(3,:))./(3*power_vec);
        B(:,j) = B(:,j) + accumarray(tet_i, dot_vec(:), [N, 1]);

        load_vec_count = load_vec_count + 1;
        if mod(load_vec_count, floor(4*L/50))==0
            time_val = toc;
            zef_waitbar(load_vec_count,(4*L),h,['MEG load vectors. Ready: ' datestr(datevec(now+(4*L/load_vec_count - 1)*time_val/86400)) '.']);
        end

    end
end

time_val = toc;
zef_waitbar(1,1,h,['MEG load vectors. Ready: ' datestr(datevec(now+(4*L/i - 1)*time_val/86400)) '.']);

zef_waitbar(0,1,h,'System matrices.')

A(zero_ind,:) = 0;
A(:,zero_ind) = 0;
A(zero_ind,zero_ind) = 1;

if isequal(permutation,'symamd')
    perm_vec = symamd(A)';
elseif isequal(permutation,'symmmd')
    perm_vec = symmmd(A)';
elseif isequal(permutation,'symrcm')
    perm_vec = symrcm(A)';
else
    perm_vec = [1:N]';
end
iperm_vec = sortrows([ perm_vec [1:N]' ]);
iperm_vec = iperm_vec(:,2);
A_aux = A(perm_vec,perm_vec);
A = A_aux;
clear A_aux;


% Face-interior stencil: same dipoles as zef_fi_dipoles (shared-face pairs).

[T_fi, G_fi, fi_source_moments, fi_source_directions, fi_source_locations, M_fi] = zef_fi_dipoles( ...
    nodes, ...
    tetrahedra, ...
    brain_ind ...
    );

%Form G_ew and T_ew
if source_model == core.types.ZefSourceModel.Hdiv
    %*******************************
    %*******************************

    for i = 1 : 4
        for j = i + 1 : 4
            Ind_cell{i}{j} = [ brain_ind(:) tetrahedra(brain_ind(:),i)  tetrahedra(brain_ind(:),j) ];
        end
    end

    Ind_mat = [ Ind_cell{1}{2} ; Ind_cell{1}{3} ; Ind_cell{1}{4} ; Ind_cell{2}{3} ; Ind_cell{2}{4} ; Ind_cell{3}{4} ];
    clear Ind_cell;
    %[Ind_mat] = unique(Ind_mat,'rows');
    %Ind_mat = Ind_mat(find(ismember(Ind_mat(:,1),brain_ind)),:);

    Ind_mat(:,2:3) = sort(Ind_mat(:,2:3), 2);
    [edge_ind, edge_ind_aux_1, edge_ind_aux_2] = unique(Ind_mat(:,2:3),'rows');

    ew_source_directions = nodes(edge_ind(:,2),:) - nodes(edge_ind(:,1),:);
    ew_source_moments = sqrt(sum(ew_source_directions.^2,2));
    ew_source_directions = ew_source_directions./repmat(sqrt(sum(ew_source_directions.^2,2)),1,3);

    ew_source_locations = (1/2)*(nodes(edge_ind(:,1),:) + nodes(edge_ind(:,2),:));

    clear nodes_aux_vec_1 nodes_aux_vec_2;

    ones_aux = ones(size(ew_source_moments));
    M_ew = size(edge_ind,1);
    G_ew = sparse([edge_ind(:,1)  ; edge_ind(:,2)],repmat([1:M_ew]',2,1),[1./(ew_source_moments) ; -1./(ew_source_moments)],N,M_ew);

    T_ew = sparse(edge_ind_aux_2, Ind_mat(:,1), ones(length(edge_ind_aux_2),1), M_ew, K2);
    clear I tetrahedra_aux_ind_1 tetrahedra_aux_ind_2;

    %*******************************
    %*******************************
end

%%
if not(isequal(lower(direction_mode),'cartesian') || isequal(lower(direction_mode),'normal'))
    aux_rand_perm  = ceil(length(fi_source_locations)*source_ind/length(brain_ind));
    M_fi = length(aux_rand_perm);
    dipole_directions = fi_source_directions(aux_rand_perm,:);
    dipole_locations = fi_source_locations(aux_rand_perm,:);
    G_fi = G_fi(:,aux_rand_perm);
end
%%

% Primary dipole field at the coils (cross(q, r_coil-r_src)/|r|^3 · n),
% Whitney (fi) and optional H(div) edge (ew) bases. Secondary field from
% PCG potentials is added into L_meg_fi/ew below (x'*G).
L_meg_fi = zeros(L,M_fi);
for j = 1 : L
    cross_mat = cross(fi_source_directions', repmat(sensors(1:3,j),1,M_fi) - fi_source_locations');
    power_vec = sqrt(sum((repmat(sensors(1:3,j),1,M_fi) - fi_source_locations').^2));
    power_vec = (power_vec.^2).*power_vec;
    L_meg_fi(j,:) = dot(cross_mat,repmat(sensors(4:6,j),1,M_fi))./power_vec;
end

if source_model == core.types.ZefSourceModel.Hdiv
    L_meg_ew = zeros(L,M_ew);
    for j = 1 : L
        cross_mat = cross(ew_source_directions', repmat(sensors(1:3,j),1,M_ew) - ew_source_locations');
        power_vec = sqrt(sum((repmat(sensors(1:3,j),1,M_ew) - ew_source_locations').^2));
        power_vec = (power_vec.^2).*power_vec;
        L_meg_ew(j,:) = dot(cross_mat,repmat(sensors(4:6,j),1,M_ew))./power_vec;
    end
end

clear cross_mat;

zef_waitbar(0,1,h,'PCG iteration.');

if zef_session_wants_gpu(zef)
    precond_vec = gpuArray(1./full(diag(A)));
    A = gpuArray(A);

    relres_vec = zeros(1,L);
    tic;
    for i = 1 : L
        b = B(:,i);
        b(zero_ind) = 0;

        x = zeros(N,1);
        norm_b = norm(b);
        r = b(perm_vec);
        p = gpuArray(r);
        m = 0;
        x = gpuArray(x);
        r = gpuArray(r);
        p = gpuArray(p);
        norm_b = gpuArray(norm_b);

        while( (norm(r)/norm_b > tol_val) & (m < m_max))
            a = A * p;
            a_dot_p = sum(a.*p);
            aux_val = sum(r.*p);
            lambda = aux_val ./ a_dot_p;
            x = x + lambda * p;
            r = r - lambda * a;
            inv_M_r = precond_vec.*r;
            aux_val = sum(inv_M_r.*a);
            gamma = aux_val ./ a_dot_p;
            p = inv_M_r - gamma * p;
            m=m+1;
        end
        relres_vec(i) = gather(norm(r)/norm_b);
        r = gather(x(iperm_vec));
        x = r;
        L_meg_fi(i,:) = L_meg_fi(i,:) + x'*G_fi;
        if source_model == core.types.ZefSourceModel.Hdiv
            L_meg_ew(i,:) = L_meg_ew(i,:) + x'*G_ew;
        end
        if tol_val < relres_vec(i)
            zef_close_waitbar(h);
            'Error: PCG iteration did not converge.'
            L_meg = [];
            return
        end
        time_val = toc;
        zef_waitbar(i,L,h,['PCG iteration. Ready: ' datestr(datevec(now+(L/i - 1)*time_val/86400)) '.']);
    end

    %**************************************************************************
else

    %******************************************************
    %PCG CPU start
    %******************************************************
    %Define preconditioner
    if isequal(precond,'ssor');
        S1 = tril(A)*spdiags(1./sqrt(diag(A)),0,N,N);
        S2 = S1';
    else
        S2 = ichol(A,struct('type','nofill'));
        S1 = S2';
    end

    tol_val_aux = tol_val;

    %Define block size
    parallel_processes = eval('zef.parallel_processes');
    zef_ensure_parpool(parallel_processes);
    processes_per_core = eval('zef.processes_per_core');
    tic;
    block_size =  parallel_processes*processes_per_core;
    for i = 1 : block_size : L
        block_ind = [i : min(L,i+block_size-1)];

        %Define right hand side
        b = full(B(:,block_ind));
        b(zero_ind,:) = 0;

        tol_val = tol_val_aux.*ones(1,length(block_ind));

        %Iterate
        x_block_cell = cell(0);
        relres_cell = cell(0);
        x_block = zeros(N,length(block_ind));
        relres_vec = zeros(1,length(block_ind));
        tol_val = tol_val(:)';
        norm_b = sqrt(sum(b.^2));
        block_iter_end = block_ind(end)-block_ind(1)+1;
        [block_iter_ind] = [1 : processes_per_core : block_iter_end];
        parfor block_iter = 1 : length(block_iter_ind)
            block_iter_sub = [block_iter_ind(block_iter) : min(block_iter_end,block_iter_ind(block_iter)+processes_per_core-1)];
            x = zeros(N,length(block_iter_sub));
            r = b(perm_vec,block_iter_sub);
            aux_vec = S1 \ r;
            p = S2 \ aux_vec;
            m = 0;
            while( not(isempty(find(sqrt(sum(r.^2))./norm_b(block_iter_sub) > tol_val(block_iter_sub)))) & (m < m_max) )
                a = A * p;
                a_dot_p = sum(a.*p);
                aux_val = sum(r.*p);
                lambda = aux_val ./ a_dot_p;
                x = x + lambda .* p;
                r = r - lambda .* a;
                aux_vec = S1\r;
                inv_M_r = S2\aux_vec;
                aux_val = sum(inv_M_r.*a);
                gamma = aux_val ./ a_dot_p;
                p = inv_M_r - gamma .* p;
                m=m+1;
            end
            x_block_cell{block_iter} = x(iperm_vec,:);
            relres_cell{block_iter} = sqrt(sum(r.^2))./norm_b(block_iter_sub);
        end

        for block_iter = 1 : length(block_iter_ind)
            block_iter_sub = [block_iter_ind(block_iter) : min(block_iter_end,block_iter_ind(block_iter)+processes_per_core-1)];
            x_block(:,block_iter_sub) = x_block_cell{block_iter};
            relres_vec(block_iter_sub) = relres_cell{block_iter};
        end


        %Substitute matrices
        L_meg_fi(block_ind,:) = L_meg_fi(block_ind,:) + x_block'*G_fi;
        if source_model == core.types.ZefSourceModel.Hdiv
            L_meg_ew(block_ind,:) = L_meg_ew(block_ind,:) + x_block'*G_ew;
        end


        if not(isempty(find(tol_val < relres_vec)))
            zef_close_waitbar(h);
            'Error: PCG iteration did not converge.'
            L_meg = [];
            return
        end
        time_val = toc;

        zef_waitbar((i+length(block_ind)-1)*block_size,L,h,['PCG iteration. Ready: ' datestr(datevec(now+(L/(i+length(block_ind)-1) - 1)*time_val/86400)) '.']);

    end

    %******************************************************
    %PCG CPU end
    %******************************************************

end

clear S r p x aux_vec inv_M_r a b;

waitbar_ind = 0;

zef_waitbar(waitbar_ind,waitbar_length,h,'Interpolation.');
% Mean-zero coils (I − 11'/L) and μ0/4π scale. Cartesian/normal mode then
% maps Whitney/H(div) columns onto the 3-column-per-source layout via T_fi
% occupancy (surface_sources: sum(T_fi)>=0, else >=4).
Aux_mat_2 = eye(L,L) - (1/L)*ones(L,L);
L_meg_fi = Aux_mat_2*L_meg_fi/(4*pi);
if source_model == core.types.ZefSourceModel.Hdiv
    L_meg_ew = Aux_mat_2*L_meg_ew/(4*pi);
end

if isequal(lower(direction_mode),'cartesian')  || isequal(lower(direction_mode),'normal')

    if eval('zef.surface_sources')
        source_nonzero_ind = full(find(sum(T_fi)>=0))';
    else
        source_nonzero_ind = full(find(sum(T_fi)>=4))';
    end
    source_nonzero_ind = intersect(source_nonzero_ind,source_ind);
    M2 = size(source_nonzero_ind,1);
else
    L_meg = L_meg_fi;
end


if isequal(lower(direction_mode),'cartesian') || isequal(lower(direction_mode),'normal')

    zef_require_meg_cartesian_interpolation(source_model);

    c_tet = (nodes(tetrahedra(:,1),:) + nodes(tetrahedra(:,2),:) + nodes(tetrahedra(:,3),:)+ nodes(tetrahedra(:,4),:))/4;
    dipole_locations = c_tet(source_nonzero_ind,:);
    dipole_directions = [];
    L_meg = zeros(L,3*M2);

    if source_model == core.types.ZefSourceModel.Hdiv

        tic;
        for i = 1 : M2

            ind_vec_aux_fi = full(find(T_fi(:,source_nonzero_ind(i))));
            ind_vec_aux_ew = full(find(T_ew(:,source_nonzero_ind(i))));
            n_coeff_fi = length(ind_vec_aux_fi);
            n_coeff_ew = length(ind_vec_aux_ew);
            n_coeff = n_coeff_fi + n_coeff_ew;
            Aux_mat_1 = [fi_source_directions(ind_vec_aux_fi,:) ; ew_source_directions(ind_vec_aux_ew,:)];
            Aux_mat_2 = [fi_source_locations(ind_vec_aux_fi,:) ; ew_source_locations(ind_vec_aux_ew,:)];
            omega_vec = sqrt(sum((Aux_mat_2 - c_tet(source_nonzero_ind(i)*ones(n_coeff,1),:)).^2,2));
            PBO_mat = [diag(omega_vec) Aux_mat_1; Aux_mat_1' zeros(3,3)];
            Coeff_mat = PBO_mat\[zeros(n_coeff,3); eye(3)];
            L_meg(:,3*(i-1)+1:3*i) = L_meg_fi(:,ind_vec_aux_fi)*Coeff_mat(1:n_coeff_fi,:) + L_meg_ew(:,ind_vec_aux_ew)*Coeff_mat(n_coeff_fi+1:n_coeff,:) ;

            if mod(i,floor(M2/50))==0
                time_val = toc;
                zef_waitbar(i,M2,h,['Interpolation. Ready: ' datestr(datevec(now+(M2/i - 1)*time_val/86400)) '.']);
            end
        end
    end

    if source_model == core.types.ZefSourceModel.Whitney
        tic;
        for i = 1 : M2

            ind_vec_aux_fi = full(find(T_fi(:,source_nonzero_ind(i))));
            n_coeff_fi = length(ind_vec_aux_fi);
            n_coeff = n_coeff_fi;
            Aux_mat_1 = [fi_source_directions(ind_vec_aux_fi,:)];
            Aux_mat_2 = [fi_source_locations(ind_vec_aux_fi,:)];
            omega_vec = sqrt(sum((Aux_mat_2 - c_tet(source_nonzero_ind(i)*ones(n_coeff,1),:)).^2,2));
            PBO_mat = [diag(omega_vec) Aux_mat_1; Aux_mat_1' zeros(3,3)];
            Coeff_mat = PBO_mat\[zeros(n_coeff,3); eye(3)];
            L_meg(:,3*(i-1)+1:3*i) = L_meg_fi(:,ind_vec_aux_fi)*Coeff_mat(1:n_coeff_fi,:);

            if mod(i,floor(M2/50))==0
                time_val = toc;
                zef_waitbar(i,M2,h,['Interpolation. Ready: ' datestr(datevec(now+(M2/i - 1)*time_val/86400)) '.']);
            end
        end
    end

end

zef_waitbar(1,1,h);

zef_close_waitbar(h);
