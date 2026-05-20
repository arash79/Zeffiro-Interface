function [info,columnNames, hashList] = zef_databank_showAll(tree, type)
% --- Zeffiro documentation header ---
% zef_databank_showAll — Zef databank show All.
%
% Purpose:
%   Zef databank show All.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   tree
%   type
%
% Outputs:
%   info
%   columnNames
%   hashList
%
% Calls (project):
%   zef_databank_showAll
%   zef_size
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[info, columnNames, hashList]] = zef_databank_showAll(tree, type)` with project root and `src` on the path.
% --- End Zeffiro documentation header

info=cell(0,0);
columnNames=cell(0,0);

dbFieldNames=fieldnames(tree);
hashList=cell(0,0);

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
