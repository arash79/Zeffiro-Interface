% --- Zeffiro documentation header ---
% zef.reconstructionTool.bankReconstruction = zef.reconstructionTool.bankReconstruction(~cell2mat( zef.reconstructionTool — Zef.reconstruction Tool.bank Reconstruction = zef.reconstruction Tool.bank Reconstruction(~cell2mat( zef.reconstruction Tool.
%
% Purpose:
%   Zef.reconstruction Tool.bank Reconstruction = zef.reconstruction Tool.bank Reconstruction(~cell2mat( zef.reconstruction Tool.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.reconstructionTool (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef.reconstructionTool.bankReconstruction = zef.reconstructionTool.bankReconstruction(~cell2mat( zef.reconstructionTool` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef.reconstructionTool.bankReconstruction = zef.reconstructionTool.bankReconstruction(~cell2mat( zef.reconstructionTool.bankInfo(:,7)), :);
zef.reconstructionTool.bankInfo=zef.reconstructionTool.bankInfo(~cell2mat( zef.reconstructionTool.bankInfo(:,7)),:);

zef.reconstructionTool.bankSize=size(zef.reconstructionTool.bankInfo,1);

zef.reconstructionTool.app.BankTable.Data=zef.reconstructionTool.bankInfo;
