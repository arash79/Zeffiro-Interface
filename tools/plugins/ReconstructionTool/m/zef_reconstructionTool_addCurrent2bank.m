% --- Zeffiro documentation header ---
% zef.reconstructionTool.bankSize=zef.reconstructionTool — Zef.reconstruction Tool.bank Size=zef.reconstruction Tool.
%
% Purpose:
%   Zef.reconstruction Tool.bank Size=zef.reconstruction Tool.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.reconstruction (read)
%   zef.reconstructionTool (read)
%   zef.reconstruction_information (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef.reconstructionTool.bankSize=zef.reconstructionTool` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef.reconstructionTool.bankSize=zef.reconstructionTool.bankSize+1;

zef.reconstructionTool.bankInfo(zef.reconstructionTool.bankSize, 1:6)=zef.reconstructionTool.currentInfo;

if iscell(zef.reconstruction)
    zef.reconstructionTool.bankReconstruction{zef.reconstructionTool.bankSize,1}.reconstruction=zef.reconstruction;
else
    zef.reconstructionTool.bankReconstruction{zef.reconstructionTool.bankSize,1}.reconstruction={zef.reconstruction};
end

zef.reconstructionTool.bankReconstruction{zef.reconstructionTool.bankSize,1}.reconstruction_information=zef.reconstruction_information;

if ~isfield(zef.reconstructionTool.bankReconstruction{zef.reconstructionTool.bankSize,1}.reconstruction_information, 'tag')
    zef.reconstructionTool.bankReconstruction{zef.reconstructionTool.bankSize,1}.reconstruction_information.tag=zef.reconstructionTool.currentInfo{1};
end

if ~isfield(zef.reconstructionTool.bankReconstruction{zef.reconstructionTool.bankSize,1}.reconstruction_information, 'lead_field_id')
    zef.reconstructionTool.bankReconstruction{zef.reconstructionTool.bankSize,1}.reconstruction_information.lead_field_id=zef.reconstructionTool.currentInfo{6};
end

zef.reconstructionTool.bankInfo{zef.reconstructionTool.bankSize,7}=false;

zef.reconstructionTool.app.BankTable.Data=zef.reconstructionTool.bankInfo;
