%LEADFIELDPROCESSINGTOOL_START  Open Multi tools → LeadFieldProcessingTool.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Default-profile menu callback (script). Bank:
%   zef.LeadFieldProcessingTool.bank. Add snapshots live L; Replace copies
%   a checked row onto zef; Combine noise-weights then vertcat.
%
%   See also zef_LeadFieldProcessingTool_addCurrentData2bank,
%   zef_LeadfieldProcessingTool_combine.
%

zef.LeadFieldProcessingTool.app = LeadFieldProcessingTool_app;

%set initial values

if ~isfield(zef.LeadFieldProcessingTool, 'bank')
    zef.LeadFieldProcessingTool.bank=[];
end

zef.LeadFieldProcessingTool.bankSize=size(zef.LeadFieldProcessingTool.bank,2);

if ~isfield(zef, 'lf_tag')
    zef.lf_tag='';
end

zef_LeadfieldProcessingTool_refresh;

%app functions
zef.LeadFieldProcessingTool.app.AddButton.ButtonPushedFcn='zef_LeadFieldProcessingTool_addCurrentData2bank';
zef.LeadFieldProcessingTool.app.loadTraButton.ButtonPushedFcn='zef_LeadfieldProcessingTool_loadTra';
zef.LeadFieldProcessingTool.app.Mag2GradButton.ButtonPushedFcn='zef_LeadfieldProcessingTool_mag2Grad';
zef.LeadFieldProcessingTool.app.replaceButton.ButtonPushedFcn='zef_LeadfieldProcessingTool_aux2current';

zef.LeadFieldProcessingTool.app.deleteButton.ButtonPushedFcn='zef_LeadfieldProcessingTool_delete';
zef.LeadFieldProcessingTool.app.CombineButton.ButtonPushedFcn='zef_LeadfieldProcessingTool_combine';
zef.LeadFieldProcessingTool.app.refreshButton.ButtonPushedFcn='zef_LeadfieldProcessingTool_refresh';

zef.LeadFieldProcessingTool.app.BankTable.CellEditCallback='zef_LeadfieldProcessingTool_BankTableLabelUpdate';

try
    zef_ui_adopt_app(zef.LeadFieldProcessingTool.app.UIFigure, ...
        'ZEFFIRO Interface: Lead Field Processing Tool');
    zef_ui_fit_table(findall(zef.LeadFieldProcessingTool.app.UIFigure, 'Type', 'uitable'));
catch
end

