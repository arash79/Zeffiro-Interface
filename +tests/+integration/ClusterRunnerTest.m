classdef ClusterRunnerTest < matlab.unittest.TestCase
%CLUSTERRUNNERTEST  utilities.cluster.run_inverse_job writes a result.mat for dspm.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Synthetic bundle, temp directory. Asserts result.success after
%   run_inverse_job. Does not require a CSC cluster profile.
%

    methods (Test)
        function testRunInverseJobWritesResultFile(testCase)
            zef = tests.support.createSyntheticInverseZef();
            bundle = zef_inverse_extract_bundle(zef, "dspm");

            tmp_dir = fullfile(tempdir, "zi_cluster_runner_test");
            if ~isfolder(tmp_dir)
                mkdir(tmp_dir);
            end
            testCase.addTeardown(@() local_rmdir(tmp_dir));
            bundle_path = fullfile(tmp_dir, "bundle.mat");
            result_path = fullfile(tmp_dir, "result.mat");
            save(bundle_path, "bundle");

            result = utilities.cluster.run_inverse_job(bundle_path, result_path);

            testCase.verifyTrue(result.success);
            testCase.verifyTrue(isfile(result_path));
        end
    end

end

function local_rmdir(tmp_dir)
if isfolder(tmp_dir)
    rmdir(tmp_dir, "s");
end
end
