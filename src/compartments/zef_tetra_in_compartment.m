function [I] = zef_tetra_in_compartment(reuna_p,reuna_t,nodes,varargin)
%ZEF_TETRA_IN_COMPARTMENT  Test which nodes lie inside a closed surface (tetra meshing).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Same solid-angle inclusion test as zef_point_in_compartment but reads
%   meshing settings from the base zef workspace and returns only node
%   indices I (no distance vector). Supports optional compartment_info and
%   meshing_threshold in varargin.
%
%   I = zef_tetra_in_compartment(reuna_p, reuna_t, nodes)
%   I = zef_tetra_in_compartment(reuna_p, reuna_t, nodes, compartment_info)
%   I = zef_tetra_in_compartment(reuna_p, reuna_t, nodes, compartment_info, meshing_threshold)
%
%   Inputs
%     reuna_p, reuna_t - surface mesh vertices and triangles.
%     nodes            - coordinates to classify.
%
%   Output
%     I - indices of nodes classified as inside the surface.
%
%   See also zef_point_in_compartment.

if evalin('base','exist(''zef'')')
    if evalin('base','isfield(zef,''meshing_threshold'')')
        meshing_threshold = evalin('base','zef.meshing_threshold');
    else
        meshing_threshold = 0.5;
    end
else
    meshing_threshold = 0.5;
end

compartment_info = [];
if not(isempty(varargin))
    compartment_info = varargin{1};
    if length(varargin) > 1
        meshing_threshold = varargin{2};
    end
end

max_x = max(reuna_p(:,1));
min_x = min(reuna_p(:,1));
max_y = max(reuna_p(:,2));
min_y = min(reuna_p(:,2));
max_z = max(reuna_p(:,3));
min_z = min(reuna_p(:,3));
max_norm = max(sqrt(sum(reuna_p.^2,2)));
nodes_norm_vec = sqrt(sum(nodes.^2,2));

meshing_accuracy = evalin('base','zef.meshing_accuracy');

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

use_gpu  = evalin('base','zef.use_gpu');
gpu_num  = evalin('base','zef.gpu_num');

if use_gpu == 1 & evalin('base','zef.gpu_count') > 0
    nodes_aux = gpuArray(nodes_aux);
    aux_vec_1 = gpuArray(aux_vec_1);
    aux_vec_4 = gpuArray(aux_vec_4);
    ind_vec_aux = gpuArray(ind_vec_aux);
end

par_num = evalin('base','zef.parallel_vectors');
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

    if not(isempty(compartment_info))
        if  mod(i_ind,bar_ind)==0
            zef_waitbar(i,length_I,evalin('caller','h'),['Compartment ' int2str(compartment_info(1)) ' of ' int2str(compartment_info(2)) '. Ready: ' datestr(datevec(now+(length_I/i - 1)*time_val/86400)) '.']);
        end
    end

end

if not(isempty(compartment_info))
    zef_waitbar(1,1,evalin('caller','h'),['Compartment ' int2str(compartment_info(1)) ' of ' int2str(compartment_info(2)) '. Ready: ' datestr(datevec(now)) '.']);
end

ind_vec(I) = gather(ind_vec_aux);
I = find(ind_vec > evalin('base','zef.meshing_threshold'));

end
