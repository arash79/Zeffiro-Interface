classdef IASFamilyLastStepTest < matlab.unittest.TestCase
%IASFAMILYLASTSTEPTEST  sLORETA/dSPM last-step weighting actually runs.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Guards the n_map_iterations last-step branches on inverse.IASInverter
%   and inverse.RAMUSInverter, and the plugin ias_type==3 branch.

    methods (TestMethodSetup)
        function seedRngAndCloseWaitbars(~)
            rng(4, "twister");
            try
                zef_delete_waitbar;
            catch
            end
        end
    end

    methods (TestMethodTeardown)
        function closeWaitbars(~)
            try
                zef_delete_waitbar;
            catch
            end
        end
    end

    methods (Test)
        function testIASLastStepSLoretaDiffersFromNone(testCase)
            [L, f, procFile, source_positions] = i_synth();
            z_none = i_ias_invert(L, f, procFile, source_positions, "None");
            z_last = i_ias_invert(L, f, procFile, source_positions, "sLORETA last step");
            testCase.verifySize(z_last, size(z_none));
            testCase.verifyTrue(all(isfinite(z_last)));
            testCase.verifyNotEqual(z_last, z_none);
        end

        function testIASLastStepDSPMDiffersFromNone(testCase)
            [L, f, procFile, source_positions] = i_synth();
            z_none = i_ias_invert(L, f, procFile, source_positions, "None");
            z_last = i_ias_invert(L, f, procFile, source_positions, "dSPM last step");
            testCase.verifyTrue(all(isfinite(z_last)));
            testCase.verifyNotEqual(z_last, z_none);
        end

        function testRAMUSLastStepSLoretaDiffersFromNone(testCase)
            [L, f, procFile, source_positions] = i_synth();
            n_src = size(source_positions, 1);
            z_none = i_ramus_invert(L, f, procFile, source_positions, n_src, "None");
            z_last = i_ramus_invert(L, f, procFile, source_positions, n_src, "sLORETA last step");
            testCase.verifyTrue(all(isfinite(z_last)));
            testCase.verifyNotEqual(z_last, z_none);
        end

        function testPluginIASTypeThreeIsLastStep(testCase)
            src = fileread(fullfile("tools", "plugins", "IASInversion", "m", "zef_ias_iteration.m"));
            testCase.verifyTrue(contains(src, "isequal(ias_type,3)"));
            testCase.verifyFalse(contains(src, "elseif isequal(ias_type,2)"));
        end

        function testLastStepDoesNotReferenceTypoProperty(testCase)
            ias_src = fileread(fullfile("+inverse", "@IASInverter", "invert.m"));
            ramus_src = fileread(fullfile("+inverse", "@RAMUSInverter", "invert.m"));
            testCase.verifyFalse(contains(ias_src, "n_n_map_iterations"));
            testCase.verifyFalse(contains(ramus_src, "n_n_map_iterations"));
        end
    end
end

function [L, f, procFile, source_positions] = i_synth()
n_src = 4;
n_sens = 8;
L = randn(n_sens, 3*n_src);
f = randn(n_sens, 1);
source_positions = [zeros(n_src, 1), (0:n_src-1)', zeros(n_src, 1)];
procFile = struct();
end

function z_vec = i_ias_invert(L, f, procFile, source_positions, method_type)
inverter = inverse.IASInverter( ...
    "number_of_frames", 2, ...
    "n_map_iterations", 3, ...
    "method_type", method_type, ...
    "signal_to_noise_ratio", 20);
inverter = inverter.initialize(L, f);
[z_vec, ~] = inverter.invert( ...
    f, L, procFile, 1, source_positions, ...
    "use_gpu", false, "normalize_data", 1);
end

function z_vec = i_ramus_invert(L, f, procFile, source_positions, n_src, method_type)
inverter = inverse.RAMUSInverter( ...
    "number_of_frames", 2, ...
    "n_map_iterations", 3, ...
    "method_type", method_type, ...
    "number_of_decompositions", 1, ...
    "number_of_multiresolution_levels", 1, ...
    "sparsity_factor", 1, ...
    "multiresolution_dec", {{(1:n_src)}}, ...
    "multiresolution_ind", {{(1:n_src)}}, ...
    "signal_to_noise_ratio", 20);
inverter = inverter.initialize(L, f);
[z_vec, ~] = inverter.invert( ...
    f, L, procFile, 1, source_positions, ...
    "use_gpu", false, "normalize_data", 1);
end
