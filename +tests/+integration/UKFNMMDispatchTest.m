classdef UKFNMMDispatchTest < matlab.unittest.TestCase
%UKFNMMDISPATCHTEST  Registry, local dispatch, and cluster-job serialization for UKFNMM.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Synthetic session via tests.support.createSyntheticUKFNMMZef. Asserts registry
%   ids ukfnmm / ukf_nmm, dispatch_inverse, zef_inverse_run, and
%   run_inverse_job reconstruction plus NMM execution exactly once.

    methods (TestMethodSetup)
        function seedRngAndCloseWaitbars(~)
            rng(1, "twister");
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
        function testRegistryResolvesUkfnmm(testCase)
            method_info = utilities.cluster.inverse_method_registry("ukfnmm");
            testCase.verifyEqual(method_info.execution_kind, "class");
            testCase.verifyEqual(method_info.class_name, "inverse.UKFNMMInverter");
        end

        function testRegistryAliasUkfNmm(testCase)
            method_info = utilities.cluster.inverse_method_registry("ukf_nmm");
            testCase.verifyEqual(method_info.execution_kind, "class");
            testCase.verifyEqual(method_info.class_name, "inverse.UKFNMMInverter");
        end

        function testRegistryConstruction(testCase)
            method_info = utilities.cluster.inverse_method_registry("ukfnmm");
            obj = feval(method_info.class_name);
            testCase.verifyClass(obj, 'inverse.UKFNMMInverter');
            inverse.CommonInverseParameters.isAnInverter(obj);
        end

        function testDispatchInverseUkfnmm(testCase)
            testCase.assumeTrue(exist('kmeans', 'file') == 2, "kmeans required");
            zef = tests.support.createSyntheticUKFNMMZef();
            params = i_method_params();
            bundle = zef_inverse_extract_bundle(zef, "ukfnmm", "MethodParams", params);
            result = utilities.cluster.dispatch_inverse(bundle);

            testCase.verifyTrue(isfield(result, "reconstruction"));
            testCase.verifyTrue(isfield(result, "reconstruction_information"));
            testCase.verifyTrue(~isempty(result.reconstruction));
            testCase.verifyEqual(numel(result.z_inverse), zef.number_of_frames);
            testCase.verifyEqual(size(result.z_inverse{1}, 1), size(bundle.L, 2));
            testCase.verifyEqual(string(result.reconstruction_information.tag), "UKFNMM");
            testCase.verifyEqual(result.reconstruction_information.n_temporal_postprocess_runs, 1);
        end

        function testZefInverseRunLocal(testCase)
            testCase.assumeTrue(exist('kmeans', 'file') == 2, "kmeans required");
            zef = tests.support.createSyntheticUKFNMMZef();
            [zef_out, run_result] = zef_inverse_run( ...
                zef, "ukfnmm", ...
                "execution", "local", ...
                "MethodParams", i_method_params());

            testCase.verifyTrue(isfield(zef_out, "reconstruction"));
            testCase.verifyTrue(~isempty(zef_out.reconstruction));
            testCase.verifyTrue(~isempty(run_result.reconstruction));
            testCase.verifyEqual(numel(zef_out.reconstruction), zef.number_of_frames);
            testCase.verifyEqual(zef_out.reconstruction_information.n_temporal_postprocess_runs, 1);
        end

        function testLocalDispatchDoesNotBreakKalmanRegistry(testCase)
            zef = tests.support.createSyntheticInverseZef();
            bundle = zef_inverse_extract_bundle(zef, "kalman");
            testCase.verifyEqual(bundle.method_info.class_name, "inverse.KalmanInverter");
        end

        function testClusterJobSerialization(testCase)
            testCase.assumeTrue(exist('kmeans', 'file') == 2, "kmeans required");
            zef = tests.support.createSyntheticUKFNMMZef();
            bundle = zef_inverse_extract_bundle(zef, "ukfnmm", "MethodParams", i_method_params());

            tmp_dir = fullfile(tempdir, "zi_ukfnmm_cluster_test");
            if ~isfolder(tmp_dir)
                mkdir(tmp_dir);
            end
            bundle_path = fullfile(tmp_dir, "bundle.mat");
            result_path = fullfile(tmp_dir, "result.mat");
            save(bundle_path, "bundle");

            result = utilities.cluster.run_inverse_job(bundle_path, result_path);

            testCase.verifyTrue(result.success);
            testCase.verifyTrue(isfile(result_path));
            testCase.verifyTrue(~isempty(result.reconstruction));
            testCase.verifyEqual(numel(result.z_inverse), zef.number_of_frames);
        end
    end
end

function params = i_method_params()
params = struct( ...
    "number_of_corrclusters", 1, ...
    "score_threshold", 0.05, ...
    "smoother_type", "None", ...
    "evolution_prior_model", "Reworked original", ...
    "number_of_noise_steps", 2);
end
