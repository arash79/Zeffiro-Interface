function [pos, label] = getElectrodePositions(data, OptionalNameforElectrodeFile, OptionalNameForLabelFile, OptionalSaveToFile0or1)
%GETELECTRODEPOSITIONS  Match data.label to data.elec and optionally write DAT.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [pos, label] = getElectrodePositions(data)
%   [pos, label] = getElectrodePositions(data, elecFile, labelFile, saveFlag)
%
%   data.label{i} must equal some data.elec.label{j}; pos(i,:) =
%   data.elec.chanpos(j,:). Defaults: save on, ./electrodes.dat (ascii)
%   and ./electrodesLabel.dat (writecell). Not Import → Import electrodes
%   (that uses core.io.electrodes.from_csv / from_dat).
%
%   See also getMagnetometerPositions.

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
