% --- Zeffiro documentation header ---
% [~, indexOfMinimumTrueElement]=max(cell2mat( zef.reconstructionTool — [~, index Of Minimum True Element]=max(cell2mat( zef.reconstruction Tool.
%
% Purpose:
%   [~, index Of Minimum True Element]=max(cell2mat( zef.reconstruction Tool.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.inv_sampling_frequency (read, write)
%   zef.inv_time_1 (read, write)
%   zef.inv_time_2 (read, write)
%   zef.inv_time_3 (read, write)
%   zef.reconstruction (read, write)
%   zef.reconstructionTool (read)
%   zef.reconstruction_information (read, write)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `[~, indexOfMinimumTrueElement]=max(cell2mat( zef.reconstructionTool` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

[~, indexOfMinimumTrueElement]=max(cell2mat( zef.reconstructionTool.bankInfo(:,7)));

zef.reconstruction=zef.reconstructionTool.bankReconstruction{indexOfMinimumTrueElement,1}.reconstruction;

zef.reconstructionTool.currentInfo=zef.reconstructionTool.bankInfo(indexOfMinimumTrueElement,1:6);

%set every checkbox to false
for indexOfMinimumTrueElement=1:zef.reconstructionTool.bankSize
    zef.reconstructionTool.bankInfo{indexOfMinimumTrueElement,7}=false;
end

zef.reconstructionTool.app.BankTable.Data=zef.reconstructionTool.bankInfo;
zef.reconstructionTool.app.current.Data=zef.reconstructionTool.currentInfo;

zef.reconstruction_information=zef.reconstructionTool.bankReconstruction{indexOfMinimumTrueElement,1}.reconstruction_information;

clear indexOfMinimumTrueElement;

%% copy the information to the zef file

if isfield(zef.reconstruction_information, 'inv_time_1') && isfield(zef.reconstruction_information, 'inv_time_2') ...
        && isfield(zef.reconstruction_information, 'inv_time_3') && isfield(zef.reconstruction_information, 'inv_sampling_frequency')
    zef.inv_time_1=zef.reconstruction_information.inv_time_1;
    zef.inv_time_2=zef.reconstruction_information.inv_time_2;
    zef.inv_time_3=zef.reconstruction_information.inv_time_3;
    zef.inv_sampling_frequency=zef.reconstruction_information.inv_sampling_frequency;

end
