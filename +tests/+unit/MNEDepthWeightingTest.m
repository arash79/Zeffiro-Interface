classdef MNEDepthWeightingTest < matlab.unittest.TestCase
%MNEDEPTHWEIGHTINGTEST  Class-path MNE prior must stay per-source.
%
%   initialize used to wrap the Dale/Lin weight
%       θ_j ∝ data_power / ‖L_triplet_j‖²
%   in mean(...), which made theta a scalar and turned every MNE/WMNE run
%   through this class into unweighted minimum-norm. The comment, the
%   registry entry for "wmne", and KalmanInverter's analogous theta0 (a
%   vector) all say the weight is per source. Pin that.
%
%   See also inverse.MNEInverter.

    methods (Test)
        function thetaIsPerColumnAndLargerForWeakerSources(testCase)
            rng(5);
            n_sens = 18;
            n_src = 8;
            L = randn(n_sens, 3*n_src);
            % Make source 1 ten times more sensitive than source 8.
            L(:,1:3) = 10 * L(:,1:3);
            L(:,end-2:end) = 0.1 * L(:,end-2:end);
            f = randn(n_sens, 4);
            inv = inverse.MNEInverter("number_of_frames", 2);
            inv = inv.initialize(L, f);

            testCase.verifyEqual(numel(inv.theta), size(L,2), ...
                'theta must be one prior variance per lead-field column');
            testCase.verifyEqual(inv.theta(1), inv.theta(2));
            testCase.verifyEqual(inv.theta(2), inv.theta(3));
            testCase.verifyGreaterThan(inv.theta(end), inv.theta(1), ...
                'a weaker lead-field triplet must get a larger prior variance');

            % Product θ * ‖L_triplet‖² is constant (the data-power scale).
            energy = repelem(sum(reshape(sum(L.^2, 1), 3, [])), 3);
            scale = inv.theta .* energy;
            testCase.verifyEqual(max(scale)/min(scale), 1, 'RelTol', 1e-12);
        end

        function userSuppliedThetaIsNotOverwritten(testCase)
            rng(6);
            L = randn(10, 12);
            f = randn(10, 3);
            user = (1:12);
            inv = inverse.MNEInverter("number_of_frames", 2, "theta", user);
            testCase.verifyTrue(inv.thetaSetted);
            inv = inv.initialize(L, f);
            testCase.verifyEqual(inv.theta, user);
        end

        function reconstructionDiffersFromScalarMeanPrior(testCase)
            % The defect this guards against: using mean(θ) instead of θ
            % changes the reconstruction. If they agree, the vector prior
            % has no effect and the test is vacuous.
            rng(7);
            L = randn(16, 24);
            L(:,1:3) = 8 * L(:,1:3);
            f = L * [1;0;0; zeros(21,1)] + 0.05*randn(16,1);
            F = [f, f];

            inv = inverse.MNEInverter("number_of_frames", 2, "signal_to_noise_ratio", 20);
            inv = inv.initialize(L, F);
            z = inv.invert(f, L, struct(), 1, [], "use_gpu", false);

            inv_s = inverse.MNEInverter("number_of_frames", 2, "signal_to_noise_ratio", 20);
            inv_s = inv_s.initialize(L, F);
            inv_s.theta = mean(inv_s.theta);
            inv_s.precomputed_inverse_operator = [];
            z_s = inv_s.invert(f, L, struct(), 1, [], "use_gpu", false);

            testCase.verifyThat(norm(z - z_s) > 1e-6*norm(z), ...
                matlab.unittest.constraints.IsTrue(), ...
                'depth weighting must change the reconstruction relative to a scalar prior');
        end
    end
end
