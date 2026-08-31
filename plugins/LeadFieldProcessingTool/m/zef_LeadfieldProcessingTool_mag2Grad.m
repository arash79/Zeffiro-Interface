%ZEF_LEADFIELDPROCESSINGTOOL_MAG2GRAD  Apply loaded tra to checked bank L (magnetometer→gradiometer).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Mag2GradButton. For each checked row: bank→auxData, L = tra*L,
%   sensors truncated to size(tra,1), imaging_method = 3, new lead_field_id
%   ('bank_apply'), then aux2bank_new (appends; does not overwrite).
%   Needs zef.LeadFieldProcessingTool.tra from loadTra.
%
%   See also zef_LeadfieldProcessingTool_loadTra.

for zef_LeadFieldProcessingTool_index=1:zef.LeadFieldProcessingTool.bankSize

    if zef.LeadFieldProcessingTool.app.BankTable.Data{zef_LeadFieldProcessingTool_index, 6}

        zef.LeadFieldProcessingTool.bank2auxIndex=zef_LeadFieldProcessingTool_index;

        zef_LeadfieldProcessingTool_bank2aux_bank2auxIndex;

        zef.LeadFieldProcessingTool.auxData.L = zef.LeadFieldProcessingTool.tra*zef.LeadFieldProcessingTool.auxData.L;
        zef.LeadFieldProcessingTool.auxData.sensors = zef.LeadFieldProcessingTool.auxData.sensors(1:size(zef.LeadFieldProcessingTool.tra,1),:);
        zef.LeadFieldProcessingTool.auxData.imaging_method = 3;

        [zef.lead_field_id,zef.lead_field_id_max] = zef_update_lead_field_id(zef.lead_field_id,zef.lead_field_id_max,'bank_apply');
        zef.LeadFieldProcessingTool.auxData.lead_field_id=zef.lead_field_id_max;
        zef_LeadFieldProcessingTool_aux2bank_new;

    end

end

zef.LeadFieldProcessingTool.auxData=[];

clear zef_LeadFieldProcessingTool_index;
