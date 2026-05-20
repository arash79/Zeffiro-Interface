classdef ELORETAInverterTest < matlab.unittest.TestCase
% --- Zeffiro documentation header ---
% tests.ELORETAInverterTest — Inverse solver class implementing ELORETATest reconstruction.
%
% Purpose:
%   Inverse solver class implementing ELORETATest reconstruction.
%   Folder: MATLAB unit and integration tests for refactored inverse dispatch, lead fields, cluster jobs, and legacy/class parity.
%
% Inputs:
%   Constructor and method arguments are declared in classdef methods below.
%
% Zef fields (observed):
%   zef.inv_snr (read)
%   zef.measurements (read)
%   zef.normalize_data (read)
%   zef.source_direction_mode (read)
%   zef.source_positions (read)
%
% Calls (project):
%   inverse.ELORETAInverter
%   zef_processLeadfields
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `tests.ELORETAInverterTest(...)` after `addpath(projectRoot)`; methods: initialize / precompute / invert where defined.
% --- End Zeffiro documentation header


    methods (Test)
        function testOutputShapeMatchesLeadField(testCase)
            zef = tests.createSyntheticInverseZef();
            [L, n_interp, procFile] = zef_processLeadfields(zef);
            L = i_reorder_if_needed(L, zef.source_direction_mode, n_interp);

            inverter = inverse.ELORETAInverter( ...
                "number_of_frames", 1, ...
                "signal_to_noise_ratio", zef.inv_snr ...
            );
            inverter = inverter.initialize(L, zef.measurements);

            [z_vec, inverter] = inverter.invert( ...
                zef.measurements(:,1), ...
                L, ...
                procFile, ...
                zef.source_direction_mode, ...
                zef.source_positions(procFile.s_ind_0,:), ...
                "use_gpu", false, ...
                "normalize_data", zef.normalize_data ...
            );

            testCase.verifySize(z_vec, [size(L,2), 1]);
        end

        function testFixedPointConverges(testCase)
            zef = tests.createSyntheticInverseZef();
            [L, n_interp, procFile] = zef_processLeadfields(zef);
            L = i_reorder_if_needed(L, zef.source_direction_mode, n_interp);

            inverter = inverse.ELORETAInverter( ...
                "number_of_frames", 1, ...
                "n_max_iterations", 50, ...
                "convergence_tolerance", 1e-5 ...
            );
            inverter = inverter.initialize(L, zef.measurements);
            inverter = inverter.precompute(L, procFile);

            testCase.verifyGreaterThan(inverter.n_iterations_used, 0);
            testCase.verifyLessThanOrEqual(inverter.n_iterations_used, inverter.n_max_iterations);
            testCase.verifyLessThan(inverter.final_residual, 1e-3);
        end

        function testZeroLocalizationErrorPointSource(testCase)
            [L, procFile, source_positions] = i_make_block_leadfield();
            true_source = 3;
            z_true = zeros(size(L,2),1);
            z_true(3*true_source - 2) = 1;
            f = L * z_true;

            inverter = inverse.ELORETAInverter("number_of_frames", 1);
            inverter = inverter.initialize(L, f);
            [z_vec, inverter] = inverter.invert( ...
                f, L, procFile, 1, source_positions, ...
                "use_gpu", false, "normalize_data", 1 ...
            );

            source_power = sum(reshape(z_vec.^2,3,[]),1);
            [~, peak_source] = max(source_power);
            testCase.verifyEqual(peak_source, true_source);
        end

        function testManualRegularizationOverridesSNR(testCase)
            L = randn(10, 12);
            f_data = randn(10, 5);
            alpha_manual = 0.1234;

            inverter = inverse.ELORETAInverter( ...
                "regularization_parameter", alpha_manual, ...
                "signal_to_noise_ratio", 5 ...
            );
            inverter = inverter.initialize(L, f_data);

            testCase.verifyEqual(inverter.regularization_parameter, alpha_manual, "AbsTol", 1e-12);
        end

        function testReconstructionStableUnderRescaling(testCase)
            [L, procFile, source_positions] = i_make_block_leadfield();
            true_source = 2;
            z_true = zeros(size(L,2),1);
            z_true(3*true_source - 1) = 1;
            f = L * z_true;

            inv_a = inverse.ELORETAInverter("number_of_frames", 1);
            inv_a = inv_a.initialize(L, f);
            [z_a, inv_a] = inv_a.invert( ...
                f, L, procFile, 1, source_positions, ...
                "use_gpu", false, "normalize_data", 1 ...
            );

            scale = 10;
            L_scaled = scale * L;
            f_scaled = scale * f;
            inv_b = inverse.ELORETAInverter("number_of_frames", 1);
            inv_b = inv_b.initialize(L_scaled, f_scaled);
            [z_b, inv_b] = inv_b.invert( ...
                f_scaled, L_scaled, procFile, 1, source_positions, ...
                "use_gpu", false, "normalize_data", 1 ...
            );

            pow_a = sum(reshape(z_a.^2,3,[]),1);
            pow_b = sum(reshape(z_b.^2,3,[]),1);
            [~, src_a] = max(pow_a);
            [~, src_b] = max(pow_b);
            testCase.verifyEqual(src_a, src_b);
        end
    end

end

function L = i_reorder_if_needed(L, source_direction_mode, n_interp)
if source_direction_mode == 1 || source_direction_mode == 2
    s_reorder_ind = reshape((1:n_interp) + (0:n_interp:(2*n_interp))', [], 1);
    L = L(:, s_reorder_ind);
end
end

function [L, procFile, source_positions] = i_make_block_leadfield()
n_sources = 4;
n_sensors = 3*n_sources;
L = eye(n_sensors);
source_positions = zeros(n_sources, 3);
procFile = struct( ...
    "source_direction_mode", 1, ...
    "source_directions", zeros(n_sources,3), ...
    "s_ind_1", [], ...
    "s_ind_2", [], ...
    "s_ind_3", [], ...
    "s_ind_4", [], ...
    "n_interp", n_sources, ...
    "sizeL2", size(L,2), ...
    "s_ind_0", 1:n_sources ...
);
end
