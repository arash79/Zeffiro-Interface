%ZEF_UPDATE_IAS_ROI  IAS ROI widgets → zef.iasroi_* and zef.inv_time_*/snr.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Apply / Start / plot-source. roi_mode 1 packs the four
%   sphere edits. Also rec_source columns 8–9. Does not invert.
%
%   See also zef_init_ias_roi, ias_map_estimation_roi.

zef.iasroi_roi_mode = get(zef.h_iasroi_roi_mode ,'value');
if zef.iasroi_roi_mode == 1
    zef.iasroi_roi_sphere = str2num(get(zef.h_iasroi_roi_sphere_1 ,'string'));
    zef.iasroi_roi_sphere = zef.iasroi_roi_sphere(:);
    zef.iasroi_roi_sphere = [ zef.iasroi_roi_sphere ...
        reshape(str2num(get(zef.h_iasroi_roi_sphere_2 ,'string')),size(zef.iasroi_roi_sphere,1),1)...
        reshape(str2num(get(zef.h_iasroi_roi_sphere_3 ,'string')),size(zef.iasroi_roi_sphere,1),1)...
        reshape(str2num(get(zef.h_iasroi_roi_sphere_4 ,'string')),size(zef.iasroi_roi_sphere,1),1)...
        ];
end
zef.iasroi_roi_threshold = str2num(get(zef.h_iasroi_roi_threshold ,'string'));
zef.iasroi_hyperprior = get(zef.h_iasroi_hyperprior ,'value');
zef.iasroi_snr = str2num(get(zef.h_iasroi_snr,'string'));
zef.iasroi_n_map_iterations = str2num(get(zef.h_iasroi_n_map_iterations,'string'));
zef.iasroi_sampling_frequency = str2num(get(zef.h_iasroi_sampling_frequency,'string'));
zef.iasroi_low_cut_frequency = str2num(get(zef.h_iasroi_low_cut_frequency,'string'));
zef.iasroi_high_cut_frequency = str2num(get(zef.h_iasroi_high_cut_frequency,'string'));
zef.iasroi_time_1 = str2num(get(zef.h_iasroi_time_1,'string'));
zef.iasroi_time_2 = str2num(get(zef.h_iasroi_time_2,'string'));
zef.iasroi_time_3 = str2num(get(zef.h_iasroi_time_3,'string'));
zef.iasroi_number_of_frames = str2num(get(zef.h_iasroi_number_of_frames,'string'));
zef.iasroi_normalize_data = get(zef.h_iasroi_normalize_data ,'value');
zef.inv_time_1 = str2num(get(zef.h_iasroi_time_1,'string'));
zef.inv_time_2 = str2num(get(zef.h_iasroi_time_2,'string'));
zef.inv_time_3 = str2num(get(zef.h_iasroi_time_3,'string'));
zef.inv_sampling_frequency = str2num(get(zef.h_iasroi_sampling_frequency,'string'));
zef.inv_low_cut_frequency = str2num(get(zef.h_iasroi_low_cut_frequency,'string'));
zef.inv_high_cut_frequency = str2num(get(zef.h_iasroi_high_cut_frequency,'string'));
zef.number_of_frames = str2num(get(zef.h_iasroi_number_of_frames,'string'));
zef.inv_snr = zef.iasroi_snr;

if not(size(zef.iasroi_rec_source,1) == size(zef.iasroi_roi_sphere,1))
    zef.iasroi_rec_source = zeros(size(zef.iasroi_roi_sphere,1),9);
end
zef.iasroi_rec_source(:,8) = str2num(get(zef.h_iasroi_rec_source_8,'string'));
zef.iasroi_rec_source(:,9) = get(zef.h_iasroi_rec_source_9,'value');
