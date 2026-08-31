classdef MEGGradiometerDistanceLawTest < matlab.unittest.TestCase
%MEGGRADIOMETERDISTANCELAWTEST  1/|r|^3 falloff in the MEG gradiometer load.
%
%   zef_lead_field_meg_grad_fem builds its nodal load vector by reusing the
%   variable sensor_mat_aux: it first holds r = r_sensor - r_centroid, is then
%   overwritten with the transformed vector n2 - 3(n2.e_r)e_r. Upstream and
%   this port both went on to compute the 1/|r|^3 factor from the overwritten
%   variable, so the factor became |n2 - 3(n2.e_r)e_r|^3 = (1+3(n2.e_r)^2)^1.5,
%   a dimensionless number in [1,8]. The FEM contribution therefore had no
%   distance dependence while the FI and edgewise contributions added to it
%   did, so the primary and secondary fields were summed on inconsistent
%   scales.
%
%   These tests pin the invariant that was violated: the kernel must fall off
%   as 1/|r|^3, and the FEM and FI branches must agree on that falloff.
%
%   See also zef_lead_field_meg_grad_fem, zef_lead_field_meg_fem.

    methods (Static, Access = private)
        function w = femBranchWeight(r_vec, n1, n2, sigma_grad)
            % Mirrors the load-vector body of zef_lead_field_meg_grad_fem.
            nrm = sqrt(sum(r_vec.^2, 1));
            e_r = r_vec ./ nrm;
            dps = n2(1)*e_r(1,:) + n2(2)*e_r(2,:) + n2(3)*e_r(3,:);
            T = n2 - 3*dps.*e_r;
            cross_mat = cross(sigma_grad, T);
            power_vec = (nrm.^2).*nrm;
            w = (n1(1)*cross_mat(1,:) + n1(2)*cross_mat(2,:) + n1(3)*cross_mat(3,:)) ...
                ./ (3*power_vec);
        end

        function w = fiBranchWeight(r_vec, q, n1, n2)
            % Mirrors the corrected primary-field branches.
            nrm = sqrt(sum(r_vec.^2, 1));
            e_r = r_vec ./ nrm;
            dps = n2(1)*e_r(1,:) + n2(2)*e_r(2,:) + n2(3)*e_r(3,:);
            cross_mat = cross(q, n2 - 3*dps.*e_r);
            w = (n1(1)*cross_mat(1,:) + n1(2)*cross_mat(2,:) + n1(3)*cross_mat(3,:)) ...
                ./ ((nrm.^2).*nrm);
        end

        function w = fiBranchWeightPreFix(r_vec, q, n1, n2)
            % The pre-fix primary field: q x r normalised and substituted for
            % e_r, with q absent from any cross product afterwards.
            cm = cross(q, r_vec);
            cm = cm ./ sqrt(sum(cm.^2, 1));
            dps = n2(1)*cm(1,:) + n2(2)*cm(2,:) + n2(3)*cm(3,:);
            T = n2 - 3*dps.*cm;
            nrm = sqrt(sum(r_vec.^2, 1));
            w = (n1(1)*T(1,:) + n1(2)*T(2,:) + n1(3)*T(3,:)) ./ ((nrm.^2).*nrm);
        end

        function w = brokenBranchWeight(r_vec, n1, n2, sigma_grad)
            % The pre-fix form, kept so the tests can show the two differ.
            nrm = sqrt(sum(r_vec.^2, 1));
            e_r = r_vec ./ nrm;
            dps = n2(1)*e_r(1,:) + n2(2)*e_r(2,:) + n2(3)*e_r(3,:);
            T = n2 - 3*dps.*e_r;
            cross_mat = cross(sigma_grad, T);
            power_vec = sqrt(sum(T.^2, 1));
            power_vec = (power_vec.^2).*power_vec;
            w = (n1(1)*cross_mat(1,:) + n1(2)*cross_mat(2,:) + n1(3)*cross_mat(3,:)) ...
                ./ (3*power_vec);
        end
    end

    methods (Test)
        function kernelFallsOffAsInverseCubeOfDistance(testCase)
            % Hold the geometry fixed and only push the sensor further away
            % along the same ray, so the sole change is |r|.
            e = [0.3 -0.5 0.8]'; e = e/norm(e);
            n1 = [1 0 0]'; n2 = [0 1 0]';
            sigma_grad = [0.11 -0.07 0.23]';

            base = 0.04;
            w_base = tests.unit.MEGGradiometerDistanceLawTest.femBranchWeight( ...
                base*e, n1, n2, sigma_grad);
            testCase.assumeTrue(abs(w_base) > 0, 'degenerate fixture');

            for k = [2 3 4]
                w_far = tests.unit.MEGGradiometerDistanceLawTest.femBranchWeight( ...
                    k*base*e, n1, n2, sigma_grad);
                % Only the 1/|r|^3 factor changes, so the ratio is exactly k^3.
                testCase.verifyEqual(w_base/w_far, k^3, 'RelTol', 1e-12, ...
                    sprintf('weight must scale as 1/r^3; failed at k=%d', k));
            end
        end

        function femAndFiBranchesShareTheSameFalloff(testCase)
            % The FI branch divides by an independently computed |r|^3. Both
            % contributions are summed into one lead field, so their distance
            % dependence has to match.
            rng(31);
            e = randn(3,1); e = e/norm(e);
            n1 = randn(3,1); n1 = n1/norm(n1);
            n2 = randn(3,1); n2 = n2/norm(n2);
            sigma_grad = randn(3,1);

            radii = [0.04 0.06 0.09 0.13 0.16];
            fem = arrayfun(@(r) tests.unit.MEGGradiometerDistanceLawTest.femBranchWeight( ...
                r*e, n1, n2, sigma_grad), radii);
            % FI-branch distance factor, computed the way that branch does.
            fi = 1 ./ (radii.^3);

            % Ratio of the two must be constant across distance.
            ratio = fem ./ fi;
            testCase.verifyEqual(max(ratio)/min(ratio), 1, 'RelTol', 1e-12, ...
                'FEM and FI branches disagree on the distance falloff');
        end

        function preFixFormHadNoDistanceDependence(testCase)
            % Demonstrates the defect this test guards against, so the guard
            % cannot silently become vacuous.
            e = [0 0 1]'; n1 = [1 0 0]'; n2 = [0 1 0]';
            sigma_grad = [1 1 1]';
            w1 = tests.unit.MEGGradiometerDistanceLawTest.brokenBranchWeight( ...
                0.04*e, n1, n2, sigma_grad);
            w2 = tests.unit.MEGGradiometerDistanceLawTest.brokenBranchWeight( ...
                0.16*e, n1, n2, sigma_grad);
            testCase.verifyEqual(w1, w2, 'AbsTol', 0, ...
                'pre-fix form is distance independent; if this fails the reference drifted');

            % And the fixed form must not be distance independent.
            v1 = tests.unit.MEGGradiometerDistanceLawTest.femBranchWeight( ...
                0.04*e, n1, n2, sigma_grad);
            v2 = tests.unit.MEGGradiometerDistanceLawTest.femBranchWeight( ...
                0.16*e, n1, n2, sigma_grad);
            testCase.verifyEqual(v1/v2, 4^3, 'RelTol', 1e-12);
        end

        function primaryFieldIsTheDirectionalDerivativeOfTheMagnetometerField(testCase)
            % The defining property of a gradiometer: its response is the
            % spatial derivative of the magnetometer response along the coil
            % baseline n2. Writing c = n1 x q, both the analytic derivative of
            % (q x r).n1/|r|^3 along n2 and the implemented kernel reduce to
            %   [(c.n2) - 3 (c.e_r)(e_r.n2)] / |r|^3,
            % so a central difference of the magnetometer formula must match
            % the gradiometer formula with no free scale factor.
            rng(101);
            for trial = 1:25
                q  = randn(3,1);
                n1 = randn(3,1); n1 = n1/norm(n1);
                n2 = randn(3,1); n2 = n2/norm(n2);
                r  = randn(3,1); r = 0.09 * r/norm(r);

                mag = @(rv) dot(cross(q, rv), n1) / norm(rv)^3;

                h = 1e-7;
                fd = (mag(r + h*n2) - mag(r - h*n2)) / (2*h);

                grad = tests.unit.MEGGradiometerDistanceLawTest.fiBranchWeight( ...
                    r, q, n1, n2);

                % Central differences on a smooth function at this step size
                % carry O(h^2) truncation plus cancellation noise, so a few
                % parts in 10^6 of the derivative magnitude is the honest bar.
                testCase.verifyEqual(grad, fd, 'RelTol', 1e-6, ...
                    sprintf('gradiometer primary field is not d/dn2 of the magnetometer field (trial %d)', trial));
            end
        end

        function preFixPrimaryFieldFailsTheDerivativeIdentity(testCase)
            % Shows the identity above actually discriminates: the old form,
            % which normalised q x r and fed it in place of e_r, does not
            % satisfy it.
            rng(202);
            q  = [0.7 -0.2 0.4]';
            n1 = [0 0 1]';
            n2 = [1 0 0]';
            r  = 0.09 * [0.3 0.5 -0.8]'/norm([0.3 0.5 -0.8]);

            mag = @(rv) dot(cross(q, rv), n1) / norm(rv)^3;
            h = 1e-7;
            fd = (mag(r + h*n2) - mag(r - h*n2)) / (2*h);

            fixed = tests.unit.MEGGradiometerDistanceLawTest.fiBranchWeight(r, q, n1, n2);
            old   = tests.unit.MEGGradiometerDistanceLawTest.fiBranchWeightPreFix(r, q, n1, n2);

            testCase.verifyEqual(fixed, fd, 'RelTol', 1e-6);
            testCase.verifyThat(abs(old - fd) > 1e-3*abs(fd), ...
                matlab.unittest.constraints.IsTrue(), ...
                'pre-fix primary field unexpectedly satisfies the derivative identity');
        end

        function fiBranchUsesTheRadialUnitVectorNotTheNormalisedCrossProduct(testCase)
            f = which('zef_lead_field_meg_grad_fem');
            testCase.assertNotEmpty(f);
            lines = splitlines(string(fileread(f)));
            code = strtrim(lines(~startsWith(strtrim(lines), "%")));

            testCase.verifyEmpty(code(contains(code, ...
                "sensor_mat_aux = sensor_mat_aux./repmat(sqrt(sum(sensor_mat_aux.^2)),3,1)")), ...
                'the primary-field branches must not normalise q x r and use it as e_r');
            testCase.verifyTrue(any(contains(code, "cross(fi_source_directions', n2 - 3*dps.*e_r)")), ...
                'FI primary field should cross the dipole direction with the e_r kernel');
        end

        function sourceDoesNotDeriveTheDistanceFromTheOverwrittenVariable(testCase)
            % Guards the specific regression: power_vec must not be rebuilt
            % from sensor_mat_aux after it has been overwritten with the
            % transformed vector.
            f = which('zef_lead_field_meg_grad_fem');
            testCase.assertNotEmpty(f, 'zef_lead_field_meg_grad_fem not on path');
            lines = splitlines(string(fileread(f)));
            code = strtrim(lines(~startsWith(strtrim(lines), "%")));

            loadBlock = code(contains(code, "power_vec = sqrt(sum(sensor_mat_aux.^2"));
            testCase.verifyEmpty(loadBlock, ...
                "power_vec must come from the true distance (nrm), not from the " + ...
                "overwritten sensor_mat_aux");
            testCase.verifyTrue(any(contains(code, "power_vec = (nrm.^2).*nrm")), ...
                'expected the |r|^3 factor to be built from nrm');
        end
    end
end
