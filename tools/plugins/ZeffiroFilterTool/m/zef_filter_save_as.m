%ZEF_FILTER_SAVE_AS  Save as: filter pipeline, raw_data, zoom, epoch points.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. ButtonPushedFcn of h_filter_save_as. uiputfile '*.mat'.
%   Writes zef_data with filter_zoom, raw_data, epoch points, name/file/
%   parameter lists, sampling_rate, tag, data_segment, pipeline cells
%   (-v7.3). As written, zef_data.filter_file_list is assigned from
%   zef.filter_name_list (not filter_file_list). Does not save
%   processed_data (that is zef_filter_save_processed_data_as).
%
%   See also zef_filter_load, zef_filter_save_processed_data_as.

if not(isempty(zef.save_file_path)) & not(zef.save_file_path==0)
    [zef.file zef.file_path] = uiputfile('*.mat','Save as...',[zef.filter_save_file_path zef.filter_save_file]);
else
    [zef.file zef.file_path] = uiputfile('*.mat','Save as...');
end
if not(isequal(zef.file,0));

    zef.filter_save_file_path = zef.file_path;
    zef.filter_save_file = zef.file;
    zef_data.filter_zoom = zef.filter_zoom;
    zef_data.raw_data = zef.raw_data;
    zef_data.filter_epoch_points =  zef.filter_epoch_points;
    zef_data.filter_name_list = zef.filter_name_list;
    zef_data.filter_file_list = zef.filter_name_list;
    zef_data.filter_parameter_list = zef.filter_parameter_list;
    zef_data.filter_list_selected = zef.filter_list_selected;
    zef_data.filter_sampling_rate = zef.filter_sampling_rate ;
    zef_data.filter_tag = zef.filter_tag ;
    zef_data.filter_data_segment = zef.filter_data_segment;
    zef_data.filter_pipeline = zef.filter_pipeline;
    zef_data.filter_pipeline_list = zef.filter_pipeline_list;
    zef_data.filter_pipeline_selected = zef.filter_pipeline_selected;

    save([zef.file_path zef.file],'zef_data','-v7.3');
    clear zef_data;

end
