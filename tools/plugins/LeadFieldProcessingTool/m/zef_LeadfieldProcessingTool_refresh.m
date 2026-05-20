% --- Zeffiro documentation header ---
% zef.LeadFieldProcessingTool.app.currentLeadfield.Data={zef.lf_tag, zef.imaging_method_cell{zef.imaging_method}, size(zef.sensors, 1), size(zef.source_positions, 1), zef — Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
%
% Purpose:
%   Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.LeadFieldProcessingTool (read)
%   zef.lead_field_id (read)
%   zef.lead_field_id_max (read)
%
% Calls (project):
%   zef_update_lead_field_id
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef.LeadFieldProcessingTool.app.currentLeadfield.Data={zef.lf_tag, zef.imaging_method_cell{zef.imaging_method}, size(zef.sensors, 1), size(zef.source_positions, 1), zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef.LeadFieldProcessingTool.app.currentLeadfield.Data={zef.lf_tag, zef.imaging_method_cell{zef.imaging_method}, size(zef.sensors, 1), size(zef.source_positions, 1), zef.lead_field_id};

if zef.LeadFieldProcessingTool.bankSize>=1

    for zef_LeadfieldProcessingTool_startIndex=1:zef.LeadFieldProcessingTool.bankSize
        zef.LeadFieldProcessingTool.bankPosition=zef_LeadfieldProcessingTool_startIndex;

        if ~isfield(zef.LeadFieldProcessingTool.bank{zef_LeadfieldProcessingTool_startIndex}, 'lead_field_id')
            warning('old project data. IDs are set sequentially');
            [zef.lead_field_id,zef.lead_field_id_max] = zef_update_lead_field_id(zef.lead_field_id,zef.lead_field_id_max,'bank_oldData');
            zef.LeadFieldProcessingTool.bank{zef_LeadfieldProcessingTool_startIndex}.lead_field_id=zef.lead_field_id_max;
        end

        zef_LeadfieldProcessingTool_updateTable;
    end
    clear zef_LeadfieldProcessingTool_startIndex;
end
