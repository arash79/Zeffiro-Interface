classdef MCMCPosteriorMeanDivisorTest < matlab.unittest.TestCase
%MCMCPOSTERIORMEANDIVISORTEST  Mean over post-burn-in samples, all chains.

    methods (Test)
        function multiChainBurnInIsProductNotMinus(testCase)
            n_iter = 5;
            n_burn = 1;
            n_chains = 4;
            d = zef_mcmc_posterior_mean_divisor(n_iter, n_burn, n_chains);
            testCase.verifyEqual(d, (n_iter - n_burn) * n_chains);
            inherited = n_iter * n_chains - n_burn;
            testCase.verifyNotEqual(d, inherited);
        end

        function oneChainAgreesWithInheritedFormula(testCase)
            d = zef_mcmc_posterior_mean_divisor(10, 2, 1);
            testCase.verifyEqual(d, 10*1 - 2);
        end

        function pluginUsesHelperAndPriorMeanInit(testCase)
            root = fileparts(which("zeffiro_interface"));
            testCase.assumeNotEmpty(root, "zeffiro_interface is not on the MATLAB path");
            src = fileread(fullfile(root, "plugins", "HBSampler", "m", "zef_mcmc.m"));
            testCase.verifyTrue(contains(src, "zef_mcmc_posterior_mean_divisor"));
            testCase.verifyTrue(contains(src, "theta_init"));
            testCase.verifyFalse(contains(src, "theta{j} = theta0.*ones"));
        end
    end
end
