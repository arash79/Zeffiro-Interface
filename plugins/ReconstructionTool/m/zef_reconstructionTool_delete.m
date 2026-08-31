%ZEF_RECONSTRUCTIONTOOL_DELETE  Drop bank rows whose column-7 checkbox is true.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. deleteButton. Keeps bankReconstruction and bankInfo rows
%   where column 7 is false; sets bankSize and BankTable.Data. Does not
%   change live zef.reconstruction.
%
%   See also zef_reconstructionTool_addCurrent2bank.

zef.reconstructionTool.bankReconstruction = zef.reconstructionTool.bankReconstruction(~cell2mat( zef.reconstructionTool.bankInfo(:,7)), :);
zef.reconstructionTool.bankInfo=zef.reconstructionTool.bankInfo(~cell2mat( zef.reconstructionTool.bankInfo(:,7)),:);

zef.reconstructionTool.bankSize=size(zef.reconstructionTool.bankInfo,1);

zef.reconstructionTool.app.BankTable.Data=zef.reconstructionTool.bankInfo;
