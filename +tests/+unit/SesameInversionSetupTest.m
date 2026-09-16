classdef SesameInversionSetupTest < matlab.unittest.TestCase
%SESAMEINVERSIONSETUPTEST  SESAME Start wrapper subsets sources without SMC.

    methods (TestMethodSetup)
        function stashBaseZef(testCase)
            testCase.addTeardown(@() evalin("base", "clear zef"));
            if evalin("base", "exist('zef','var')")
                previous = evalin("base", "zef");
                testCase.addTeardown(@() assignin("base", "zef", previous));
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
        function uniqueInterpolationIndicesProduceReconstruction(testCase)
            stubDir = tempname;
            mkdir(stubDir);
            testCase.addTeardown(@() rmdir(stubDir, "s"));
            stubFile = fullfile(stubDir, "inverse_SESAME.m");
            writelines([ ...
                "function result = inverse_SESAME(full_data, leadfield, sourcespace, cfg)"
                "n_comp = size(leadfield, 2) / size(sourcespace, 1);"
                "assert(n_comp == 3, 'leadfield columns must be 3 per unique interpolated source');"
                "result = struct();"
                "result.estimated_dipoles = 1;"
                "result.QV_estimated = [1; 0; 0];"
                "end"], stubFile);
            addpath(stubDir, "-begin");
            testCase.addTeardown(@() rmpath(stubDir));

            zef = tests.support.createSyntheticInverseZef();
            zef.source_positions = [0 0 0; 1 1 1; 9 9 9];
            zef.source_interpolation_ind{1} = [1; 1; 2];
            zef.number_of_frames = 1;
            zef.inv_data_mode = "raw";
            zef.inv_low_cut_frequency = 0;
            zef.inv_high_cut_frequency = 0;
            zef.SESAME_snr = 20;
            zef.SESAME_n_sampler = 4;
            assignin("base", "zef", zef);

            z = SESAME_inversion([]);
            testCase.verifyTrue(iscell(z));
            testCase.verifyEqual(numel(z), 1);
            testCase.verifyTrue(all(isfinite(z{1})));
            restored = evalin("base", "zef");
            testCase.verifyTrue(isfield(restored, "SESAME"));
            testCase.verifyEqual(restored.SESAME.estimated_dipoles, 1);
        end
    end
end
