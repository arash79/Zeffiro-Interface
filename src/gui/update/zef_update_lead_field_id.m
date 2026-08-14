function [lead_field_id,lead_field_id_max] = zef_update_lead_field_id(lead_field_id,lead_field_id_max,varargin)
%ZEF_UPDATE_LEAD_FIELD_ID  Bump lead-field bank counters (no GUI widget).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Function. Third argument is the event string (default 'create'):
%     'create'        — id_max += 1; id = id_max (new lead field)
%     'bank_oldData'  — id_max += 1 (keep current id)
%     'bank_apply'    — id_max += 1 (keep current id)
%     'bank_add' / 'bank_replace' — no change
%   Otherwise errors. Does not plot or write zef; callers assign the
%   returned pair.
%
%   [id, id_max] = zef_update_lead_field_id(id, id_max)
%   [id, id_max] = zef_update_lead_field_id(id, id_max, 'create')
%
%   See also zef_lead_field_matrix.
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
