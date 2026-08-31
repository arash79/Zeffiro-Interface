function [info,columnNames, hashList] = zef_databank_showAll(tree, type)
%ZEF_DATABANK_SHOWALL  Fill DataTable from every tree node of the selected type.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   showButton.ButtonPushedFcn and Entrytype.ValueChangedFcn in
%   zef_open_dataBank. Filename is zef_databank_showAll.m (lowercase b).
%   Collects hashes whose .type equals type, then size/tag columns:
%     leadfield       - imaging_method, size(L)
%     data            - size(measurements)
%     reconstruction  - tag, type, size(reconstruction)
%     gmm             - empty columns
%   Other types (noisedata, custom, import) leave info empty. hashList is
%   stored as zef.dataBank.DataTableHashList for table context menus.
%
%   [info, columnNames, hashList] = zef_databank_showAll(tree, type)
%
%   Inputs
%     tree  - zef.dataBank.tree (or a dummy one-node tree from showCurrent).
%     type  - char Entrytype.Value.
%
%   Output
%     info         - n-by-k cell for the table Data.
%     columnNames  - cellstr of headers (type-dependent).
%     hashList     - 1-by-n cell of matching hashes.
%
%   See also zef_dataBank_showCurrent, zef_size.

info=cell(0,0);
columnNames=cell(0,0);

dbFieldNames=fieldnames(tree);
hashList=cell(0,0);

%get all hashes of type nodes
% this will add a tiny bit of runtime, but makes the funtion more readable
for i=1:length(dbFieldNames)
    if strcmp(tree.(dbFieldNames{i}).type, type)
        hashList{end+1}=dbFieldNames{i};
    end
end

for i=1:length(hashList)

    switch type

        case 'leadfield'
            info{i,1}=tree.(hashList{i}).data.imaging_method;
            [info{i, 2}, info{i, 3}]=zef_size(tree.(hashList{i}).data, 'L');

        case 'data'
            [info{i, 1}, info{i, 2}]=zef_size(tree.(hashList{i}).data, 'measurements');

        case 'reconstruction'
            reconstruction_information=tree.(hashList{i}).data.reconstruction_information;

            info{i,1}=reconstruction_information.tag;
            if isfield(reconstruction_information, 'type')
                info{i,2}=reconstruction_information.type;
            else
                info{i,2}='';
            end
            [info{i, 3}, info{i, 4}]=zef_size(tree.(hashList{i}).data, 'reconstruction');

        case 'gmm'

    end

end

%set columnNames

switch type

    case 'leadfield'
        columnNames={'type', 'sensors', 'sources'};

    case 'data'
        columnNames={'sensors', 'samples'};

    case 'reconstruction'
        columnNames={'tag', 'type', 'samples', 'sources'};

    case 'gmm'

end
