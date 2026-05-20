function [pos, label] = getElectrodePositions(data, OptionalNameforElectrodeFile, OptionalNameForLabelFile, OptionalSaveToFile0or1)
% --- Zeffiro documentation header ---
% getElectrodePositions — Get Electrode Positions.
%
% Purpose:
%   Get Electrode Positions.
%   Folder: Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.
%
% Inputs:
%   data
%   OptionalNameforElectrodeFile
%   OptionalNameForLabelFile
%   OptionalSaveToFile0or1
%
% Outputs:
%   pos
%   label
%
% Side effects:
%   - filesystem I/O
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[pos, label]] = getElectrodePositions(data, OptionalNameforElectrodeFile, OptionalNameForLabelFile, OptionalSaveToFile0or1)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin==3
    OptionalSaveToFile0or1=1;

end

if nargin==2
    OptionalNameForLabelFile='./electrodesLabel.dat';
    OptionalSaveToFile0or1=1;

end

if nargin==1
    OptionalSaveToFile0or1=1;
    OptionalNameForLabelFile='./electrodesLabel.dat';
    OptionalNameforElectrodeFile='./electrodes.dat';
end

pos=nan(length(data.label), 3);

for i=1:length(data.label)

    for j=i:length(data.elec.label) %the labels are sorted the same way, only that some will be missing in the data

        if strcmp(data.label{i}, data.elec.label{j})
            pos(i,:)=data.elec.chanpos(j,:);
            break;
        end

        if j==length(data.elec.label)&& ~strcmp(data.label{i}, data.elec.label{j})
            error('label not found'); %I think this cannot happen
        end
    end
end

if sum(isnan(pos))~=0
    error('some position was not found');
end

label=data.label;

if OptionalSaveToFile0or1
    save(OptionalNameforElectrodeFile, 'pos', '-ascii');
    writecell(label, OptionalNameForLabelFile);
end

end
