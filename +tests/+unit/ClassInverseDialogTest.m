classdef ClassInverseDialogTest < matlab.unittest.TestCase
%CLASSINVERSEDIALOGTEST  Class-solver parameter dialogs expose method controls.

    properties
        Figures = gobjects(0)
        HadZef = false
        OldZef = []
        HadBaseZef = false
        OldBaseZef = []
    end

    methods (TestClassSetup)
        function setupPath(testCase)
            testCase.HadBaseZef = evalin('base', 'exist(''zef'',''var'')') == 1;
            if testCase.HadBaseZef
                testCase.OldBaseZef = evalin('base', 'zef');
            end
            zeffiro_interface('start_mode', 'nodisplay', 'zeffiro_restart', true);
        end
    end

    methods (TestClassTeardown)
        function restoreBaseZef(testCase)
            if testCase.HadBaseZef
                assignin('base', 'zef', testCase.OldBaseZef);
            else
                evalin('base', 'clear zef');
            end
        end
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

        function mneDialogHasMethodControls(testCase)
            zef = evalin('base', 'zef');
            zef = zef_mne_class_window(zef);
            fig = zef.h_class_inverse_fig;
            testCase.Figures(end+1) = fig; %#ok<AGROW>
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_ui_root'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_initial_prior_steering_db'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_inv_snr'));
        end

        function iasDialogHasMethodControls(testCase)
            zef = evalin('base', 'zef');
            zef = zef_ias_class_window(zef);
            fig = zef.h_class_inverse_fig;
            testCase.Figures(end+1) = fig; %#ok<AGROW>
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_ui_root'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_method_type'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_hyperprior'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_hyperprior_mode'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_n_map_iterations'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_hyperprior_tail_length_db'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_hyperprior_weight'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_amplitude_db'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_prior_over_measurement_db'));
        end

        function ramusDialogHasMethodControls(testCase)
            zef = evalin('base', 'zef');
            zef = zef_ramus_class_window(zef);
            fig = zef.h_class_inverse_fig;
            testCase.Figures(end+1) = fig; %#ok<AGROW>
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_ui_root'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_method_type'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_hyperprior'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_hyperprior_mode'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_n_map_iterations'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_number_of_multiresolution_levels'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_sparsity_factor'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_number_of_decompositions'));
        end

        function csmDialogHasMethodControls(testCase)
            zef = evalin('base', 'zef');
            zef = zef_csm_class_window(zef);
            fig = zef.h_class_inverse_fig;
            testCase.Figures(end+1) = fig; %#ok<AGROW>
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_ui_root'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_method_type'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_SBL_number_of_iterations'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_theta0'));
        end

        function kalmanDialogHasMethodControls(testCase)
            zef = evalin('base', 'zef');
            zef = zef_kalman_class_window(zef);
            fig = zef.h_class_inverse_fig;
            testCase.Figures(end+1) = fig; %#ok<AGROW>
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_ui_root'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_method_type'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_evolution_prior_model'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_number_of_ensembles'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_use_smoothing'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_smoother_type'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_standardization_exponent'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_evolution_prior_db'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_initial_prior_steering_db'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_number_of_noise_steps'));
        end

        function beamformerDialogHasMethodControls(testCase)
            zef = evalin('base', 'zef');
            zef = zef_beamformer_class_window(zef);
            fig = zef.h_class_inverse_fig;
            testCase.Figures(end+1) = fig; %#ok<AGROW>
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_ui_root'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_method_type'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_cov_reg_parameter'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_leadfield_reg_parameter'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_leadfield_reg_type'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_leadfield_normalization'));
        end

        function dipolescanDialogHasMethodControls(testCase)
            zef = evalin('base', 'zef');
            zef = zef_dipolescan_class_window(zef);
            fig = zef.h_class_inverse_fig;
            testCase.Figures(end+1) = fig; %#ok<AGROW>
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_ui_root'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_method_type'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_reg_type'));
            testCase.verifyNotEmpty(findall(fig, 'Tag', 'zef_inv_reg_parameter'));
        end

        function pluginStartNamesResolve(testCase)
            testCase.verifyNotEmpty(which('zef_eloreta_start'));
            testCase.verifyNotEmpty(which('zef_ukfnmm_start'));
            testCase.verifyNotEmpty(which('zef_halpr_start'));
            testCase.verifyNotEmpty(which('zef_grouplasso_start'));
            testCase.verifyNotEmpty(which('zef_mne_class_start'));
            testCase.verifyNotEmpty(which('zef_ias_class_start'));
            testCase.verifyNotEmpty(which('zef_ramus_class_start'));
            testCase.verifyNotEmpty(which('zef_csm_class_start'));
            testCase.verifyNotEmpty(which('zef_kalman_class_start'));
            testCase.verifyNotEmpty(which('zef_beamformer_class_start'));
            testCase.verifyNotEmpty(which('zef_dipolescan_class_start'));
        end
    end
end
