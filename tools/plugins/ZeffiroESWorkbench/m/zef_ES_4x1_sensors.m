function ell_idx = zef_ES_4x1_sensors(varargin)
% --- Zeffiro documentation header ---
% zef_ES_4x1_sensors — Zef ES 4x1 sensors.
%
% Purpose:
%   Zef ES 4x1 sensors.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   varargin
%
% Outputs:
%   ell_idx
%
% Zef fields (observed):
%   zef.ES_separation_angle (read)
%   zef.inv_synth_source (read)
%   zef.sensors (read)
%
% Calls (project):
%   zef_ES_4x1_sensors
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[ell_idx] = zef_ES_4x1_sensors(varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header

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
