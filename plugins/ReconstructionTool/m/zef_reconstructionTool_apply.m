%ZEF_RECONSTRUCTIONTOOL_APPLY  Run dropdown transform on checked bank rows.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. ApplytransformationButton. For each bankInfo column-7 true
%   row, calls str2func('zef_reconstructionTool_' + FunctionDropDown) on
%   that reconstruction and appends a new bank row (does not overwrite
%   the source). Copies reconstruction_information, sets
%   .appliedFunction, and suffixes the tag and bankInfo name with the
%   dropdown value. New-row column 4 is size(newRec,1). Columns 5 and 6
%   are written onto the source row (index), not the new row.
%
%   The function handle is kept for every checked row. Shipped dropdown
%   items: mean, power (m/apply_functions/). New-row columns 4–6 describe
%   the appended reconstruction.
%
%   See also zef_reconstructionTool_mean, zef_reconstructionTool_power.

trueDex=cell2mat( zef.reconstructionTool.bankInfo(:,7));

zef_reconstructionTool_function=str2func(strcat('zef_reconstructionTool_', zef.reconstructionTool.app.FunctionDropDown.Value));

for index=1:zef.reconstructionTool.bankSize
    if trueDex(index)

        newRec=zef_reconstructionTool_function(zef.reconstructionTool.bankReconstruction{index}.reconstruction);

        %all functions should give out a cell!

        %why did I do it like that? make new auxdata and add it

        zef.reconstructionTool.bankSize=zef.reconstructionTool.bankSize+1;
        zef.reconstructionTool.bankReconstruction{zef.reconstructionTool.bankSize,1}.reconstruction=newRec;
        zef.reconstructionTool.bankReconstruction{zef.reconstructionTool.bankSize,1}.reconstruction_information=zef.reconstructionTool.bankReconstruction{index,1}.reconstruction_information;
        zef.reconstructionTool.bankReconstruction{zef.reconstructionTool.bankSize,1}.reconstruction_information.appliedFunction=zef.reconstructionTool.app.FunctionDropDown.Value;
        zef.reconstructionTool.bankReconstruction{zef.reconstructionTool.bankSize,1}.reconstruction_information.tag = ...
            strcat(zef.reconstructionTool.bankReconstruction{zef.reconstructionTool.bankSize,1}.reconstruction_information.tag, zef.reconstructionTool.app.FunctionDropDown.Value);

        zef.reconstructionTool.bankInfo(zef.reconstructionTool.bankSize,:)=zef.reconstructionTool.bankInfo(index,:);
        zef.reconstructionTool.bankInfo{zef.reconstructionTool.bankSize, 1}=strcat(zef.reconstructionTool.bankInfo{index, 1},'_', zef.reconstructionTool.app.FunctionDropDown.Value);

        zef.reconstructionTool.bankInfo{zef.reconstructionTool.bankSize, 4}=size(zef.reconstructionTool.bankReconstruction{zef.reconstructionTool.bankSize}.reconstruction, 1);
        zef.reconstructionTool.bankInfo{zef.reconstructionTool.bankSize, 5}=size(zef.reconstructionTool.bankReconstruction{zef.reconstructionTool.bankSize}.reconstruction{1}, 1);
        zef.reconstructionTool.bankInfo{zef.reconstructionTool.bankSize, 6}= zef.reconstructionTool.bankReconstruction{zef.reconstructionTool.bankSize,1}.reconstruction_information.lead_field_id;

    end

    %zef.reconstructionTool.bankInfo{index,6}=false;
end

zef.reconstructionTool.app.BankTable.Data=zef.reconstructionTool.bankInfo;

clear index trueDex newRec nextRec zef_reconstructionTool_function
