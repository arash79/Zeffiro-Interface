classdef ClassInverseDialogTest < matlab.unittest.TestCase
%CLASSINVERSEDIALOGTEST  eLORETA / UKF-NMM dialogs expose method parameters.

    properties
        Figures = gobjects(0)
        HadZef = false
        OldZef = []
    end

    methods (TestMethodSetup)
        function stashZef(testCase)
            testCase.HadZef = evalin('base', 'exist(''zef'',''var'')') == 1;
            if testCase.HadZef
                testCase.OldZef = evalin('base', 'zef');
            end
            zef = struct();
            zef.inv_snr = 30;
            zef.number_of_frames = 1;
            zef.inv_sampling_frequency = 1025;
            zef.inv_low_cut_frequency = 7;
            zef.inv_high_cut_frequency = 9;
            zef.inv_time_1 = 0;
            zef.inv_time_2 = 0;
            zef.inv_time_3 = 0.001;
            zef.normalize_data = 1;
            zef.use_display = 0;
            assignin('base', 'zef', zef);
        end
    end

    methods (TestMethodTeardown)
        function cleanup(testCase)
            figs = testCase.Figures;
            for i = 1:numel(figs)
                if isgraphics(figs(i)) && isvalid(figs(i))
                    delete(figs(i));
                end
            end
            if testCase.HadZef
                assignin('base', 'zef', testCase.OldZef);
            else
                evalin('base', 'clear zef');
            end
        end
    end

    methods (Test)
        function eloretaDialogHasMethodControls(testCase)
            zef = evalin('base', 'zef');
            zef = zef_eloreta_window(zef);
            fig = zef.h_class_inverse_fig;
            testCase.Figures(end+1) = fig; %#ok<AGROW>
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_ui_root'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_n_max_iterations'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_convergence_tolerance'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_apply_average_reference'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_inv_snr'));
            testCase.verifyEmpty(findall(fig, 'Tag', 'zef_inv_noise_cov'));
        end

        function ukfnmmDialogHasMethodControls(testCase)
            zef = evalin('base', 'zef');
            zef = zef_ukfnmm_window(zef);
            fig = zef.h_class_inverse_fig;
            testCase.Figures(end+1) = fig; %#ok<AGROW>
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_number_of_corrclusters'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_alpha'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_smoother_type'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_evolution_prior_model'));
        end

        function pluginStartNamesResolve(testCase)
            testCase.verifyNotEmpty(which('zef_eloreta_start'));
            testCase.verifyNotEmpty(which('zef_ukfnmm_start'));
            testCase.verifyNotEmpty(which('zef_halpr_start'));
            testCase.verifyNotEmpty(which('zef_grouplasso_start'));
        end
    end
end
