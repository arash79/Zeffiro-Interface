function save_color_tables(in_dir, out_dir)
% --- Zeffiro documentation header ---
% utilities.fs2zef.generators.save_color_tables — Save color tables.
%
% Purpose:
%   Save color tables.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   in_dir
%   out_dir
%
% Outputs:
%   See function signature and code below.
%
% Calls (project):
%   utilities.fs2zef.generators.save_color_tables
%
% Side effects:
%   - filesystem I/O
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `utilities.fs2zef.generators.save_color_tables(in_dir, out_dir)` with project root and `src` on the path.
% --- End Zeffiro documentation header

%
% save_color_tables
%
% Extracts color tables from FreeSurfer annotation files and saves them as
% MATLAB .mat files for use in Zeffiro Interface. The color tables contain
% mapping information between cortical parcellation labels and their visual
% representations.
%
% This function processes annotation files for both hemispheres and two
% parcellation schemes:
%   - 76 labels: Destrieux parcellation (aparc.a2009s)
%   - 36 labels: Desikan-Killiany parcellation (aparc)
%
% Inputs:
%
% - in_dir (1,1) string { mustBeFolder }
%
%   The FreeSurfer recon-all output directory containing the 'label' subdirectory
%   with annotation files (.annot).
%
% - out_dir (1,1) string { mustBeFolder }
%
%   The output directory where the color table .mat files will be saved.
%
% Outputs:
%
%   None. The function saves four .mat files:
%   - color_table_lh_76.mat, color_table_rh_76.mat (76-label parcellation)
%   - color_table_lh_36.mat, color_table_rh_36.mat (36-label parcellation)
%
%   Each file contains:
%   - colortable: Structure with parcellation color information
%   - label: Vector of annotation labels for each vertex
%   - vertices: Vertex indices (0-indexed)
%

    arguments

        in_dir (1,1) string { mustBeFolder }

        out_dir (1,1) string { mustBeFolder }

    end

    % Normalize the input directory path
    in_dir = fullfile(in_dir);

    % Extract and save left hemisphere 76-label parcellation color table
    [vertices, label, colortable] = read_annotation(fullfile(in_dir, 'label', 'lh.aparc.a2009s.annot'));
    save(fullfile(out_dir, 'color_table_lh_76.mat'), 'colortable', 'label', 'vertices');

    % Extract and save right hemisphere 76-label parcellation color table
    [vertices, label, colortable] = read_annotation(fullfile(in_dir, 'label', 'rh.aparc.a2009s.annot'));
    save(fullfile(out_dir, 'color_table_rh_76.mat'), 'colortable', 'label', 'vertices');

    % Extract and save left hemisphere 36-label parcellation color table
    [vertices, label, colortable] = read_annotation(fullfile(in_dir, 'label', 'lh.aparc.annot'));
    save(fullfile(out_dir, 'color_table_lh_36.mat'), 'colortable', 'label', 'vertices');

    % Extract and save right hemisphere 36-label parcellation color table
    [vertices, label, colortable] = read_annotation(fullfile(in_dir, 'label', 'rh.aparc.annot'));
    save(fullfile(out_dir, 'color_table_rh_36.mat'), 'colortable', 'label', 'vertices');

end % function

%% Helper functions

function [vertices, label, colortable] = read_annotation(filename)
% [vertices, label, colortable] = Read_Brain_Annotation(annotfilename.annot)
%
% vertices expected to be simply from 0 to number of vertices - 1;
% label is the vector of annotation
%
% colortable is empty struct if not embedded in .annot. Else, it will be
% a struct.
% colortable.numEntries = number of Entries
% colortable.orig_tab = name of original colortable
% colortable.struct_names = list of structure names (e.g. central sulcus and so on)
% colortable.table = n x 5 matrix. 1st column is r, 2nd column is g, 3rd column
% is b, 4th column is flag, 5th column is resultant integer values
% calculated from r + g*2^8 + b*2^16 + flag*2^24. flag expected to be all 0.


%
% read_annotation.m
%
% Original Author: Bruce Fischl
% CVS Revision Info:
%    $Author: nicks $
%    $Date: 2007/01/10 22:55:09 $
%    $Revision: 1.4 $
%
% Copyright (C) 2002-2007,
% The General Hospital Corporation (Boston, MA).
% All rights reserved.
%
% Distribution, usage and copying of this software is covered under the
% terms found in the License Agreement file named 'COPYING' found in the
% FreeSurfer source code root directory, and duplicated here:
% https://surfer.nmr.mgh.harvard.edu/fswiki/FreeSurferOpenSourceLicense
%
% General inquiries: freesurfer@nmr.mgh.harvard.edu
% Bug reports: analysis-bugs@nmr.mgh.harvard.edu
%

    % Open file in binary read mode (big-endian format)
    fp = fopen(filename, 'r', 'b');

    if(fp < 0)
       error('Annotation file cannot be opened: %s', filename);
    end

    % Read number of vertices
    A = fread(fp, 1, 'int');

    % Read vertex indices and labels (interleaved: vertex1, label1, vertex2, label2, ...)
    tmp = fread(fp, 2*A, 'int');
    vertices = tmp(1:2:end);  % Extract vertex indices (odd positions)
    label = tmp(2:2:end);     % Extract labels (even positions)

    % Check if colortable exists
    bool = fread(fp, 1, 'int');
    if(isempty(bool))  % No colortable embedded
       warning('No colortable found in annotation file: %s', filename);
       colortable = struct([]);
       fclose(fp);
       return;
    end

    if(bool)  % Colortable exists

        %Read colortable
        numEntries = fread(fp, 1, 'int');

        if(numEntries > 0)
            % Original version format
            disp('Reading from Original Version');
            colortable.numEntries = numEntries;
            
            % Read original colortable name
            len = fread(fp, 1, 'int');
            colortable.orig_tab = fread(fp, len, '*char')';
            colortable.orig_tab = colortable.orig_tab(1:end-1);  % Remove null terminator

            % Initialize colortable arrays
            colortable.struct_names = cell(numEntries, 1);
            colortable.table = zeros(numEntries, 5);
            
            % Read each colortable entry
            for i = 1:numEntries
                % Read structure name
                len = fread(fp, 1, 'int');
                colortable.struct_names{i} = fread(fp, len, '*char')';
                colortable.struct_names{i} = colortable.struct_names{i}(1:end-1);  % Remove null terminator
                
                % Read RGB color components and flag
                colortable.table(i, 1) = fread(fp, 1, 'int');  % Red
                colortable.table(i, 2) = fread(fp, 1, 'int');  % Green
                colortable.table(i, 3) = fread(fp, 1, 'int');  % Blue
                colortable.table(i, 4) = fread(fp, 1, 'int');  % Flag
                
                % Calculate combined integer value: r + g*2^8 + b*2^16 + flag*2^24
                colortable.table(i, 5) = colortable.table(i, 1) + ...
                    colortable.table(i, 2)*2^8 + ...
                    colortable.table(i, 3)*2^16 + ...
                    colortable.table(i, 4)*2^24;
            end
            disp(['Colortable with ' num2str(colortable.numEntries) ' entries read (originally ' colortable.orig_tab ')']);

        else
            % Version 2 format (sparse representation)
            version = -numEntries;
            if(version ~= 2)
                error('Unsupported annotation file version: %d', version);
            else
                disp(['Reading from version ' num2str(version)]);
            end
            
            % Read total number of entries and original colortable name
            numEntries = fread(fp, 1, 'int');
            colortable.numEntries = numEntries;
            len = fread(fp, 1, 'int');
            colortable.orig_tab = fread(fp, len, '*char')';
            colortable.orig_tab = colortable.orig_tab(1:end-1);  % Remove null terminator

            % Initialize colortable arrays
            colortable.struct_names = cell(numEntries, 1);
            colortable.table = zeros(numEntries, 5);

            % Read number of entries to actually read (sparse format)
            numEntriesToRead = fread(fp, 1, 'int');
            
            % Read each colortable entry (sparse format: only non-empty entries)
            for i = 1:numEntriesToRead
                structure = fread(fp, 1, 'int') + 1;  % Convert from 0-indexed to 1-indexed
                if (structure < 0)
                    error('Invalid structure index: %d', structure);
                end
                if(~isempty(colortable.struct_names{structure}))
                    warning('Duplicate structure entry at index %d', structure);
                end
                
                % Read structure name
                len = fread(fp, 1, 'int');
                colortable.struct_names{structure} = fread(fp, len, '*char')';
                colortable.struct_names{structure} = colortable.struct_names{structure}(1:end-1);  % Remove null terminator
                
                % Read RGB color components and flag
                colortable.table(structure, 1) = fread(fp, 1, 'int');  % Red
                colortable.table(structure, 2) = fread(fp, 1, 'int');  % Green
                colortable.table(structure, 3) = fread(fp, 1, 'int');  % Blue
                colortable.table(structure, 4) = fread(fp, 1, 'int');  % Flag
                
                % Calculate combined integer value
                colortable.table(structure, 5) = colortable.table(structure, 1) + ...
                    colortable.table(structure, 2)*2^8 + ...
                    colortable.table(structure, 3)*2^16 + ...
                    colortable.table(structure, 4)*2^24;
            end
            disp(['Colortable with ' num2str(colortable.numEntries) ' entries read (originally ' colortable.orig_tab ')']);
        end
    else
        error('Unexpected annotation file format: bool = 0');
    end

    fclose(fp);

end % function
