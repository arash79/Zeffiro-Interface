function [L_eit,  bg_data, source_locations, source_directions] = zef_lead_field_gravity_grad(nodes,elements,rho,sensors,varargin)
%LEAD_FIELD_GRAVITY_GRAD  Gravity-gradient lead field from density rho (types 1–2).
%
%   Zeffiro Interface.
%   Copyright © 2018, Sampsa Pursiainen
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%
%   Called as zef_lead_field_gravity_grad from the asteroid INI scripts
%   zef_gravity_gradient_lead_field_scalar / _vector and from
%   zef_lead_field_matrix_gravity when gravity_field_type is 1 or 2.
%   The first function in this file is zef_lead_field_gravity_grad.
%   Reads zef.source_model and zef.gravity_field_type from the base
%   workspace. Uses the sensors argument (xyz + direction); it is not
%   overwritten from base. Density rho: 1-col isotropic (replicated onto
%   the first three tensor slots) or 6-col, optional {tetra, prism} cell.
%   Geometry is converted mm→m for the kernels; source_locations stay in
%   the session millimetre frame.
%
%   Type 1 (scalar): L is n_stations × n_sources. Kernel
%     V * (dir · (c − s)) / ||c−s||^3
%   on tet barycentres c, station xyz s (metres), unit dir = sensors(:,4:6).
%   Type 2 (vector): L is 3*n_stations × n_sources,
%     V * (−dir/||r||^3 + 3 (dir·r) r / ||r||^5)
%   i.e. the directional derivative of g = V r/||r||^3 at the station.
%   Both multiply L and bg_data by G = 6.67408e-11. Geometry is converted
%   mm→m inside this file; source_locations stay in the session millimetre
%   frame. Background bg_data sums the same kernels weighted by rho on
%   every tet. Source grouping uses zef_make_gravity_dec.
%   source_directions is ones(size(locations)).
%
%   The sensors argument is used as given (xyz + direction). It is not
%   overwritten from the base workspace.
%
%   [L_eit, bg_data, source_locations, source_directions] = ...
%       zef_lead_field_gravity_grad(nodes, elements, rho, sensors, varargin)
%
%   varargin: gravity_ind, source_ind, then optional lf_param struct
%   (pcg_tol, maxit, precond, direction_mode, source_mode, cholinc_tol,
%   permutation) — parsed like EEG FEM; PCG fields are unused here.
%
%   See also zef_gravity_gradient_lead_field_scalar, zef_lead_field_gravity.

N = size(nodes,1);
source_model = evalin('base','zef.source_model');

% Convert source model to new format.

source_model = core.types.ZefSourceModel.from(source_model);

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

if iscell(rho)
    rho{1} = rho{1}';
    if size(rho{1},1) == 1
        rho_tetrahedra = [repmat(rho{1},3,1) ; zeros(3,size(rho{1},2))];
    else
        rho_tetrahedra = rho{1};
    end
    rho_prisms = [];
    if length(rho)>1
        rho{2} = rho{2}';
        if size(rho{2},1) == 1
            rho_prisms = [repmat(rho{2},3,1) ; zeros(3,size(rho{2},2))];
        else
            rho_prisms = rho{2};
        end
    end
else
    rho = rho';
    if size(rho,1) == 1
        rho_tetrahedra = [repmat(rho,3,1) ; zeros(3,size(rho,2))];
    else
        rho_tetrahedra = rho;
    end
    rho_prisms = [];
end
clear elements;

tol_val = 1e-6;
m_max = 3*floor(sqrt(N));
precond = 'cholinc';
permutation = 'symamd';
direction_mode = 'mesh based';
source_mode = 1;
gravity_ind = [1:size(tetrahedra,1)]';
source_ind = [1:size(tetrahedra,1)]';
cholinc_tol = 1e-3;

L = size(sensors,1);

n_varargin = length(varargin);
if n_varargin >= 1
    if not(isstruct(varargin{1}))
        gravity_ind = varargin{1};
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
        if isfield(varargin{n_varargin},'source_mode');
            source_mode = varargin{n_varargin}.source_mode;
        end

        if isfield(varargin{n_varargin},'cholinc_tol')
            cholinc_tol = varargin{n_varargin}.cholinc_tol;
        end
        if isfield(varargin{n_varargin},'permutation')
            permutation = varargin{n_varargin}.permutation;
        end
    end
end
K = size(tetrahedra,1);
K3 = length(source_ind);
K4 = length(gravity_ind);

nodes_m = nodes / 1000;
sensors_m = sensors(:,1:3) / 1000;
tilavuus = zef_tetra_volume(nodes_m, tetrahedra, true);
c_tet = 0.25*(nodes_m(tetrahedra(:,1),:) + nodes_m(tetrahedra(:,2),:) + nodes_m(tetrahedra(:,3),:) + nodes_m(tetrahedra(:,4),:));

[eit_ind, ~] = zef_make_gravity_dec(nodes,tetrahedra,gravity_ind,source_ind);

h = zef_waitbar(0,1,'Lead field.');
gtype = evalin('base','zef.gravity_field_type');
if size(sensors, 2) < 6
    error("Zeffiro:Gravity:MissingDirections", ...
        "Gravity gradient types 1–2 need sensors(:,4:6) as the unit direction.");
end
directions = sensors(:,4:6);
directions = directions ./ sqrt(sum(directions.^2, 2));

% Vector gradient: 3 rows per station (type 2).
if gtype == 2

    L_eit = zeros(3*L, K3);
    bg_data = zeros(3*L,1);

    for i = 1 : K4

        diff_vec_aux = c_tet(gravity_ind(i),:) - sensors_m;
        aux_vec = zef_gravity_newton_kernel(diff_vec_aux, tilavuus(gravity_ind(i)), 2, directions);
        L_eit(:,eit_ind(i)) = L_eit(:,eit_ind(i)) + aux_vec(:);


        if mod(i,max(1,floor(K4/50)))==0
            time_val = toc;
            zef_waitbar(i,K4,h,['Lead field. Ready approx: ' datestr(datevec(now+(K4/i - 1)*time_val/86400)) '.']);
        end
    end

    for i = 1 : K

        diff_vec_aux = c_tet(i,:) - sensors_m;
        aux_vec = zef_gravity_newton_kernel(diff_vec_aux, tilavuus(i), 2, directions);
        bg_data = bg_data + rho_tetrahedra(1,i)*aux_vec(:);


        if mod(i,max(1,floor(K/50)))==0
            time_val = toc;
            zef_waitbar(i,K,h,['Background Ready approx: ' datestr(datevec(now+(K/i - 1)*time_val/86400)) '.']);
        end
    end

% Scalar gradient: one row per station, n·g (type 1).
elseif gtype == 1

    L_eit = zeros(L, K3);
    bg_data = zeros(L,1);

    for i = 1 : K4

        diff_vec_aux = c_tet(gravity_ind(i),:) - sensors_m;
        aux_vec = zef_gravity_newton_kernel(diff_vec_aux, tilavuus(gravity_ind(i)), 1, directions);
        L_eit(:,eit_ind(i)) = L_eit(:,eit_ind(i)) + aux_vec(:);


        if mod(i,max(1,floor(K4/50)))==0
            time_val = toc;
            zef_waitbar(i,K4,h,['Lead field. Ready approx: ' datestr(datevec(now+(K4/i - 1)*time_val/86400)) '.']);
        end
    end

    for i = 1 : K

        diff_vec_aux = c_tet(i,:) - sensors_m;
        aux_vec = zef_gravity_newton_kernel(diff_vec_aux, tilavuus(i), 1, directions);
        bg_data = bg_data + rho_tetrahedra(1,i)*aux_vec(:);


        if mod(i,max(1,floor(K/50)))==0
            time_val = toc;
            zef_waitbar(i,K,h,['Background. Ready approx: ' datestr(datevec(now+(K/i - 1)*time_val/86400)) '.']);
        end
    end

end

zef_close_waitbar(h);

L_eit = (6.67408E-11)*L_eit;
bg_data = (6.67408E-11)*bg_data;

source_locations = (nodes(tetrahedra(source_ind,1),:) + nodes(tetrahedra(source_ind,2),:) + nodes(tetrahedra(source_ind,3),:)+ nodes(tetrahedra(source_ind,4),:))/4;
source_directions = ones(size(source_locations));
