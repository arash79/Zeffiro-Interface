function [tree] = zef_dataBank_rebuildTreeSaveFile(tree)
% --- Zeffiro documentation header ---
% zef_dataBank_rebuildTreeSaveFile — Zef data Bank rebuild Tree Save File.
%
% Purpose:
%   Zef data Bank rebuild Tree Save File.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   tree
%
% Outputs:
%   tree
%
% Calls (project):
%   zef_dataBank_rebuildTreeSaveFile
%
% Side effects:
%   - filesystem I/O
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[tree] = zef_dataBank_rebuildTreeSaveFile(tree)` with project root and `src` on the path.
% --- End Zeffiro documentation header

hashes=fieldnames(tree);

if length(hashes)>=1
    folder=extractBefore(tree.(hashes{1}).data.Properties.Source, strcat(filesep, 'node_'));
    folder=strcat(folder, filesep);
end

for i=1:length(hashes)

    nameOfSaveFile=reverse(extractBetween(reverse(tree.(hashes{i}).data.Properties.Source),'.', filesep));
    nameOfSaveFile=nameOfSaveFile{1};

    if ~strcmp(hashes{i}, nameOfSaveFile)
        complNameOfSaveFile=tree.(hashes{i}).data.Properties.Source;
        complNameOfTMPSaveFile=strcat(folder, nameOfSaveFile, '_temporaryDataBankFile.mat');
        movefile(complNameOfSaveFile, complNameOfTMPSaveFile);

    end

end

for i=1:length(hashes)

    nameOfSaveFile=reverse(extractBetween(reverse(tree.(hashes{i}).data.Properties.Source),'.', filesep));
    nameOfSaveFile=nameOfSaveFile{1};

    if ~strcmp(hashes{i}, nameOfSaveFile)
        complNameOfSaveFile=strcat(folder, hashes{i}, '.mat') ;
        complNameOfTMPSaveFile=strcat(folder, nameOfSaveFile, '_temporaryDataBankFile.mat');
        movefile(complNameOfTMPSaveFile, complNameOfSaveFile);
        tree.(hashes{i}).data=matfile(complNameOfSaveFile);

    end

end

end
