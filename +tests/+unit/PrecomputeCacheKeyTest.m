classdef PrecomputeCacheKeyTest < matlab.unittest.TestCase
%PrecomputeCacheKeyTest  Precomputed inverse operators must not outlive their inputs.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Five inverters cache an operator built from the lead field and from solver
%   settings: CSM, MNE, eLORETA, Beamformer and DipoleScan. They are handle
%   classes, so the cache survives any later property change. Each test here
%   asserts two things per inverter:
%
%     1. equivalence — precompute + invert reproduces the uncached invert, so
%        the fast path is not a different algorithm;
%     2. invalidation — changing a setting that the cached operator depends on
%        after precompute gives the same answer as a freshly configured
%        inverter, i.e. the stale operator is discarded rather than reused.
%
%   Regression guard for the cache-key defect where CSMInverter keyed its
%   caches on [theta0, SNR] only. Switching method_type from "dSPM" to
%   "sLORETA" then reused the dSPM standardization vector 1/sqrt((P S P')_ii)
%   where sLORETA needs 1/sqrt((P L)_ii), silently returning a reconstruction
%   with a 2.4e0 relative error and no warning.
%
%   See also inverse.precompute_cache_key.

    properties (Constant)
        % Realistic shape: a lead field has many more source degrees of
        % freedom than sensors. With 3*NumSources < NumSensors instead, L*L'
        % is rank deficient, L_theta*L' + noise_cov becomes singular
        % (cond ~1e18) and the MNE normal equations stop being solvable in
        % either code path, which is a property of the fixture rather than of
        % the inverters.
        NumSensors = 24
        NumSources = 20
    end

    methods (Access = private)

        function [L, f_data, procFile] = fixture(testCase, seed)
            %fixture  Deterministic lead field, frames and source index sets.
            rng(seed, 'twister');
            n_sens = testCase.NumSensors;
            n_src  = testCase.NumSources;
            L = randn(n_sens, 3*n_src);
            f_data = randn(n_sens, 3);
            procFile = struct( ...
                's_ind_0', (1:n_src)', ...
                's_ind_4', zeros(0,1));
        end

    end

    methods (Test)

        function cacheKeyHelperDistinguishesInputs(testCase)
            %cacheKeyHelperDistinguishesInputs  The shared fingerprint is scalar and discriminating.
            L = randn(10, 6);
            k1 = inverse.precompute_cache_key(L, {"a", 1});
            testCase.verifyEqual(size(k1), [1 1], ...
                'cache key must be a scalar struct so isequaln compares values');
            testCase.verifyTrue(isequaln(k1, inverse.precompute_cache_key(L, {"a", 1})));
            testCase.verifyFalse(isequaln(k1, inverse.precompute_cache_key(L, {"b", 1})));
            testCase.verifyFalse(isequaln(k1, inverse.precompute_cache_key(L, {"a", 2})));
            L2 = L; L2(3,4) = L2(3,4) + 1e-9;
            testCase.verifyFalse(isequaln(k1, inverse.precompute_cache_key(L2, {"a", 1})), ...
                'a perturbed lead field must not validate an existing cache');
            testCase.verifyTrue(isempty(inverse.precompute_cache_key([], {})));
        end

        function csmCacheRespectsMethodType(testCase)
            %csmCacheRespectsMethodType  dSPM caches must never serve sLORETA (and back).
            [L, f_data, procFile] = testCase.fixture(42);
            f = f_data(:,1);
            mk = @() inverse.CSMInverter('method_type', "dSPM", ...
                    'signal_to_noise_ratio', 30, 'number_of_frames', 2);

            pairs = {"dSPM", "sLORETA"; "sLORETA", "dSPM"; "dSPM", "sLORETA 3D"};
            for p = 1:size(pairs,1)
                from = pairs{p,1}; to = pairs{p,2};

                ref = mk(); ref.method_type = to;
                ref = ref.initialize(L, f_data);
                z_ref = ref.invert(f, L, procFile, 1, []);

                obj = mk(); obj.method_type = from;
                obj = obj.initialize(L, f_data);
                obj = obj.precompute(L);
                obj.method_type = to;
                z_got = obj.invert(f, L, procFile, 1, []);

                testCase.verifyEqual(z_got, z_ref, 'AbsTol', 0, ...
                    sprintf('precompute(%s) then invert(%s) reused a stale cache', from, to));
            end
        end

        function csmPrecomputeMatchesUncached(testCase)
            %csmPrecomputeMatchesUncached  The fast path is the same algorithm.
            [L, f_data, procFile] = testCase.fixture(7);
            f = f_data(:,1);
            for mt = ["dSPM", "sLORETA", "sLORETA 3D"]
                a = inverse.CSMInverter('method_type', mt, 'number_of_frames', 2);
                a = a.initialize(L, f_data);
                z_plain = a.invert(f, L, procFile, 1, []);

                b = inverse.CSMInverter('method_type', mt, 'number_of_frames', 2);
                b = b.initialize(L, f_data);
                b = b.precompute(L);
                z_cached = b.invert(f, L, procFile, 1, []);

                testCase.verifyEqual(z_cached, z_plain, 'RelTol', 1e-12, ...
                    sprintf('%s precompute path diverged from the direct path', mt));
            end
        end

        function csmCacheRespectsLeadField(testCase)
            %csmCacheRespectsLeadField  A different lead field must rebuild P.
            [L, f_data, procFile] = testCase.fixture(11);
            f = f_data(:,1);
            L2 = L; L2(:,1) = 3*L2(:,1);

            obj = inverse.CSMInverter('method_type', "sLORETA", 'number_of_frames', 2);
            obj = obj.initialize(L, f_data);
            obj = obj.precompute(L);
            obj.theta0 = 1e-3;                 % pin theta0 so only L differs
            z_got = obj.invert(f, L2, procFile, 1, []);

            ref = inverse.CSMInverter('method_type', "sLORETA", 'number_of_frames', 2);
            ref.theta0 = 1e-3;
            z_ref = ref.invert(f, L2, procFile, 1, []);

            testCase.verifyEqual(z_got, z_ref, 'AbsTol', 0, ...
                'stale P from a previous lead field was reused');
        end

        function mneCacheRespectsTheta(testCase)
            %mneCacheRespectsTheta  W depends on theta; changing it must rebuild W.
            [L, f_data, procFile] = testCase.fixture(3);
            f = f_data(:,1);

            obj = inverse.MNEInverter('number_of_frames', 2);
            obj = obj.initialize(L, f_data);
            obj = obj.precompute(L);
            obj.theta = 5 * obj.theta;
            z_got = obj.invert(f, L, procFile, 1, []);

            ref = inverse.MNEInverter('number_of_frames', 2);
            ref = ref.initialize(L, f_data);
            ref.theta = 5 * ref.theta;
            z_ref = ref.invert(f, L, procFile, 1, []);

            testCase.verifyEqual(z_got, z_ref, 'RelTol', 1e-12, ...
                'MNE reused W built from the previous theta');
        end

        function mnePrecomputeMatchesUncached(testCase)
            [L, f_data, procFile] = testCase.fixture(4);
            f = f_data(:,1);
            a = inverse.MNEInverter('number_of_frames', 2);
            a = a.initialize(L, f_data);
            z_plain = a.invert(f, L, procFile, 1, []);

            b = inverse.MNEInverter('number_of_frames', 2);
            b = b.initialize(L, f_data);
            b = b.precompute(L);
            z_cached = b.invert(f, L, procFile, 1, []);

            testCase.verifyEqual(z_cached, z_plain, 'RelTol', 1e-10);
        end

        function elouretaCacheRespectsAlpha(testCase)
            %elouretaCacheRespectsAlpha  T depends on the regularization parameter.
            [L, f_data, procFile] = testCase.fixture(5);
            f = f_data(:,1);

            obj = inverse.ELORETAInverter('number_of_frames', 2, 'n_max_iterations', 5);
            obj = obj.initialize(L, f_data);
            obj = obj.precompute(L, procFile);
            obj.regularization_parameter = 10 * obj.regularization_parameter;
            z_got = obj.invert(f, L, procFile, 1, []);

            ref = inverse.ELORETAInverter('number_of_frames', 2, 'n_max_iterations', 5);
            ref = ref.initialize(L, f_data);
            ref.regularization_parameter = 10 * ref.regularization_parameter;
            z_ref = ref.invert(f, L, procFile, 1, []);

            testCase.verifyEqual(z_got, z_ref, 'RelTol', 1e-10, ...
                'eLORETA reused T built from the previous alpha');
        end

        function beamformerCacheRespectsMethodType(testCase)
            %beamformerCacheRespectsMethodType  B depends on the beamformer variant.
            [L, f_data, procFile] = testCase.fixture(6);
            f = f_data(:,1);
            lcmv = "Linearly constrained minimum variance (LCMV) beamformer";
            ung  = "Unit noise gain (UNG) beamformer";

            obj = inverse.BeamformerInverter('method_type', lcmv, 'number_of_frames', 2);
            obj = obj.initialize(L, f_data);
            obj = obj.precompute(L, procFile);
            obj.method_type = ung;
            z_got = obj.invert(f, L, procFile, 1, []);

            ref = inverse.BeamformerInverter('method_type', ung, 'number_of_frames', 2);
            ref = ref.initialize(L, f_data);
            z_ref = ref.invert(f, L, procFile, 1, []);

            testCase.verifyEqual(z_got, z_ref, 'RelTol', 1e-10, ...
                'beamformer reused B built for a different method_type');
        end

        function beamformerPrecomputeMatchesUncached(testCase)
            [L, f_data, procFile] = testCase.fixture(8);
            f = f_data(:,1);
            for mt = ["Linearly constrained minimum variance (LCMV) beamformer", ...
                      "Unit noise gain (UNG) beamformer", ...
                      "Unit-gain constrained beamformer"]
                a = inverse.BeamformerInverter('method_type', mt, 'number_of_frames', 2);
                a = a.initialize(L, f_data);
                z_plain = a.invert(f, L, procFile, 1, []);

                b = inverse.BeamformerInverter('method_type', mt, 'number_of_frames', 2);
                b = b.initialize(L, f_data);
                b = b.precompute(L, procFile);
                z_cached = b.invert(f, L, procFile, 1, []);

                testCase.verifyEqual(z_cached, z_plain, 'RelTol', 1e-9, ...
                    sprintf('%s precompute path diverged from the direct path', mt));
            end
        end

        function dipoleScanCacheRespectsRegularization(testCase)
            %dipoleScanCacheRespectsRegularization  Cached singular values carry reg_parameter.
            [L, f_data, procFile] = testCase.fixture(9);
            f = f_data(:,1);

            obj = inverse.DipoleScanInverter('reg_type', "Basic", ...
                'reg_parameter', 1e-3, 'number_of_frames', 2);
            obj = obj.initialize(L, f_data);
            obj = obj.precompute(L);
            obj.reg_parameter = 5e-1;
            z_got = obj.invert(f, L, procFile, 1, []);

            ref = inverse.DipoleScanInverter('reg_type', "Basic", ...
                'reg_parameter', 5e-1, 'number_of_frames', 2);
            ref = ref.initialize(L, f_data);
            z_ref = ref.invert(f, L, procFile, 1, []);

            testCase.verifyEqual(z_got, z_ref, 'RelTol', 1e-10, ...
                'dipole scan reused an SVD carrying the previous reg_parameter');
        end

        function dipoleScanPrecomputeMatchesUncached(testCase)
            [L, f_data, procFile] = testCase.fixture(10);
            f = f_data(:,1);
            a = inverse.DipoleScanInverter('number_of_frames', 2);
            a = a.initialize(L, f_data);
            z_plain = a.invert(f, L, procFile, 1, []);

            b = inverse.DipoleScanInverter('number_of_frames', 2);
            b = b.initialize(L, f_data);
            b = b.precompute(L);
            z_cached = b.invert(f, L, procFile, 1, []);

            testCase.verifyEqual(z_cached, z_plain, 'RelTol', 1e-9);
        end

    end

end
