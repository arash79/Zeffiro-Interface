function [I] = zef_tetra_in_compartment(reuna_p,reuna_t,nodes,varargin)
%ZEF_TETRA_IN_COMPARTMENT  Test which nodes lie inside a closed surface (tetra meshing).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Inclusion uses zef_meshing_runtime. Pass the session struct in
%   varargin, or leave it out to read zef from the base workspace.
%   Optional numeric arguments are compartment_info and meshing_threshold.
%   An optional graphics handle is the waitbar. A numeric meshing_threshold
%   is the cutoff that is applied.
%
%   I = zef_tetra_in_compartment(reuna_p, reuna_t, nodes)
%   I = zef_tetra_in_compartment(reuna_p, reuna_t, nodes, compartment_info)
%   I = zef_tetra_in_compartment(reuna_p, reuna_t, nodes, compartment_info, meshing_threshold)
%   I = zef_tetra_in_compartment(reuna_p, reuna_t, nodes, zef)
%
%   See also zef_point_in_compartment, zef_meshing_runtime.

settings = [];
compartment_info = [];
threshold_override = [];
h_waitbar = [];
n_numeric = 0;
for k = 1:numel(varargin)
    arg = varargin{k};
    if isstruct(arg)
        settings = arg;
    elseif ~isempty(arg) && isgraphics(arg)
        h_waitbar = arg;
    else
        n_numeric = n_numeric + 1;
        if n_numeric == 1
            compartment_info = arg;
        else
            threshold_override = arg;
        end
    end
end

runtime = zef_meshing_runtime(settings);
meshing_threshold = runtime.meshing_threshold;
if ~isempty(threshold_override)
    meshing_threshold = threshold_override;
end
meshing_accuracy = runtime.meshing_accuracy;

max_x = max(reuna_p(:,1));
min_x = min(reuna_p(:,1));
max_y = max(reuna_p(:,2));
min_y = min(reuna_p(:,2));
max_z = max(reuna_p(:,3));
min_z = min(reuna_p(:,3));
max_norm = max(sqrt(sum(reuna_p.^2,2)));
nodes_norm_vec = sqrt(sum(nodes.^2,2));

if meshing_accuracy < 1
    P.faces = reuna_t;
    P.vertices = reuna_p;
    P = reducepatch(P,meshing_accuracy);
    reuna_t = P.faces;
    reuna_p = P.vertices;
end

if meshing_accuracy > 1
    P.faces = reuna_t;
    P.vertices = reuna_p;
    P = reducepatch(P,min(1,min(size(reuna_t,1), meshing_accuracy)/size(reuna_t,1)));
    reuna_t = P.faces;
    reuna_p = P.vertices;
end

aux_vec_1 = (1/3)*(reuna_p(reuna_t(:,1),:) + reuna_p(reuna_t(:,2),:) + reuna_p(reuna_t(:,3),:))';
aux_vec_2 = reuna_p(reuna_t(:,2),:)'-reuna_p(reuna_t(:,1),:)';
aux_vec_3 = reuna_p(reuna_t(:,3),:)'-reuna_p(reuna_t(:,1),:)';
aux_vec_4 = cross(aux_vec_2,aux_vec_3)/2;

ind_vec = zeros(size(nodes,1),1);

I = find(nodes(:,1) <= max_x & nodes(:,1) >= min_x & nodes(:,2) <= max_y & nodes(:,2) >= min_y & nodes(:,3) <= max_z & nodes(:,3) >= min_z & nodes_norm_vec <= max_norm);

length_I = length(I);

tic;
ind_vec_aux = zeros(length_I,1);
nodes_aux = nodes(I,:)';

use_gpu  = runtime.use_gpu;

if use_gpu == 1 & runtime.gpu_count > 0
    nodes_aux = gpuArray(nodes_aux);
    aux_vec_1 = gpuArray(aux_vec_1);
    aux_vec_4 = gpuArray(aux_vec_4);
    ind_vec_aux = gpuArray(ind_vec_aux);
end

par_num = runtime.parallel_vectors;
bar_ind = ceil(length_I/(50*par_num));
i_ind = 0;

for i = 1 : par_num : length_I
    i_ind = i_ind + 1;
    block_ind = [i: min(i+par_num-1,length_I)];
    aux_vec = nodes_aux(:,block_ind);
    aux_vec = reshape(aux_vec,3,1,length(block_ind));
    aux_vec_5 = aux_vec_1 - aux_vec;
    aux_vec_2 = sum(aux_vec_5.*aux_vec_4);
    aux_vec_3 = sqrt(sum(aux_vec_5.*aux_vec_5));
    aux_vec_3 = (aux_vec_3.*aux_vec_3).*aux_vec_3;
    aux_vec_6 = sum(aux_vec_2./aux_vec_3)/(4*pi);
    ind_vec_aux(block_ind) = aux_vec_6(:);

    time_val = toc;

    if not(isempty(compartment_info)) && ~isempty(h_waitbar)
        if  mod(i_ind,bar_ind)==0
            zef_waitbar(i,length_I,h_waitbar,['Compartment ' int2str(compartment_info(1)) ' of ' int2str(compartment_info(2)) '. Ready: ' datestr(datevec(now+(length_I/i - 1)*time_val/86400)) '.']);
        end
    end

end

if not(isempty(compartment_info)) && ~isempty(h_waitbar)
    zef_waitbar(1,1,h_waitbar,['Compartment ' int2str(compartment_info(1)) ' of ' int2str(compartment_info(2)) '. Ready: ' datestr(datevec(now)) '.']);
end

ind_vec(I) = gather(ind_vec_aux);
I = find(ind_vec > meshing_threshold);

end
