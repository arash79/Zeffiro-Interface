classdef ForensicPassFixesTest < matlab.unittest.TestCase
%FORENSICPASSFIXESTEST  Source contracts for GUI and plugin behaviour.

    methods (Test)
        function pluginConstrainedSLoretaUsesSqrt(testCase)
            src = fileread(fullfile("plugins", "ClassicalSparseMethods", ...
                "zef_CSM_iteration.m"));
            testCase.verifyTrue(contains(src, ...
                "M = 1./sqrt(sum(P(surf_ind,:).'.*L(:,surf_ind),1)')"));
            testCase.verifyFalse(contains(src, ...
                "M = 1./sum(P(surf_ind,:).'.*L(:,surf_ind),1)'"));
        end

        function mneFilterWidgetsWriteCutFrequencies(testCase)
            src = fileread(fullfile("plugins", "MNETool", "m", ...
                "zef_find_mne_reconstruction.m"));
            testCase.verifyTrue(contains(src, ...
                "zef.inv_low_cut_frequency = zef.mne_low_cut_frequency"));
            testCase.verifyTrue(contains(src, ...
                "zef.inv_high_cut_frequency = zef.mne_high_cut_frequency"));
        end

        function reconstructionToolKeepsHandleAcrossRows(testCase)
            src = fileread(fullfile("plugins", "ReconstructionTool", "m", ...
                "zef_reconstructionTool_apply.m"));
            testCase.verifyFalse(contains(src, ...
                "clear zef_reconstructionTool_function;"));
        end

        function segmentationProfileDeleteRowsUsesRowCount(testCase)
            src = fileread(fullfile("src", "gui", "open", ...
                "zef_open_segmentation_profile.m"));
            testCase.verifyTrue(contains(src, ...
                "size(zef.h_segmentation_profile_table.Data,1)"));
        end

        function epilepsyShowResultsUsesPackageQualifiedDistance(testCase)
            src = fileread(fullfile("+examples", "+studies", ...
                "+decision_making", "+helpers", ...
                "zef_show_results_focal_epilepsy.m"));
            testCase.verifyTrue(contains(src, ...
                "examples.studies.decision_making.helpers.zef_distance_to_resection"));
            testCase.verifyFalse(contains(src, ...
                "dist_resection = zef_distance_to_resection("));
        end

        function startupDoesNotBangGitPull(testCase)
            src = fileread(fullfile("src", "app", "zef_start.m"));
            testCase.verifyFalse(contains(src, "!git pull"));
            testCase.verifyTrue(contains(src, "Zeffiro:GitPullDisabled"));
        end

        function importScriptsUseConfinedRun(testCase)
            src = fileread(fullfile("src", "io", "zef_import_segmentation.m"));
            testCase.verifyTrue(contains(src, "zef_run_confined_script"));
            testCase.verifyFalse(contains(src, "evalc(''' filename"));
        end

        function eloretaPinvFallbackWarns(testCase)
            src = fileread(fullfile("+inverse", "@ELORETAInverter", "precompute.m"));
            testCase.verifyTrue(contains(src, "Zeffiro:ELORETA:CholeskyFallback"));
            testCase.verifyTrue(contains(src, "if average_reference"));
        end

        function asteroidScriptsCallPrefixedGravity(testCase)
            s = fileread(fullfile("src", "forward", "lead_field", ...
                "zef_gravity_lead_field_scalar.m"));
            testCase.verifyTrue(contains(s, "zef_lead_field_gravity("));
            g = fileread(fullfile("src", "forward", "lead_field", ...
                "zef_gravity_gradient_lead_field_scalar.m"));
            testCase.verifyTrue(contains(g, "zef_lead_field_gravity_grad("));
        end

        function rapMusicUsesOrientedTopographies(testCase)
            src = fileread(fullfile("plugins", "RAP-MUSIC", ...
                "RAP_MUSIC_iteration.m"));
            testCase.verifyTrue(contains(src, "zef_rap_music_scan"));
            testCase.verifyTrue(contains(src, "zef_blocked_source_index"));
            testCase.verifyFalse(contains(src, "length(s_ind_1)/3"));
            testCase.verifyFalse(contains(src, "A_mat = L(:,reshape(L_ind(ind_space,:)"));
            start_src = fileread(fullfile("plugins", "RAP-MUSIC", "RAPMUSIC_start.m"));
            testCase.verifyTrue(contains(start_src, "reconstruction_information"));
        end

        function classInverseDialogAdvertisesClassSolver(testCase)
            src = fileread(fullfile("src", "gui", "open", "zef_open_class_inverse.m"));
            testCase.verifyTrue(contains(src, "(class solver)"));
            testCase.verifyTrue(contains(src, "not the Inverse-tools plugin"));
        end

        function dtiInterpolationUiSaysTrilinear(testCase)
            src = fileread(fullfile("plugins", "DTIConductivityTool", ...
                "zef_dti_conductivity_window.m"));
            testCase.verifyTrue(contains(src, "'Trilinear'"));
            testCase.verifyFalse(contains(src, "'Radius Average'"));
        end
    end
end
