%ZEF_RECONSTRUCTIONTOOL_REPLACE  First checked bank row → live zef.reconstruction.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. replaceButton. max() on the column-7 logicals picks the first
%   true row. Copies that reconstruction onto zef.reconstruction before
%   the checkbox-clearing loop. The loop reuses the index name, so
%   reconstruction_information is then taken from the last bank row
%   (bankSize), not the checked row. Also copies inv_time_1/2/3 and
%   inv_sampling_frequency when all four fields exist. Clears every
%   checkbox. Does not invert.
%
%   See also zef_reconstructionTool_addCurrent2bank, zef_reconstructionTool_refresh.

[~, indexOfMinimumTrueElement]=max(cell2mat( zef.reconstructionTool.bankInfo(:,7)));

zef.reconstruction=zef.reconstructionTool.bankReconstruction{indexOfMinimumTrueElement,1}.reconstruction;

zef.reconstructionTool.currentInfo=zef.reconstructionTool.bankInfo(indexOfMinimumTrueElement,1:6);

%set every checkbox to false
for indexOfMinimumTrueElement=1:zef.reconstructionTool.bankSize
    zef.reconstructionTool.bankInfo{indexOfMinimumTrueElement,7}=false;
end

zef.reconstructionTool.app.BankTable.Data=zef.reconstructionTool.bankInfo;
zef.reconstructionTool.app.current.Data=zef.reconstructionTool.currentInfo;

% Loop reused the index name, so this is the last bank row (bankSize).
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
