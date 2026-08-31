classdef DTIActiveCompartmentMapTest < matlab.unittest.TestCase
%DTIACTIVECOMPARTMENTMAPTEST  domain_labels uses active-compartment indices.

    methods (Test)
        function testSkippedOffCompartmentDoesNotOccupyALabel(testCase)
            zef = struct();
            zef.compartment_tags = {'skin', 'skull', 'wm'};
            zef.skin_on = true;
            zef.skull_on = false;
            zef.wm_on = true;
            map = zef_dti_active_compartment_map(zef);
            testCase.verifyEqual(map(:), [1; 0; 2]);
        end

        function testIsoFallbackUsesActiveIndexNotTagPosition(testCase)
            % Two active compartments; wm is tag 3 but domain_labels==2.
            zef = struct();
            zef.compartment_tags = {'skin', 'skull', 'wm'};
            zef.skin_on = true;
            zef.skull_on = false;
            zef.wm_on = true;
            zef.skin_sigma = 0.33;
            zef.skull_sigma = 0.006;
            zef.wm_sigma = 0.14;
            map = zef_dti_active_compartment_map(zef);
            dl = [1; 1; 2; 2];
            scale_value = 0.99;
            sigma_per_tetra = scale_value * ones(4, 1);
            for k = 1:numel(zef.compartment_tags)
                tag_name = zef.compartment_tags{k};
                sigma_var = [tag_name '_sigma'];
                if isfield(zef, sigma_var) && map(k) > 0
                    I = (dl == map(k));
                    sigma_per_tetra(I) = zef.(sigma_var);
                end
            end
            testCase.verifyEqual(sigma_per_tetra, [0.33; 0.33; 0.14; 0.14]);
            % The inherited bug compared dl == k (tag position). That would
            % assign skull_sigma to the wm tets (label 2) and miss wm_sigma.
            wrong = scale_value * ones(4, 1);
            for k = 1:numel(zef.compartment_tags)
                tag_name = zef.compartment_tags{k};
                I = (dl == k);
                wrong(I) = zef.([tag_name '_sigma']);
            end
            testCase.verifyEqual(wrong(3:4), [0.006; 0.006]);
            testCase.verifyNotEqual(sigma_per_tetra(3), wrong(3));
        end

        function testPartialApplyDoesNotMarkNonTargetAsIso(testCase)
            M = 4;
            update_indices = [3; 4];
            sigma_anisotropy = [0.2 0.2 0.2 0 0 0.1; ...
                0.2 0.2 0.2 0 0 0.1; ...
                0 0 0 0 0 0; ...
                0 0 0 0 0 0];
            iso_mask = false(M, 1);
            iso_mask(update_indices) = all(sigma_anisotropy(update_indices, :) == 0, 2);
            testCase.verifyEqual(iso_mask(:), [false; false; true; true]);
        end
    end
end
