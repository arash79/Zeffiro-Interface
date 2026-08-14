function zef = zef_dataBank_saveFolderButtonPush(zef)
%ZEF_DATABANK_SAVEFOLDERBUTTONPUSH  Choose the folder used when save-to-disk is On.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   selectfolderButton.ButtonPushedFcn in zef_open_dataBank. uigetdir with
%   title 'select folder for the databank', appends filesep, maps '\' to
%   '/', writes zef.dataBank.folder, sets DataFolder.Text, and enables
%   savetodiskSwitch. Does not save nodes until the switch turns On.
%
%   zef = zef_dataBank_saveFolderButtonPush(zef)
%
%   Inputs
%     zef  - session with dataBank.app. nargin==0 → base.
%
%   Output
%     zef  - folder and UI updated. nargout==0 → assignin base.
%
%   See also zef_dataBank_saveTreeNodeSwitchChange.

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
