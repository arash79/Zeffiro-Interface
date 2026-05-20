%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% set(zef — Set(zef.
%
% Purpose:
%   Set(zef.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.filter_data_segment (read, write)
%   zef.filter_pipeline (read)
%   zef.filter_pipeline_list (read, write)
%   zef.filter_pipeline_selected (read, write)
%   zef.filter_sampling_rate (read, write)
%   zef.filter_tag (read, write)
%   zef.filter_zoom (read, write)
%   zef.h_filter_data_segment (read)
%   zef.h_filter_parameter_list (read)
%   zef.h_filter_pipeline_list (read)
%   zef.h_filter_sampling_rate (read)
%   zef.h_filter_tag (read)
%   zef.h_filter_zoom (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `set(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header



set(zef.h_filter_pipeline_list,'Value',cell(0),'Items',cell(0),'Multiselect','on');
zef.filter_pipeline_list = cell(0);

for zef_i = 1 : length(zef.filter_pipeline)
    zef.filter_pipeline_list{zef_i} = ['Tag: ' zef.filter_pipeline{zef_i}.filter_tag  ', Type: ' zef.filter_pipeline{zef_i}.name ];
end

if isempty(zef.filter_pipeline)
    set(zef.h_filter_parameter_list,'data',cell(0));
else
    if isempty(zef.filter_pipeline_selected)
        zef.filter_pipeline_selected = 1;
    end
    set(zef.h_filter_parameter_list,'data',zef.filter_pipeline{zef.filter_pipeline_selected(1)}.parameters);
end
if isempty(zef.filter_pipeline_list)
    set(zef.h_filter_pipeline_list,'Items',cell(0),'ItemsData',1,'Value',cell(0),'Multiselect','on');
else
    set(zef.h_filter_pipeline_list,'Items',zef.filter_pipeline_list,'ItemsData',[1:length(zef.filter_pipeline_list)],'Value',zef.filter_pipeline_selected,'Multiselect','on');
end

clear zef_i;

zef.filter_tag = get(zef.h_filter_tag,'value');
zef.filter_data_segment = str2num(get(zef.h_filter_data_segment,'value'));
zef.filter_sampling_rate = str2num(get(zef.h_filter_sampling_rate,'value'));
zef.filter_zoom = 100/str2num(get(zef.h_filter_zoom,'value'));

zef.filter_pipeline_selected = sort(zef.filter_pipeline_selected);
