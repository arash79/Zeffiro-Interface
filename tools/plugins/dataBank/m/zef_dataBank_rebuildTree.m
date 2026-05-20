function [newtree] = zef_dataBank_rebuildTree(tree)
% --- Zeffiro documentation header ---
% zef_dataBank_rebuildTree — Zef data Bank rebuild Tree.
%
% Purpose:
%   Zef data Bank rebuild Tree.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   tree
%
% Outputs:
%   newtree
%
% Calls (project):
%   zef_dataBank_number2hash
%   zef_dataBank_rebuildTree
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[newtree] = zef_dataBank_rebuildTree(tree)` with project root and `src` on the path.
% --- End Zeffiro documentation header

hashes=fieldnames(tree);
newtree=struct;

% list=cell(length(hashes));

if ~isempty(hashes)

    newtree.(zef_dataBank_number2hash(1))=tree.(hashes{1});
    newtree.(zef_dataBank_number2hash(1)).hash=zef_dataBank_number2hash(1);

    index=1;
    for i=2:length(hashes)
        num=(regexp(hashes{i}, '(?<num>\d+)'));

        if length(num)==length(index)
            index(end)=index(end)+1;

        else
            if length(num)<length(index)
                index=index(1:length(num));
                index(end)=index(end)+1;

            else
                index(end+1)=1;
            end
        end
        %node=tree.(hashes{i}); %this is needed for the matfile
        %node.hash=zef_dataBank_number2hash(index);
        % newtree.(zef_dataBank_number2hash(index))=node;

        newtree.(zef_dataBank_number2hash(index))=tree.(hashes{i});
        newtree.(zef_dataBank_number2hash(index)).hash=zef_dataBank_number2hash(index);

    end

end

end
