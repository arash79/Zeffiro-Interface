function [lead_field_id,lead_field_id_max] = zef_update_lead_field_id(lead_field_id,lead_field_id_max,varargin)
% --- Zeffiro documentation header ---
% zef_update_lead_field_id — Syncs GUI control values into `zef` for lead_field_id.
%
% Purpose:
%   Syncs GUI control values into `zef` for lead_field_id.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   lead_field_id
%   lead_field_id_max
%   varargin
%
% Outputs:
%   lead_field_id
%   lead_field_id_max
%
% Calls (project):
%   zef_update_lead_field_id
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[lead_field_id, lead_field_id_max]] = zef_update_lead_field_id(lead_field_id, lead_field_id_max, varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header


lead_field_event = 'create'; %'' would be better, or lead_field_event instead of varargin
if not(isempty(varargin))
    lead_field_event = varargin{1};
end

switch lead_field_event

    case 'bank_replace'
        lead_field_id = lead_field_id;
        lead_field_id_max = lead_field_id_max;

    case 'bank_add'
        lead_field_id = lead_field_id;
        lead_field_id_max = lead_field_id_max;

    case 'bank_oldData'
        lead_field_id = lead_field_id;
        lead_field_id_max = lead_field_id_max+1;

    case 'bank_apply'
        lead_field_id = lead_field_id;
        lead_field_id_max = lead_field_id_max+1;

    case 'create'
        lead_field_id_max = lead_field_id_max + 1;
        lead_field_id = lead_field_id_max;

    otherwise
        error('event not specified');

end

end
