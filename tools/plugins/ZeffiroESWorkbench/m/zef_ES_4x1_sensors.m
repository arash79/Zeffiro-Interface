function ell_idx = zef_ES_4x1_sensors(varargin)
%ZEF_ES_4X1_SENSORS  Five sensor indices for a 4×1 montage around inv_synth_source.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Not bound in zef_ES_optimization_window. Anode = nearest sensor to
%   inv_synth_source; four returns at ±separation_angle along the source
%   orientation and the cross product with the anode radial. Optional first
%   argument is the angle in degrees; else zef.ES_separation_angle.
%   Further varargin entries are ignored — sensors and inv_synth_source
%   always come from the base workspace (zef_ES_4x1_fun still passes them).
%
%   ell_idx = zef_ES_4x1_sensors()
%   ell_idx = zef_ES_4x1_sensors(separation_angle)
%
%   See also zef_ES_plot_4x1, zef_ES_find_valid_separation_angle.
%

if length(varargin) >= 1
    separation_angle = varargin{1};
else
    separation_angle = evalin('base','zef.ES_separation_angle');
end

sensor_coord = evalin('base','zef.sensors(:,1:3)');
source_pos   = evalin('base','zef.inv_synth_source(1,1:3)');
source_ori   = evalin('base','zef.inv_synth_source(1,4:6)');

ell_idx    = zeros(5,1);
source_pos = source_pos(:)';
source_ori = source_ori(:)';

% Anode: nearest sensor to the synthetic source.
d_norm = sqrt(sum((source_pos - sensor_coord).^2,2));
[~,m_ind] = min(d_norm);

p_1 = sensor_coord((m_ind),:);
    ell_idx(1) = m_ind;

    v_1 = p_1;
    p_1_norm = sqrt(sum(p_1.^2,2));

    v_1 = v_1./p_1_norm;
    v_2 = source_ori./sqrt(sum(source_ori.^2,2));
    v_3 = cross(v_1',v_2')';

    source_index = [1:size(sensor_coord,1)]; %#ok<NBRAK>

    source_index = setdiff(source_index, source_index(m_ind));
    sensor_coord_aux = sensor_coord;
    sensor_coord = sensor_coord_aux(source_index,:);

% Returns ±separation_angle along source orientation (v_2) then along v_3 = v_1 × v_2.
p_2 = p_1 + p_1_norm*tan(pi*separation_angle/180)*v_2;
    d_norm = sqrt(sum((p_2 - sensor_coord).^2,2));
    [~,m_ind] = min(d_norm);
    ell_idx(2) = source_index(m_ind);

    %sensor_coord_aux = sensor_coord;
    source_index = setdiff(source_index, source_index(m_ind));
    sensor_coord = sensor_coord_aux(source_index,:);

p_3 = p_1 + p_1_norm*tan(-pi*separation_angle/180)*v_2;
    d_norm = sqrt(sum((p_3 - sensor_coord).^2,2));
    [~,m_ind] = min(d_norm);
    ell_idx(3) = source_index(m_ind);

    %sensor_coord_aux = sensor_coord;
    source_index = setdiff(source_index, source_index(m_ind));
    sensor_coord = sensor_coord_aux(source_index,:);

p_4 = p_1 + p_1_norm*tan(pi*separation_angle/180)*v_3;
    d_norm = sqrt(sum((p_4 - sensor_coord).^2,2));
    [~,m_ind] = min(d_norm);
    ell_idx(4) = source_index(m_ind);

    %sensor_coord_aux = sensor_coord;
    source_index = setdiff(source_index, source_index(m_ind));
    sensor_coord = sensor_coord_aux(source_index,:);

p_5 = p_1 + p_1_norm*tan(-pi*separation_angle/180)*v_3;
    d_norm = sqrt(sum((p_5 - sensor_coord).^2,2));
    [~,m_ind] = min(d_norm);
    ell_idx(5) = source_index(m_ind);
end
