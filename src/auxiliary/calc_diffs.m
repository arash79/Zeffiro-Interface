%CALC_DIFFS  Lab one-off: MAG/RDM of one pallomalli_pem.mat vs ary_model.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script, not a product workflow. Not on any Zeffiro menu. cwd-relative
%   load data/ary_model/ary_model.mat then zeffiro_projects/pallomalli_pem.mat
%   (expects zef_data in that file). Those paths are not in this repo.
%   Extra numbered load blocks (%% 2–4) are commented; unlike
%   calculate_differences this file does not average-reference L.
%
%   Local mag_rdm_fn: analytic sphere L from
%   zef_lead_field_eeg_multilayer_sphere(sensors_attached_volume(:,1:3)/1000,
%   source_positions/1000, [], ary_model) vs zef_data.L. Nested mag_fn /
%   rdm_fn match src/auxiliary/mag_fn.m and rdm_fn.m. Leaves mag_v_1,
%   rdm_v_1, s_p_1, plus La/Lfem from the last local call.
%
%   See also calculate_differences, mag_fn, rdm_fn.

load data/ary_model/ary_model.mat;

%% 1

load zeffiro_projects/pallomalli_pem.mat;

[mag_v_1, rdm_v_1, La, Lfem] = mag_rdm_fn(ary_model, zef_data);
s_p_1 = zef_data.source_positions;

% %% 2
%
% load zeffiro_projects/pallomalli_pem.mat;
%
% [mag_v_2, rdm_v_2, La, Lfem] = mag_rdm_fn(ary_model, zef_data);
% s_p_2 = zef_data.source_positions;
%
% %% 3
%
% load zeffiro_projects/pallomalli_pem.mat;
%
% [mag_v_3, rdm_v_3, La, Lfem] = mag_rdm_fn(ary_model, zef_data);
% s_p_3 = zef_data.source_positions;
%
% %% 4
%
% load zeffiro_projects/pallomalli_pem.mat;
%
% [mag_v_4, rdm_v_4, La, Lfem] = mag_rdm_fn(ary_model, zef_data);
% s_p_4 = zef_data.source_positions;

%% Function definitions

function [mag, rdm, La, Lfem] = mag_rdm_fn(ary_model, zef_data)
La = zef_lead_field_eeg_multilayer_sphere( ...
    zef_data.sensors_attached_volume(:,1:3) / 1000, ...
    zef_data.source_positions / 1000, ...
    [], ...
    ary_model ...
    );

Lfem = zef_data.L;

rdm = rdm_fn(La, Lfem);

mag = mag_fn(La, Lfem);

end

function rdm = rdm_fn(La, Lfem)

scaled_Lfem = Lfem ./ repmat(sqrt(sum(Lfem.^2)), size(Lfem, 1), 1);
scaled_La = La ./ repmat(sqrt(sum(La.^2)), size(La, 1), 1);

diffs = scaled_Lfem - scaled_La;

rdm = sqrt(sum(diffs.^2))';

end

function mag = mag_fn(La, Lfem)
mag = 1 - sqrt(sum(Lfem.^2))' ./ sqrt(sum(La.^2))';
end
