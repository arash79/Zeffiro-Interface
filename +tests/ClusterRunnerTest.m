classdef ClusterRunnerTest < matlab.unittest.TestCase

    methods (Test)
        function testRunInverseJobWritesResultFile(testCase)
            zef = tests.createSyntheticInverseZef();
            bundle = zef_inverse_extract_bundle(zef, "dspm");

            tmp_dir = fullfile(tempdir, "zi_cluster_runner_test");
            if ~isfolder(tmp_dir)
                mkdir(tmp_dir);
            end
            bundle_path = fullfile(tmp_dir, "bundle.mat");
            result_path = fullfile(tmp_dir, "result.mat");
            save(bundle_path, "bundle");

            result = utilities.cluster.run_inverse_job(bundle_path, result_path);

            testCase.verifyTrue(result.success);
            testCase.verifyTrue(isfile(result_path));
        end
    end

end
