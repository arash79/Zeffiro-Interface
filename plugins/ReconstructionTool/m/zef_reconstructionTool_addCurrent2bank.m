%ZEF_RECONSTRUCTIONTOOL_ADDCURRENT2BANK  Snapshot live reconstruction into the bank.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. AddButton. Increments bankSize, copies currentInfo into
%   bankInfo columns 1:6, stores reconstruction (wrapping a non-cell as
%   {rec}) plus reconstruction_information, and sets checkbox column 7
%   false. Fills .tag / .lead_field_id on reconstruction_information when
%   missing, from currentInfo{1} and {6}. Writes BankTable.Data. Does not
%   change live zef.reconstruction.
%
%   See also zef_reconstructionTool_replace, zef_reconstructionTool_refresh.

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
