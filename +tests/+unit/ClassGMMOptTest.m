classdef ClassGMMOptTest < matlab.unittest.TestCase
%CLASSGMMOPTTEST  ClassGMM implementation opts preserve labels, EM, and outputs.

    methods (TestMethodSetup)
        function seedRngAndCloseWaitbars(~)
            rng(11, "twister");
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
        function mahalanobisMatchesDiagForm(testCase)
            ns = [40, 200, 1200];
            for n = ns
                [X, mu, Sigma] = i_synth_gmm_params(n, 5, 3);
                [D_old, idx_old] = i_mahal_old(X, mu, Sigma);
                [D_new, idx_new] = i_mahal_new(X, mu, Sigma);
                testCase.verifyEqual(idx_old, idx_new);
                testCase.verifyEqual(size(D_new), size(D_old));
                testCase.verifyLessThanOrEqual(max(abs(D_old(:) - D_new(:))), 1e-12);
            end
        end

        function mahalanobisMatchesOnNearTies(testCase)
            n = 300;
            d = 3;
            X = [randn(n, d); randn(n, d) + [4 0 0]];
            mu = [0 0 0; 4 0 0];
            Sigma = cat(3, eye(d), eye(d));
            [D_old, idx_old] = i_mahal_old(X, mu, Sigma);
            [D_new, idx_new] = i_mahal_new(X, mu, Sigma);
            testCase.verifyEqual(idx_old, idx_new);
            testCase.verifyLessThanOrEqual(max(abs(D_old(:) - D_new(:))), 1e-12);
        end

        function mahalanobisEmptyAndSingleton(testCase)
            [D_old, idx_old] = i_mahal_old(zeros(0, 3), zeros(2, 3), cat(3, eye(3), eye(3)));
            [D_new, idx_new] = i_mahal_new(zeros(0, 3), zeros(2, 3), cat(3, eye(3), eye(3)));
            testCase.verifyEqual(idx_old, idx_new);
            testCase.verifyEqual(D_old, D_new);
            X = randn(1, 4);
            mu = randn(2, 4);
            A = randn(4);
            Sigma = cat(3, A'*A + eye(4), A'*A + 1.2*eye(4));
            [D_old, idx_old] = i_mahal_old(X, mu, Sigma);
            [D_new, idx_new] = i_mahal_new(X, mu, Sigma);
            testCase.verifyEqual(idx_old, idx_new);
            testCase.verifyLessThanOrEqual(max(abs(D_old(:) - D_new(:))), 1e-12);
        end

        function estepWeightMatchesFreshOptimset(testCase)
            n = 500;
            k = 3;
            log_lh = randn(n, k);
            post = i_softmax(log_lh);
            w = rand(n, 1);
            w = w / sum(w);
            w_new = inverse.gmm.EstepWeight(log_lh, post, w);
            w_old = i_estepweight_old(log_lh, post, w);
            testCase.verifyEqual(w_new, w_old);
        end

        function fitAdvGMMWorksWithoutAdvancedGMMPath(testCase)
            adv = fullfile(pwd, "plugins", "GMMClustering", ...
                "GMModeling App (JL)", "m", "AdvancedGMM");
            if contains(path, char(adv))
                rmpath(adv);
                testCase.addTeardown(@() addpath(adv));
            end
            [X, w] = i_synth_weighted(250, 3, 2);
            idx = ones(250, 1);
            idx(126:end) = 2;
            opts = statset("MaxIter", 40, "TolFun", 1e-6, "Display", "off");
            obj = inverse.gmm.FitAdvGMM(X, w, 2, "CovarianceType", "full", ...
                "SharedCovariance", false, "Start", idx, ...
                "RegularizationValue", 1e-2, "Options", opts);
            testCase.verifyEqual(obj.NComponents, 2);
            testCase.verifyEqual(size(obj.mu), [2, 3]);
            testCase.verifyEqual(size(obj.Sigma, 1), 3);
            testCase.verifyTrue(isfinite(obj.NlogL));
            testCase.verifyTrue(isfinite(obj.BIC));
        end

        function classGMModelingOutputsAreFiniteAndShaped(testCase)
            [zef, rec, inv] = i_synth_zef_rec(400);
            inv2 = inverse.gmm.ClassGMModeling(inv, rec, zef, ...
                "number_of_clusters", 3, ...
                "sought_estimate", "Location & orientation", ...
                "covariance_type", "full", ...
                "MaxIter", 60, ...
                "model_selection_criterion", "Given number of components", ...
                "initial_cluster_finding_approach", "Maximum component-wise fit", ...
                "regularization_parameter", 1e-2);
            testCase.verifyTrue(isstruct(inv2.GMM.Model));
            testCase.verifyEqual(inv2.GMM.Model.NComponents, 3);
            testCase.verifyEqual(size(inv2.GMM.Model.mu, 2), 5);
            testCase.verifyEqual(size(inv2.GMM.Dipoles), [3, 3]);
            testCase.verifyEqual(numel(inv2.GMM.Amplitudes), 3);
            testCase.verifyTrue(all(isfinite(inv2.GMM.Model.mu), "all"));
            testCase.verifyTrue(all(isfinite(inv2.GMM.Dipoles), "all"));
            testCase.verifyEqual(inv2.GMM.TimeVariables.sampling_frequency, inv.sampling_frequency);
        end

        function classGMModelingIsDeterministicInMode3(testCase)
            [zef, rec, inv] = i_synth_zef_rec(350);
            args = {"number_of_clusters", 2, "MaxIter", 50, ...
                "model_selection_criterion", "Given number of components", ...
                "initial_cluster_finding_approach", "Maximum component-wise fit", ...
                "regularization_parameter", 1e-2};
            a = inverse.gmm.ClassGMModeling(inv, rec, zef, args{:});
            b = inverse.gmm.ClassGMModeling(inv, rec, zef, args{:});
            testCase.verifyEqual(a.GMM.Model.mu, b.GMM.Model.mu);
            testCase.verifyEqual(a.GMM.Model.Sigma, b.GMM.Model.Sigma);
            testCase.verifyEqual(a.GMM.Model.NlogL, b.GMM.Model.NlogL);
            testCase.verifyEqual(a.GMM.Model.Iters, b.GMM.Model.Iters);
            testCase.verifyEqual(a.GMM.Dipoles, b.GMM.Dipoles);
        end

        function recoversSeparatedGaussianMeans(testCase)
            rng(19, "twister");
            n = 180;
            mu_true = [0 0 0; 8 0 0];
            X = [0.25 * randn(n, 3); mu_true(2, :) + 0.25 * randn(n, 3)];
            w = ones(2 * n, 1);
            w = w / sum(w);
            idx = [ones(n, 1); 2 * ones(n, 1)];
            opts = statset("MaxIter", 80, "TolFun", 1e-8, "Display", "off");
            obj = inverse.gmm.FitAdvGMM(X, w, 2, "CovarianceType", "full", ...
                "SharedCovariance", false, "Start", idx, ...
                "RegularizationValue", 1e-4, "Options", opts);
            e = zeros(2, 1);
            used = false(2, 1);
            for j = 1:2
                dj = vecnorm(obj.mu - mu_true(j, :), 2, 2);
                dj(used) = inf;
                [e(j), k] = min(dj);
                used(k) = true;
            end
            testCase.verifyLessThan(max(e), 0.35);
        end

        function computeGMMWrapperMatchesDirectCall(testCase)
            [zef, rec, inv] = i_synth_zef_rec(280);
            nv = {"number_of_clusters", 2, "MaxIter", 40, ...
                "model_selection_criterion", "Given number of components", ...
                "initial_cluster_finding_approach", "Maximum component-wise fit", ...
                "regularization_parameter", 1e-2};
            direct = inverse.gmm.ClassGMModeling(inv, rec, zef, nv{:});
            wrapped = inv.computeGMM("reconstruction", rec, "zef", zef, nv{:});
            testCase.verifyEqual(wrapped.GMM.Model.mu, direct.GMM.Model.mu);
            testCase.verifyEqual(wrapped.GMM.Model.NlogL, direct.GMM.Model.NlogL);
            testCase.verifyEqual(wrapped.GMM.Dipoles, direct.GMM.Dipoles);
        end

        function locationOrientationDiagonalCovarianceRuns(testCase)
            [zef, rec, inv] = i_synth_zef_rec(220);
            out = inverse.gmm.ClassGMModeling(inv, rec, zef, ...
                "number_of_clusters", 2, ...
                "sought_estimate", "Location & orientation", ...
                "covariance_type", "diagonal", ...
                "MaxIter", 40, ...
                "model_selection_criterion", "Given number of components", ...
                "initial_cluster_finding_approach", "k-means ++", ...
                "regularization_parameter", 1e-2);
            testCase.verifyEqual(out.GMM.Model.NDimensions, 5);
            testCase.verifyEqual(out.GMM.Model.CovType, 'diagonal');
            testCase.verifyTrue(isfinite(out.GMM.Model.NlogL));
            testCase.verifyEqual(size(out.GMM.Dipoles, 2), 3);
        end

        function cellFramesProduceCellOutputs(testCase)
            [zef, rec, inv] = i_synth_zef_rec(180);
            recs = {rec, 0.8 * rec};
            out = inverse.gmm.ClassGMModeling(inv, recs, zef, ...
                "number_of_clusters", 2, ...
                "MaxIter", 30, ...
                "model_selection_criterion", "Given number of components", ...
                "initial_cluster_finding_approach", "Maximum component-wise fit", ...
                "regularization_parameter", 1e-2);
            testCase.verifyTrue(iscell(out.GMM.Model));
            testCase.verifyEqual(numel(out.GMM.Model), 2);
            testCase.verifyTrue(isstruct(out.GMM.Model{1}) && isstruct(out.GMM.Model{2}));
            testCase.verifyTrue(iscell(out.GMM.Dipoles));
        end

        function maximumProbabilityModeRuns(testCase)
            [zef, rec, inv] = i_synth_zef_rec(260);
            out = inverse.gmm.ClassGMModeling(inv, rec, zef, ...
                "number_of_clusters", 2, ...
                "MaxIter", 40, ...
                "model_selection_criterion", "Given number of components", ...
                "initial_cluster_finding_approach", "Maximum probability", ...
                "regularization_parameter", 1e-2);
            testCase.verifyTrue(isstruct(out.GMM.Model));
            testCase.verifyGreaterThanOrEqual(out.GMM.Model.NComponents, 1);
        end
    end
end

function [D, idx] = i_mahal_old(X, mu, Sigma)
k = size(mu, 1);
D = nan(size(X, 1), k);
for kk = 1:k
    D(:, kk) = diag((mu(kk, :) - X) * (squeeze(Sigma(:, :, kk)) \ (mu(kk, :) - X)'));
end
[~, idx] = min(D, [], 2);
end

function [D, idx] = i_mahal_new(X, mu, Sigma)
k = size(mu, 1);
D = nan(size(X, 1), k);
for kk = 1:k
    delta = mu(kk, :) - X;
    D(:, kk) = sum(delta .* (squeeze(Sigma(:, :, kk)) \ delta')', 2);
end
[~, idx] = min(D, [], 2);
end

function [X, mu, Sigma] = i_synth_gmm_params(n, d, k)
X = randn(n, d);
mu = randn(k, d);
Sigma = zeros(d, d, k);
for j = 1:k
    A = randn(d);
    Sigma(:, :, j) = A' * A + 0.25 * eye(d);
end
end

function P = i_softmax(A)
m = max(A, [], 2);
E = exp(A - m);
P = E ./ sum(E, 2);
end

function w = i_estepweight_old(log_lh, post, weight)
log_lh = sum(post .* log_lh, 2);
options = optimset("Display", "off");
alpha = fminbnd(@(s) i_target(s, weight, log_lh), 0, 4, options);
w = weight .^ alpha;
w = w / sum(w);
end

function val = i_target(s, weight, p)
weight = weight .^ s;
weight = weight / sum(weight);
val = -sum(weight .* p, 1);
end

function [X, w] = i_synth_weighted(n, d, k)
centers = 3 * randn(k, d);
idx = randi(k, n, 1);
X = zeros(n, d);
amp = zeros(n, 1);
for j = 1:k
    m = idx == j;
    X(m, :) = centers(j, :) + 0.5 * randn(sum(m), d);
    amp(m) = exp(-sum((X(m, :) - centers(j, :)).^2, 2));
end
w = amp / sum(amp);
end

function [zef, rec, inv] = i_synth_zef_rec(nsrc)
pos = randn(nsrc, 3);
centers = [2 0 0; -2 0 0; 0 2 0];
rec = zeros(3 * nsrc, 1);
for j = 1:3
    g = exp(-sum((pos - centers(j, :)).^2, 2) / 0.8);
    dir = [0.2 * j, 1, 0.1];
    dir = dir / norm(dir);
    rec(1:3:end) = rec(1:3:end) + g * dir(1);
    rec(2:3:end) = rec(2:3:end) + g * dir(2);
    rec(3:3:end) = rec(3:3:end) + g * dir(3);
end
zef = struct;
zef.source_positions = pos;
inv = inverse.CommonInverseParameters();
end
