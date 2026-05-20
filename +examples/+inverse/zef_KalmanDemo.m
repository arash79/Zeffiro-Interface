% --- Zeffiro documentation header ---
% examples.inverse.zef = zef_KalmanDemo_create_measurement(); — Example or study script demonstrating zef = zef_KalmanDemo_create_measurement();.
%
% Purpose:
%   Example or study script demonstrating zef = zef_KalmanDemo_create_measurement();.
%   Folder: Runnable examples and study scripts that exercise meshing, forward lead fields, inverse solvers, importing, and published workflows.
%
% Zef fields (observed):
%   zef.h_zeffiro (read)
%   zef.use_display (read, write)
%
% Calls (project):
%   zef_KF
%   zef_KalmanDemo_create_measurement
%   zef_KalmanDemo_runKalman
%   zef_KalmanDemo_save
%   zef_KalmanDemo_visualize
%   zef_Kalman_visualization
%   zef_close_all
%   zef_processLeadfields
%   zef_save
%   zef_visualize_surfaces
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `examples.inverse.zef = zef_KalmanDemo_create_measurement();` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef = zef_KalmanDemo_create_measurement();
%%
zef = zef_KalmanDemo_runKalman(zef);
%%
%zef = zef_KalmanDemo_save(zef);
%% Visualization
%(!!!) Under maintenance (!!!)
%zef = zef_Kalman_visualization(project_struct);
%%

function project_struct = zef_KalmanDemo_runKalman(project_struct)
    % zef_KalmanDemo_runKalman - Configure and execute Kalman filter reconstruction.
    %
    % Configures the Kalman filter settings and runs the inverse reconstruction
    % on the measurement data stored in project_struct.
    %
    % Kalman filter settings:
    project_struct.inv_snr = 25;
    project_struct.inv_sampling_frequency = 2500;
    project_struct.inv_low_cut_frequency = 0;
    project_struct.inv_high_cut_frequency = 0;
    project_struct.number_of_frames = 26;
    project_struct.inv_time_1 = 0;
    project_struct.inv_time_2 = 0;
    project_struct.inv_time_3 = 0.0004;
    project_struct.normalize_data = 1;
    project_struct.inv_evolution_prior = -34;
    % Filter type: 1 = Kalman, 2 = EnKF, 3 = Kalman SL, 4 = Kalman spatial SL
    project_struct.filter_type = 1;
    % Smoothing: 1 = none, 2 = Rauch-Tung-Striebel (RTS) smoother
    project_struct.kf_smoothing = 1;

    % Execute the inverse reconstruction.
    [project_struct] = zef_KF(project_struct);

end % function

function project_struct = zef_KalmanDemo_save(project_struct)
    % zef_KalmanDemo_save - Save project struct and close Zeffiro windows.
    zef_save(project_struct, 'example_project.mat', 'data/');
    zef_close_all(project_struct);
end

function project_struct = zef_KalmanDemo_create_measurement()
    % zef_KalmanDemo_create_measurement - Create synthetic P20/N20 EEG measurements.
    %
    % Generates a mesh and lead field, then simulates the somatosensory P20/N20
    % component with two dipolar sources: one cortical (peak at ~6 ms) and one
    % thalamic (peak at ~4 ms), separated by 2 ms to model neural propagation.

    % Create mesh and lead field based on the default segmentation.
    project_struct = examples.forward.lead_field_example ( ...
        'mesh_resolution' , 4.5 , ...
        'n_sources' , 2000 , ...
        'source_direction_mode' , 1 , ... Cartesian sources
        'mesh_smoothing_on' , true , ...
        'refinement_on' , true , ...
        'refinement_surface_on' , true , ...
        'lead_field_type' , 1 ... EEG
    ) ;

    % Define source parameters for P20/N20 simulation.
    noise_dB = 25;  % Measurement noise level (dB, higher = less noise)
    sampling_frequency = 2500;  % Sampling frequency (Hz) for synthetic data

    % Cortical source (P20 component):
    pos(1,:) = [-33,-37,80];  % Position (mm) in MNI or head coordinates
    ori(1,:) = [0.2,1,0];     % Orientation vector
    amp(1) = 10;              % Amplitude (nAm)

    % Thalamic source (N20 component):
    pos(2,:) = [-12,-32,50];  % Position (mm)
    ori(2,:) = [0.2,0.196,-0.98058];  % Orientation vector
    amp(2) = 10;              % Amplitude (nAm)

    ori = ori ./ sqrt(sum(ori.^2, 2));  % Normalize orientations to unit vectors

    % Time course: Blackman-Harris window models Gaussian-like pulse.
    t = 0:(1/sampling_frequency):0.01;   % Time vector (seconds)
    sz = find(t > 0.008, 1);             % Pulse width (8 ms)
    time_series = [zeros(1, length(t)-sz), blackmanharris(sz)'];
    % Cortical source (1) peaks at ~6 ms; thalamic source (2) at ~4 ms;
    % 2 ms delay models thalamo-cortical propagation.
    time_series(2,:) = flip(time_series);
    noise = randn(size(project_struct.L, 1), length(t));  % Gaussian measurement noise
    % Find source indices for Cartesian (non-normal) lead field within brain,
    % excluding outer compartments (skin, skull, etc.).
    project_struct.source_direction_mode = 2;
    [~,n_interp,procFile] = zef_processLeadfields(project_struct);
    project_struct.source_direction_mode = 1;

    mesh_points = project_struct.source_positions(procFile.s_ind_0, :);  % Brain source points
    source_ind = nan(2, 1);
    % Find nearest mesh nodes to target positions by Euclidean distance.
    for i = 1:2
        [~,source_ind(i)] = min(sum((mesh_points-pos(i,:)).^2,2));
    end
    source_ind = [source_ind; source_ind+n_interp; source_ind+2*n_interp];  % 3D lead field indices
    L = 1e-6 * project_struct.L(:, procFile.s_ind_1(source_ind));  % Lead field (µV/nAm)

    project_struct.measurements = (L .* ori(:)') * repmat((amp' .* time_series), 3, 1);  % Noiseless signal
    % Add noise according to specified SNR.
    project_struct.measurements = project_struct.measurements + (10^(-noise_dB/20)*sqrt(sum(project_struct.measurements.^2,2)./sum(noise.^2,2))).*noise;

end % function

function project_struct = zef_KalmanDemo_visualize(project_struct)
    % zef_KalmanDemo_visualize - Display reconstruction in Zeffiro GUI.
    zef.h_zeffiro.Visible = 1;
    zef.use_display = 1;
    project_struct.visualization_type = 3;
    zef_visualize_surfaces(project_struct)
end

function project_struct = zef_Kalman_visualization(project_struct)
    % zef_Kalman_visualization - Open figure tool and visualize surfaces.
    zef_figure_tool
    project_struct.h_zeffiro.Visible = 1;
    project_struct.use_display = 1;
    project_struct.visualization_type = 3;
    project_struct.cp2_on = 0;
    project_struct.cp_on = 0;
    project_struct.cp3_on = 0;
    zef_visualize_surfaces
end
