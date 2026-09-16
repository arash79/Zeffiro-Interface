classdef EnsureParpoolTest < matlab.unittest.TestCase
%ENSUREPARPOOLTEST  CPU parfor callers size a pool only through zef_ensure_parpool.
%
%   cpuParallelCallersUseHelper and megEitMeshTransferDoNotCallGcpDirectly
%   are structural (source contracts). helperIsNoOpWithoutParallelToolbox
%   and helperLeavesMatchingPoolAlone call the helper.

    methods (Test)
        function cpuParallelCallersUseHelper(testCase)
            % Structural: these CPU parfor files must call the helper by name.
            root = fileparts(which("zeffiro_interface"));
            testCase.assumeNotEmpty(root, "zeffiro_interface is not on the MATLAB path");
            files = [ ...
                fullfile(root, "src", "app", "zef_ensure_parpool.m"); ...
                fullfile(root, "src", "mesh", "zef_create_fem_mesh.m"); ...
                fullfile(root, "src", "forward", "lead_field", "zef_transfer_matrix.m"); ...
                fullfile(root, "src", "forward", "lead_field", "zef_lead_field_meg_fem.m"); ...
                fullfile(root, "src", "forward", "lead_field", "zef_lead_field_meg_grad_fem.m"); ...
                fullfile(root, "src", "forward", "lead_field", "zef_lead_field_eit_fem.m"); ...
                fullfile(root, "src", "forward", "wave", "make_born_approximation_amp.m"); ...
                fullfile(root, "src", "forward", "wave", "make_born_approximation_qam.m")];
            for k = 1:numel(files)
                src = fileread(files(k));
                testCase.verifyTrue(contains(src, "zef_ensure_parpool"), files(k));
            end
        end

        function megEitMeshTransferDoNotCallGcpDirectly(testCase)
            root = fileparts(which("zeffiro_interface"));
            testCase.assumeNotEmpty(root, "zeffiro_interface is not on the MATLAB path");
            files = [ ...
                fullfile(root, "src", "mesh", "zef_create_fem_mesh.m"); ...
                fullfile(root, "src", "forward", "lead_field", "zef_transfer_matrix.m"); ...
                fullfile(root, "src", "forward", "lead_field", "zef_lead_field_meg_fem.m"); ...
                fullfile(root, "src", "forward", "lead_field", "zef_lead_field_meg_grad_fem.m"); ...
                fullfile(root, "src", "forward", "lead_field", "zef_lead_field_eit_fem.m")];
            for k = 1:numel(files)
                src = fileread(files(k));
                testCase.verifyEmpty(regexp(src, '(?<![A-Za-z_])gcp\(', 'once'), files(k));
                testCase.verifyEmpty(regexp(src, '(?<![A-Za-z_])parpool\(', 'once'), files(k));
            end
        end

        function helperIsNoOpWithoutParallelToolbox(testCase)
            started = zef_ensure_parpool(1);
            testCase.verifyClass(started, "logical");
            has_pct = exist("parpool", "file") == 2 ...
                && license("test", "Distrib_Computing_Toolbox") ...
                && ~isempty(ver("parallel"));
            if ~has_pct
                testCase.verifyFalse(started);
            end
        end

        function helperLeavesMatchingPoolAlone(testCase)
            has_pct = exist("parpool", "file") == 2 ...
                && license("test", "Distrib_Computing_Toolbox") ...
                && ~isempty(ver("parallel"));
            testCase.assumeTrue(has_pct, "Parallel Computing Toolbox is not available");
            pool = gcp("nocreate");
            if isempty(pool)
                pool = parpool(1);
                testCase.addTeardown(@local_delete_pool);
            end
            n = pool.NumWorkers;
            started = zef_ensure_parpool(n);
            testCase.verifyTrue(started);
            testCase.verifyEqual(gcp("nocreate").NumWorkers, n);
        end
    end
end

function local_delete_pool()
try
    p = gcp("nocreate");
    if ~isempty(p)
        delete(p);
    end
catch
end
end

