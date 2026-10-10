classdef ProjectSensorRestoreTest < matlab.unittest.TestCase
%PROJECTSENSORRESTORETEST  Loaded electrode sets stay current and aligned.

    methods (Test)
        function freshLegacyTagBecomesCurrent(testCase)
            zef = i_session();
            zef = zef_create_sensors(zef, 's');
            testCase.verifyEqual(zef.current_sensors, 's');
        end

        function ensuringEmptySetDoesNotRetargetElectrodes(testCase)
            zef = i_session();
            zef.sensor_tags = {'s2', 's'};
            zef.current_sensors = 's2';
            zef.s2_points = zeros(200, 3);
            zef.s2_name = 'Electrodes';
            zef = zef_create_sensors(zef, 's2');
            zef = zef_create_sensors(zef, 's');
            testCase.verifyEqual(zef.current_sensors, 's2');
            testCase.verifyEqual(zef.s2_name, 'Electrodes');
            testCase.verifyEqual(size(zef.s2_points, 1), 200);
            testCase.verifyEqual(size(zef.s_points, 1), 0);
        end

        function canonicalizeAlignsAppendedElectrodeProperties(testCase)
            zef = i_session();
            zef.sensor_tags = {'s2', 's'};
            zef.current_sensors = 's2';
            zef.sensors_canonical = true;
            zef.s2_points = zeros(200, 3);
            zef.s2_name = 'Electrodes';
            zef.s2_visible = 1;
            zef.s2_visible_list = ones(200, 1);
            zef.s2_imaging_method_name = 'EEG';
            zef.s2_electrode_impedance = [2000; 1000 * ones(128, 1)];
            zef.s2_electrode_inner_radius = [2; zeros(128, 1)];
            zef.s2_electrode_outer_radius = [5; zeros(128, 1)];
            zef = zef_canonicalize_sensors(zef);

            testCase.verifyEqual(char(string(zef.current_sensors)), 's2');
            testCase.verifyEqual(numel(zef.s2_electrode_impedance), 200);
            testCase.verifyEqual(zef.s2_electrode_impedance(1:72), 2000 * ones(72, 1));
            testCase.verifyEqual(zef.s2_electrode_impedance(73:200), 1000 * ones(128, 1));
            testCase.verifyEqual(zef.s2_electrode_outer_radius(1:72), 5 * ones(72, 1));
            testCase.verifyEqual(zef.s2_electrode_outer_radius(73:200), zeros(128, 1));
            testCase.verifyEqual(zef.s2_electrode_inner_radius(72), 2);
            testCase.verifyEqual(zef.s2_electrode_inner_radius(73), 0);
            testCase.verifyEqual(zef.s_electrode_impedance, 2000);

            out = zef_cem_electrode(zef, zef.s2_points);
            testCase.verifySize(out, [200 6]);
            testCase.verifyEqual(out(1, 4), 5);
            testCase.verifyEqual(out(73, 4), 0);
            testCase.verifyEqual(out(1, 6), 2000);
            testCase.verifyEqual(out(200, 6), 1000);
        end

        function scalarPropertyStaysScalarAndCemReplicatesIt(testCase)
            zef = i_session();
            zef.sensor_tags = {'s'};
            zef.current_sensors = 's';
            zef.sensors_canonical = true;
            zef.s_points = zeros(4, 3);
            zef.s_electrode_impedance = 2000;
            zef.s_electrode_inner_radius = 2;
            zef.s_electrode_outer_radius = 5;
            zef.s_visible = 1;
            zef.s_visible_list = ones(4, 1);
            zef.s_imaging_method_name = 'EEG';
            zef = zef_canonicalize_sensors(zef);
            testCase.verifyEqual(zef.s_electrode_impedance, 2000);
            out = zef_cem_electrode(zef, zef.s_points);
            testCase.verifyEqual(out(:, 6), 2000 * ones(4, 1));
            testCase.verifyEqual(out(:, 4), 5 * ones(4, 1));
        end
    end
end

function zef = i_session()
zef = struct();
zef.sensor_tags = {};
zef.imaging_method_cell = {'EEG', 'MEG magnetometer', 'MEG gradiometers'};
zef.imaging_method = 1;
end
