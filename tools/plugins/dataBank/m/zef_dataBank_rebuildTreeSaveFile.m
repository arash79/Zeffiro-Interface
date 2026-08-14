function [tree] = zef_dataBank_rebuildTreeSaveFile(tree)
%ZEF_DATABANK_REBUILDTREESAVEFILE  Rename on-disk node .mat files after rebuildTree.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   When save2disk is 'On', node.data is a matfile whose Source path still
%   uses the old hash. After sort/rebuild the field names may no longer
%   match those files. Two-pass rename via *_temporaryDataBankFile.mat
%   avoids overwriting, then each .data is a new matfile(newhash.mat).
%   Folder is taken from the first node's Source (strip through filesep+'node_').
%
%   tree = zef_dataBank_rebuildTreeSaveFile(tree)
%
%   Inputs
%     tree  - rebuilt tree whose .data objects still point at old files.
%
%   Output
%     tree  - .data handles updated to the renamed files.
%
%   See also zef_dataBank_rebuildTree, zef_dataBank_saveTreeNodes.

% Tree hashes may no longer match save-file names. Rename old files to
% tmp names, then to the new hashes (avoids overwriting).
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
