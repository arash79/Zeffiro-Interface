function s_points = zef_cem_electrode(zef,s_points)

if isempty(s_points)
    s_points = [];
else
    current_sensors = eval('zef.current_sensors');
    
    % Get the number of sensor points
    n_sensors = size(s_points, 1);
    
    % Get electrode properties
    outer_radius = eval(['zef.' current_sensors '_electrode_outer_radius(:)']);
    inner_radius = eval(['zef.' current_sensors '_electrode_inner_radius(:)']);
    impedance = eval(['zef.' current_sensors '_electrode_impedance(:)']);
    
    % Expand scalar properties to match the number of sensors
    if isscalar(outer_radius)
        outer_radius = repmat(outer_radius, n_sensors, 1);
    end
    if isscalar(inner_radius)
        inner_radius = repmat(inner_radius, n_sensors, 1);
    end
    if isscalar(impedance)
        impedance = repmat(impedance, n_sensors, 1);
    end
    
    % Concatenate
    s_points = [s_points(:,1:3), outer_radius, inner_radius, impedance];
end
end
