% --- Zeffiro documentation header ---
% zef.LeadFieldProcessingTool.auxData.source_interpolation_ind = zef — Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
%
% Purpose:
%   Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.L (read)
%   zef.LeadFieldProcessingTool (read)
%   zef.compartment_tags (read)
%   zef.imaging_method (read)
%   zef.imaging_method_cell (read)
%   zef.lf_bank_scaling_factor (read)
%   zef.lf_tag (read)
%   zef.measurements (read)
%   zef.noise_data (read)
%   zef.parcellation_interp_ind (read)
%   zef.sensors (read)
%   zef.source_directions (read)
%   zef.source_positions (read)
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef.LeadFieldProcessingTool.auxData.source_interpolation_ind = zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef.LeadFieldProcessingTool.auxData.source_interpolation_ind = zef.source_interpolation_ind;
zef.LeadFieldProcessingTool.auxData.parcellation_interp_ind = zef.parcellation_interp_ind;
zef.LeadFieldProcessingTool.auxData.source_positions = zef.source_positions;
zef.LeadFieldProcessingTool.auxData.source_directions = zef.source_directions;
zef.LeadFieldProcessingTool.auxData.L = zef.L;
zef.LeadFieldProcessingTool.auxData.sensors = zef.sensors;
zef.LeadFieldProcessingTool.auxData.imaging_method = zef.imaging_method_cell{zef.imaging_method};
zef.LeadFieldProcessingTool.auxData.measurements = zef.measurements;
zef.LeadFieldProcessingTool.auxData.noise_data = zef.noise_data;
zef.LeadFieldProcessingTool.auxData.scaling_factor = zef.lf_bank_scaling_factor;
zef.LeadFieldProcessingTool.auxData.lf_tag = zef.lf_tag;

zef.LeadFieldProcessingTool.auxData.source_structure = cell(0,0);

for zef_ind=1:length(zef.compartment_tags)

    zef_name=strcat(zef.compartment_tags{zef_ind}, '_sources');

    zef.LeadFieldProcessingTool.auxData.source_structure{zef_ind}=zef.(zef_name);
    %evalin('base', ['zef.' zef.compartment_tags{zef_ind} '_sources']);

end

zef_LeadFieldProcessingTool_aux2bank; %aux data is deleted in aux2bank
