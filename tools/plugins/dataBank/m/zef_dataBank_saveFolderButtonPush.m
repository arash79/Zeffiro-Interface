function zef = zef_dataBank_saveFolderButtonPush(zef)
% --- Zeffiro documentation header ---
% zef_dataBank_saveFolderButtonPush — Zef data Bank save Folder Button Push.
%
% Purpose:
%   Zef data Bank save Folder Button Push.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.dataBank (read)
%
% Calls (project):
%   zef_dataBank_saveFolderButtonPush
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: `[zef] = zef_dataBank_saveFolderButtonPush(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef')
end

zef.dataBank.folder=uigetdir('', 'select folder for the databank');
zef.dataBank.folder=strcat(zef.dataBank.folder, filesep);

zef.dataBank.folder(strfind(zef.dataBank.folder,'\'))='/'; %ubuntu system works in windows, but not vice versa
zef.dataBank.app.savetodiskSwitch.Enable=true;
zef.dataBank.app.DataFolder.Text=zef.dataBank.folder;

if nargout == 0
    assignin('base','zef',zef);
end

end
