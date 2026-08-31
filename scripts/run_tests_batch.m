%RUN_TESTS_BATCH  Headless package test run from the repository root.
%
%   Invoked by: matlab -batch "run('scripts/run_tests_batch.m')"
%   Not on the default MATLAB path; this file is a maintainer helper.

root = fileparts(fileparts(mfilename('fullpath')));
cd(root);
zef = zeffiro_interface( ...
    'start_mode', 'nodisplay', ...
    'use_gpu', false, ...
    'skip_submodules', true);
% Close nodisplay figures without rmpath. zef_close_all otherwise
% removes the tree from the MATLAB path and every later test fails.
try
    zef.zeffiro_restart = 1;
    zef_close_all(zef);
catch
end

import matlab.unittest.TestSuite
suite = TestSuite.fromPackage('tests', 'IncludingSubpackages', true);
runner = matlab.unittest.TestRunner.withTextOutput;
result = runner.run(suite);

n_fail = nnz([result.Failed]);
n_pass = nnz([result.Passed]);
n_inc = nnz([result.Incomplete]);
fprintf('\nSummary: %d passed, %d failed, %d incomplete / skipped\n', ...
    n_pass, n_fail, n_inc);

if n_fail > 0
    for k = 1:numel(result)
        if result(k).Failed
            fprintf('FAILED: %s\n', result(k).Name);
        end
    end
    error('run_tests_batch:Failed', '%d test(s) failed', n_fail);
end
