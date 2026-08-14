%ZEF_UPDATE_EXP_EM  EXP EM widgets → zef.exp_em_* and zef.inv_* / number_of_frames.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. get/str2num on h_exp_em_q, hyper_type, beta, theta0, snr,
%   n_map/L1 iterations, band, times, normalize_data. Called before
%   exp_em_iteration. Siblings: zef_update_exp_ias / _em_multires /
%   _ias_multires.
%
%   See also zef_init_exp_em, exp_em_iteration.

zef.exp_em_q = get(zef.h_exp_em_q,'value');
zef.exp_em_hyper_type = get(zef.h_exp_em_hyper_type,'value');
zef.exp_em_beta = str2num(get(zef.h_exp_em_beta,'string'));
zef.exp_em_theta0 = str2num(get(zef.h_exp_em_theta0,'string'));
zef.inv_snr = str2num(get(zef.h_exp_em_snr,'string'));
zef.inv_n_map_iterations = str2num(get(zef.h_exp_em_n_map_iterations,'string'));
zef.inv_n_L1_iterations = str2num(get(zef.h_exp_em_n_L1_iterations,'string'));
%zef.inv_pcg_tol = str2num(get(zef.h_exp_em_pcg_tol,'string'));
zef.inv_sampling_frequency = str2num(get(zef.h_exp_em_sampling_frequency,'string'));
zef.inv_low_cut_frequency = str2num(get(zef.h_exp_em_low_cut_frequency,'string'));
zef.inv_high_cut_frequency = str2num(get(zef.h_exp_em_high_cut_frequency,'string'));
zef.inv_data_segment = str2num(get(zef.h_exp_em_data_segment,'string'));
zef.inv_time_1 = str2num(get(zef.h_exp_em_time_1,'string'));
zef.inv_time_2 = str2num(get(zef.h_exp_em_time_2,'string'));
zef.inv_time_3 = str2num(get(zef.h_exp_em_time_3,'string'));
zef.number_of_frames = str2num(get(zef.h_exp_em_number_of_frames,'string'));
zef.normalize_data = get(zef.h_exp_em_normalize_data ,'value');
