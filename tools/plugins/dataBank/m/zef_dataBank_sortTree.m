function [tree, newText] = zef_dataBank_sortTree(tree)
% --- Zeffiro documentation header ---
% zef_dataBank_sortTree — Zef data Bank sort Tree.
%
% Purpose:
%   Zef data Bank sort Tree.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   tree
%
% Outputs:
%   tree
%   newText
%
% Calls (project):
%   zef_dataBank_number2hash
%   zef_dataBank_sortTree
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[tree, newText]] = zef_dataBank_sortTree(tree)` with project root and `src` on the path.
% --- End Zeffiro documentation header

if isstruct(tree)
    text=fieldnames(tree);
else
    text=properties(tree);

    for i=1:length(text)
        if strcmp(text{i}, 'Properties')
            text(i)=[];
            break;
        end
    end
end

R2=(regexp(text, '(?<num>\d+)', 'names'));

m=1;

for i=1:length(R2)
    m=max(m, length(R2{i}));
end

tmp=[];
for i=1:length(R2)
    for j=1:m

        if j<=length(R2{i})
            tmp(i,j)=str2double(R2{i}(j).num);
        else
            tmp(i,j)=0;
        end

    end
end
tmp=sortrows(tmp);
newText=[];
for i=1:length(tmp)
    newText{i,1}=zef_dataBank_number2hash(tmp(i,:));
end

if isstruct(tree)
    tree=orderfields(tree, newText);
end

end
