classdef SessionWantsGpuTest < matlab.unittest.TestCase
%SESSIONWANTSGPUTEST  GPU gate reads the session argument, not evalin('base').

    methods (Test)
        function testUseGpuZero(testCase)
            testCase.verifyFalse(zef_session_wants_gpu(struct("use_gpu", 0, "gpu_count", 2)));
        end

        function testUseGpuWithCount(testCase)
            testCase.verifyTrue(zef_session_wants_gpu(struct("use_gpu", 1, "gpu_count", 2)));
            testCase.verifyFalse(zef_session_wants_gpu(struct("use_gpu", 1, "gpu_count", 0)));
        end

        function testEmptyAndMissing(testCase)
            testCase.verifyFalse(zef_session_wants_gpu([]));
            testCase.verifyFalse(zef_session_wants_gpu(struct("foo", 1)));
        end

        function testFemFilesDoNotEvalinGpuCount(testCase)
            files = [ ...
                "zef_lead_field_meg_fem.m", ...
                "zef_lead_field_meg_grad_fem.m", ...
                "zef_lead_field_eit_fem.m"];
            folder = fullfile("src", "forward", "lead_field");
            for k = 1:numel(files)
                src = fileread(fullfile(folder, files(k)));
                testCase.verifyFalse(contains(src, "evalin('base','zef.gpu_count')"), files(k));
                testCase.verifyTrue(contains(src, "zef_session_wants_gpu"), files(k));
            end
        end
    end
end
