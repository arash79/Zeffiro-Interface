function zef_file = generate_zef_import(output_dir, options)
%GENERATE_ZEF_IMPORT  Build import_segmentation.zef from meshes in output_dir.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef_file = generate_zef_import(output_dir, options)
%
% This is the unified replacement for both:
%   - fs2zef's static import_segmentation.zef template
%   - GENERICfs2zef's dynamic STL-based import generation
%
% Scans the output directory for mesh files (.asc, .stl), automatically
% determines their properties (color, sigma, activity, merge value), computes
% affine transforms when needed, and generates a complete import file for
% Zeffiro Interface. FreeSurfer label .asc files are atlas point files and
% are skipped here so they are not imported as segmentation meshes.
%
% Inputs:
%   output_dir - Directory containing mesh files
%   options    - (optional) Struct with configuration:
%
%     % File inclusion
%     .include_electrodes (logical) - Add electrodes.dat entry (default: true)
%     .include_box (logical)        - Add bounding box entry (default: true)
%     .electrode_file (string)      - Path to electrode file (default: auto-detect)
%
%     % Atlas data (for cortical parcellation)
%     .atlas_colortables (struct)   - Paths to color table files
%     .atlas_points (struct)        - Paths to label point files
%
%     % Transform computation
%     .compute_transforms (char/logical) - 'auto', true, or false (default: 'auto')
%     .reference_volume (string)    - Path to reference .mgz (default: auto-detect orig.mgz)
%     .segmentation_volume (string) - Path to source .mgz for transforms
%
%     % Compartment configuration
%     .compartment_config (struct)  - Custom compartment parameter overrides
%     .default_sigma (double)       - Default sigma if not found (default: 0.33)
%     .default_activity (double)    - Default activity (default: 0)
%
%     % Output options
%     .output_file (string)         - Output filename (default: 'import_segmentation.zef')
%     .sort_order (string)          - 'alphabetical', 'anatomical' (default: 'alphabetical')
%     .merge_left_right (logical)   - Merge L/R compartments (default: true)
%                                     true: name=base only, merge=0/1; false: name=L/R, merge=0 all
%     .validate_files (logical)     - Check file existence (default: true)
%     .verbose (logical)            - Print progress (default: true)
%
% Outputs:
%   zef_file - Path to generated ZEF import file
%
% Algorithm:
%   1. Scan output_dir for all mesh files (.asc, .stl), excluding label .asc files
%   2. Parse filenames to extract compartment names and hemisphere info
%   3. Look up metadata (color, sigma, activity) from:
%      - FreeSurferColorLUT.txt
%      - compartment_mappings.m (custom overrides)
%   4. Determine merge value (0=left, 1=right, -1=single)
%   5. Compute affine transforms if needed
%   6. Generate CSV lines with all parameters
%   7. Sort by compartment name + merge value
%   8. Write to import_segmentation.zef
%
% Example:
%   % Standard usage
%   zef_file = utilities.fs2zef.generators.generate_zef_import('/path/to/output');
%
%   % With options
%   zef_file = utilities.fs2zef.generators.generate_zef_import('/path/to/output', ...
%       'compute_transforms', true, ...
%       'reference_volume', '/path/to/orig.mgz', ...
%       'verbose', true);
%

    arguments
        output_dir (1,1) string { mustBeFolder }
        options.include_electrodes (1,1) logical = true
        options.include_box (1,1) logical = true
        options.electrode_file (1,1) string = ""
        options.atlas_colortables struct = struct()
        options.atlas_points struct = struct()
        options.compute_transforms = 'auto'
        options.reference_volume (1,1) string = ""
        options.segmentation_volume (1,1) string = ""
        options.compartment_config struct = struct()
        options.default_sigma (1,1) double = 0.33
        options.default_activity (1,1) double = 0
        options.output_file (1,1) string = "import_segmentation.zef"
        options.sort_order (1,1) string = "alphabetical"
        options.merge_left_right (1,1) logical = true
        options.validate_files (1,1) logical = true
        options.verbose (1,1) logical = true
        options.path_prefix (1,1) string = ""
    end
    
    if options.verbose
        fprintf('\n=== Generating ZEF Import File ===\n');
        fprintf('Output directory: %s\n', output_dir);
    end
    
    % Load compartment mappings and FreeSurfer LUT
    compartment_maps = utilities.fs2zef.config.compartment_mappings();
    
    try
        lut = utilities.fs2zef.readers.readFSLUT();
    catch ME
        warning('generate_zef_import:NoLUT', ...
            'Could not read FreeSurferColorLUT.txt: %s\nUsing default colors.', ME.message);
        lut = struct('No', [], 'Name', {{}}, 'R', [], 'G', [], 'B', [], 'A', []);
    end
    
    % Find all mesh files in the specified directory
    asc_files = dir(fullfile(output_dir, '*.asc'));
    asc_files = filter_mesh_asc_files(asc_files, output_dir, options.verbose);
    stl_files = dir(fullfile(output_dir, '*.stl'));
    mesh_files = [asc_files; stl_files];
    
    if isempty(mesh_files)
        error('generate_zef_import:NoMeshes', ...
            'No mesh files (.asc or .stl) found in %s. Label .asc files are atlas data and were skipped.', output_dir);
    end
    
    if options.verbose
        fprintf('Found %d mesh files\n', numel(mesh_files));
    end
    
    % Determine if transforms are needed
    need_transforms = should_compute_transforms(options, output_dir);
    
    if need_transforms
        if options.verbose
            fprintf('Computing affine transforms...\n');
        end
        
        % Get reference and segmentation volumes
        if strlength(options.reference_volume) == 0
            options.reference_volume = find_reference_volume(output_dir);
        end
        
        if strlength(options.segmentation_volume) == 0
            options.segmentation_volume = find_segmentation_volume(output_dir);
        end
        
        % Compute affine transform
        if isfile(options.reference_volume) && isfile(options.segmentation_volume)
            affine_matrix = utilities.fs2zef.transforms.compute_affine_transform(...
                options.segmentation_volume, options.reference_volume);
            affine_str = mat2str(affine_matrix);
        else
            warning('generate_zef_import:NoTransform', ...
                'Could not compute transforms: volumes not found');
            affine_str = '';
        end
    else
        affine_str = '';
    end
    
    % Generate header lines
    header_lines = {};
    
    if options.include_electrodes
        electrode_path = get_electrode_file(output_dir, options.electrode_file);
        if strlength(electrode_path) > 0
            % Apply path prefix to electrode file if specified
            if strlength(options.path_prefix) > 0
                electrode_path_full = fullfile(options.path_prefix, electrode_path);
                electrode_path_full = strrep(electrode_path_full, '\', '/');
            else
                electrode_path_full = electrode_path;
            end
            header_lines{end+1} = sprintf(...
                'type,sensors,name,Electrodes,filename,%s,filetype,points,modality,EEG', ...
                electrode_path_full);
        end
    end
    
    if options.include_box
        header_lines{end+1} = 'type,box,name,Box';
    end
    
    % Process each mesh file
    seg_lines = cell(numel(mesh_files), 1);
    seg_count = 0;
    
    % Determine path prefix for filenames
    if strlength(options.path_prefix) == 0
        % No prefix specified, use just filenames (backward compatibility)
        path_prefix = "";
    else
        path_prefix = options.path_prefix;
    end
    
    for k = 1:numel(mesh_files)
        try
            line = process_mesh_file(mesh_files(k), output_dir, lut, ...
                compartment_maps, affine_str, path_prefix, options);
            if ~isempty(line)
                seg_count = seg_count + 1;
                seg_lines{seg_count} = line;
            end
        catch ME
            warning('generate_zef_import:ProcessFailed', ...
                'Failed to process %s: %s', mesh_files(k).name, ME.message);
        end
    end
    
    % Trim unused cells
    seg_lines = seg_lines(1:seg_count);
    
    % Sort segmentation lines (by base name, left before right)
    seg_lines = sort_segmentation_lines(seg_lines, options.sort_order);
    
    % Write to file
    zef_file = fullfile(output_dir, options.output_file);
    write_zef_file(zef_file, header_lines, seg_lines);
    
    if options.verbose
        fprintf('Generated ZEF import file: %s\n', zef_file);
        fprintf('  %d compartments included\n', numel(seg_lines));
        fprintf('===================================\n\n');
    end
    
end % main function

%% Helper Functions

function need_transforms = should_compute_transforms(options, output_dir)
    % Determine if affine transforms should be computed
    
    if islogical(options.compute_transforms)
        need_transforms = options.compute_transforms;
    elseif ischar(options.compute_transforms) || isstring(options.compute_transforms)
        if strcmpi(options.compute_transforms, 'auto')
            % Auto-detect: check if directory name suggests thalamic/specialized segmentation
            dir_lower = lower(output_dir);
            need_transforms = contains(dir_lower, 'thalamic') || ...
                             contains(dir_lower, 'nuclei') || ...
                             contains(dir_lower, 'subfield');
        else
            need_transforms = false;
        end
    else
        need_transforms = false;
    end
    
end % function

function ref_vol = find_reference_volume(output_dir)
    % Try to find orig.mgz in typical FreeSurfer locations
    
    % Go up directories to find FreeSurfer subject root
    parent = output_dir;
    for ii = 1:5
        mri_dir = fullfile(parent, 'mri');
        if isfolder(mri_dir)
            orig_mgz = fullfile(mri_dir, 'orig.mgz');
            if isfile(orig_mgz)
                ref_vol = orig_mgz;
                return;
            end
        end
        [parent, ~, ~] = fileparts(parent);
    end
    
    ref_vol = "";
    
end % function

function seg_vol = find_segmentation_volume(output_dir)
    % Try to find the segmentation volume
    % Look for common names in nearby mri/ directory
    
    parent = output_dir;
    for ii = 1:5
        mri_dir = fullfile(parent, 'mri');
        if isfolder(mri_dir)
            % Check for thalamic nuclei
            candidates = ["ThalamicNuclei.v13.T1.FSvoxelSpace.mgz", ...
                         "ThalamicNuclei.mgz", ...
                         "HippocampalSubfields.mgz", ...
                         "aseg.mgz"];
            for cand = candidates
                cand_path = fullfile(mri_dir, cand);
                if isfile(cand_path)
                    seg_vol = cand_path;
                    return;
                end
            end
        end
        [parent, ~, ~] = fileparts(parent);
    end
    
    seg_vol = "";
    
end % function

function electrode_path = get_electrode_file(output_dir, custom_path)
    % Get electrode file path
    
    if strlength(custom_path) > 0 && isfile(custom_path)
        electrode_path = custom_path;
    else
        % Check in output_dir
        local_path = fullfile(output_dir, 'electrodes.dat');
        if isfile(local_path)
            electrode_path = 'electrodes.dat';  % Relative path
        else
            electrode_path = "";
        end
    end
    
end % function

function asc_files = filter_mesh_asc_files(asc_files, output_dir, verbose)
    % Exclude FreeSurfer label files from segmentation mesh discovery.

    keep = true(numel(asc_files), 1);

    for ii = 1:numel(asc_files)
        file_path = fullfile(output_dir, asc_files(ii).name);
        if is_freesurfer_label_asc(file_path)
            keep(ii) = false;
            if verbose
                fprintf('Skipping atlas label file: %s\n', asc_files(ii).name);
            end
        end
    end

    asc_files = asc_files(keep);

end % function

function is_label_file = is_freesurfer_label_asc(file_path)
    % Label .asc files start with "#!ascii label" and have one count on line 2.

    is_label_file = false;

    [~, base_name, ext] = fileparts(file_path);
    if ~strcmpi(ext, '.asc')
        return;
    end

    if ~isempty(regexp(base_name, '^[lr]h_labels_\d+$', 'once'))
        is_label_file = true;
        return;
    end

    fid = fopen(file_path, 'r');
    if fid == -1
        return;
    end

    cleanup_obj = onCleanup(@() fclose(fid));
    first_line = fgetl(fid);

    if ischar(first_line)
        is_label_file = startsWith(lower(strtrim(string(first_line))), "#!ascii label");
    end

end % function

function line = process_mesh_file(mesh_file, output_dir, lut, compartment_maps, affine_str, path_prefix, options)
    % Process a single mesh file and generate its ZEF import line
    
    [~, base_name, ext] = fileparts(mesh_file.name);
    
    % Construct filename with path prefix if provided
    if strlength(path_prefix) > 0
        filename_for_zef = fullfile(path_prefix, mesh_file.name);
        % Normalize path separators to forward slashes
        filename_for_zef = strrep(filename_for_zef, '\', '/');
    else
        % Use just the filename (backward compatibility)
        filename_for_zef = mesh_file.name;
    end
    
    % Parse compartment name and hemisphere
    [compartment_name, hemisphere] = parse_compartment_name(base_name);
    
    % Get RGB color from LUT. Use the original filename-derived name first,
    % because FreeSurfer LUT names often include the hemisphere prefix.
    color_lookup_names = get_color_lookup_names(base_name, compartment_name, hemisphere);
    rgb = lookup_color(color_lookup_names, lut);
    
    % Get sigma, activity, inflate from compartment mappings
    [sigma, activity, inflate] = lookup_parameters(compartment_name, compartment_maps, options);
    
    % Determine display name and merge value based on merge_left_right option
    [display_name, merge_val] = get_display_name_and_merge(...
        hemisphere, base_name, options.merge_left_right);
    
    % Build line
    line = sprintf('type,segmentation,name,%s,filename,%s', ...
        display_name, filename_for_zef);
    
    % Always include merge field (0 for single/separate, 0/1 for left/right when merged)
    line = sprintf('%s,merge,%d', line, merge_val);
    
    line = sprintf('%s,parameter_name,sigma,parameter_value,%.2f', line, sigma);
    
    if ~isempty(affine_str) && strlength(affine_str) > 0
        line = sprintf('%s,affine_transform,%s', line, affine_str);
    end
    
    line = sprintf('%s,activity,%d', line, activity);
    line = sprintf('%s,color,%s', line, mat2str(rgb));
    line = sprintf('%s,inflate,%d', line, inflate);
    
    % Add atlas info if available (for grey matter with parcellation)
    has_atlas_colortable = isfield(options.atlas_colortables, hemisphere);
    has_atlas_points = isfield(options.atlas_points, hemisphere);

    if (has_atlas_colortable || has_atlas_points) && ...
       (contains(lower(compartment_name), 'grey') || contains(lower(compartment_name), 'pial'))
        
        if has_atlas_colortable
            line = sprintf('%s,atlas_colortable_filename,%s', ...
                line, options.atlas_colortables.(hemisphere));
        end
        
        if has_atlas_points
            line = sprintf('%s,atlas_points_filename,%s', ...
                line, options.atlas_points.(hemisphere));
        end
    end
    
end % function

function lookup_names = get_color_lookup_names(base_name, compartment_name, hemisphere)
    % Build LUT lookup candidates from most specific to broadest.
    %
    % Mesh filenames are sanitized by makeParcellation.sh, so e.g.
    % Right-VentralDC becomes Right_VentralDC on disk. normalize_name()
    % treats '_' and '-' equivalently, so the original base name is the best
    % first candidate for side-specific FreeSurfer labels.

    lookup_names = string(base_name);

    if strcmp(hemisphere, 'left')
        lookup_names(end+1) = "Left-" + string(compartment_name);
    elseif strcmp(hemisphere, 'right')
        lookup_names(end+1) = "Right-" + string(compartment_name);
    end

    lookup_names(end+1) = string(compartment_name);
    lookup_names = [lookup_names, get_surface_color_lookup_names(base_name, compartment_name, hemisphere)];
    lookup_names = unique_strings_stable(lookup_names);

end % function

function lookup_names = get_surface_color_lookup_names(base_name, compartment_name, hemisphere)
    % Generated surfaces are not always named like FreeSurfer LUT entries.

    lookup_names = strings(1, 0);

    base_norm = normalize_name(base_name);
    comp_norm = normalize_name(compartment_name);

    if comp_norm == "pial"
        if strcmp(hemisphere, 'left')
            lookup_names(end+1) = "Left-Cerebral-Cortex";
        elseif strcmp(hemisphere, 'right')
            lookup_names(end+1) = "Right-Cerebral-Cortex";
        else
            lookup_names(end+1) = "Cerebral-Cortex";
        end
    elseif comp_norm == "wm"
        if strcmp(hemisphere, 'left')
            lookup_names(end+1) = "Left-Cerebral-White-Matter";
        elseif strcmp(hemisphere, 'right')
            lookup_names(end+1) = "Right-Cerebral-White-Matter";
        else
            lookup_names(end+1) = "Cerebral-White-Matter";
        end
    elseif contains(base_norm, "skull")
        lookup_names(end+1) = "Skull";
    elseif contains(base_norm, "skin")
        lookup_names(end+1) = "Skin";
    end

end % function

function [compartment_name, hemisphere] = parse_compartment_name(base_name)
    % Parse filename to extract compartment name and hemisphere
    
    base_lower = lower(base_name);
    
    % Detect hemisphere
    if contains(base_lower, 'lh') || contains(base_lower, 'left')
        hemisphere = 'left';
    elseif contains(base_lower, 'rh') || contains(base_lower, 'right')
        hemisphere = 'right';
    else
        hemisphere = 'none';
    end
    
    % Clean up compartment name (remove hemisphere indicators)
    compartment_name = base_name;
    compartment_name = regexprep(compartment_name, '^[lL][hH]\.', '');   % lh.
    compartment_name = regexprep(compartment_name, '^[rR][hH]\.', '');   % rh.
    compartment_name = regexprep(compartment_name, '^[lL]eft[-_]', '');  % Left- or Left_
    compartment_name = regexprep(compartment_name, '^[rR]ight[-_]', ''); % Right- or Right_
    compartment_name = regexprep(compartment_name, '[-_][lL]eft$', '');  % -left or _left
    compartment_name = regexprep(compartment_name, '[-_][rR]ight$', ''); % -right or _right
    
end % function

function rgb = lookup_color(compartment_names, lut)
    % Look up RGB color from FreeSurfer LUT

    names = string(lut.Name);
    query_names = unique_strings_stable(string(compartment_names));

    lut_norm = normalize_name(names);

    idx = [];
    for ii = 1:numel(query_names)
        query_norm = normalize_name(query_names(ii));
        idx = find(lut_norm == query_norm, 1);
        if ~isempty(idx)
            break;
        end
    end

    if ~isempty(idx)
        % rgb = double([lut.R(idx), lut.G(idx), lut.B(idx)]) / 255.0;
        rgb = round(double([lut.R(idx), lut.G(idx), lut.B(idx)]) / 255.0, 3);
    else
        warning('Color not found for compartment: "%s"', strjoin(cellstr(query_names), '", "'));
        rgb = [0.5, 0.5, 0.5];
    end
end

function out = normalize_name(in)
    out = string(in);
    out = strtrim(out);
    out = regexprep(out, '[‐-‒–—―]', '-');
    out = regexprep(out, '[-_\s]+', '_');
    out = lower(out);
end

function out = unique_strings_stable(in)
    out = strings(1, 0);
    in = string(in);

    for ii = 1:numel(in)
        value = in(ii);
        if strlength(value) == 0
            continue;
        end
        if ~any(out == value)
            out(end+1) = value;
        end
    end
end

function [sigma, activity, inflate] = lookup_parameters(compartment_name, compartment_maps, options)
    % Look up sigma, activity, and inflate from compartment mappings
    
    name_lower = lower(compartment_name);
    
    % Check each tissue type's keywords
    map_fields = fieldnames(compartment_maps);
    for ii = 1:numel(map_fields)
        tissue_type = map_fields{ii};
        if strcmp(tissue_type, 'default')
            continue;
        end
        
        tissue_map = compartment_maps.(tissue_type);
        if isfield(tissue_map, 'keywords')
            for kw = tissue_map.keywords
                if contains(name_lower, lower(kw))
                    sigma = tissue_map.sigma;
                    activity = tissue_map.activity;
                    inflate = tissue_map.inflate;
                    return;
                end
            end
        end
    end
    
    % Use defaults
    sigma = options.default_sigma;
    activity = options.default_activity;
    inflate = compartment_maps.default.inflate;
    
end % function

function [display_name, merge_val] = get_display_name_and_merge(hemisphere, base_name, merge_left_right)
    % Determine display name and merge value based on merge_left_right option
    %
    % merge_left_right = true (merge enabled):
    %   - name = base name only (no left/right)
    %   - merge = 0 for left, 1 for right, 0 for single
    %
    % merge_left_right = false (separate):
    %   - name = explicit left/right in name
    %   - merge = 0 for ALL compartments
    
    base_name_clean = cleanup_name(base_name);
    
    if strcmp(hemisphere, 'left') || startsWith(lower(base_name), 'lh')
        if merge_left_right
            display_name = base_name_clean;
            merge_val = 0;
        else
            display_name = ['Left ' base_name_clean];
            merge_val = 0;
        end
    elseif strcmp(hemisphere, 'right') || startsWith(lower(base_name), 'rh')
        if merge_left_right
            display_name = base_name_clean;
            merge_val = 1;
        else
            display_name = ['Right ' base_name_clean];
            merge_val = 0;
        end
    else
        display_name = base_name_clean;
        merge_val = 0;  % Single compartments always use 0 when merge disabled
    end
    
end % function

function clean_name = cleanup_name(base_name)
    % Clean up compartment name for display (extract base name only)
    
    clean_name = base_name;
    
    % Remove hemisphere prefixes (dash or underscore)
    clean_name = regexprep(clean_name, '^[lL][hH]\.', '');
    clean_name = regexprep(clean_name, '^[rR][hH]\.', '');
    clean_name = regexprep(clean_name, '^[lL]eft[-_]', '');
    clean_name = regexprep(clean_name, '^[rR]ight[-_]', '');
    clean_name = regexprep(clean_name, '[-_][lL]eft$', '');
    clean_name = regexprep(clean_name, '[-_][rR]ight$', '');
    clean_name = regexprep(clean_name, '[-_][lLrR][hH][-_]', '-');
    
    % Replace underscores/dashes with spaces
    clean_name = strrep(clean_name, '_', ' ');
    clean_name = strrep(clean_name, '-', ' ');
    
    % Remove leading/trailing spaces
    clean_name = strtrim(clean_name);
    
end % function

function sorted_lines = sort_segmentation_lines(lines, sort_order)
    % Sort segmentation lines by base compartment name (alphabetically).
    % For left/right pairs: sort by shared base name, left immediately before right.
    
    if strcmpi(sort_order, 'alphabetical')
        % Extract names and merge values for sorting
        base_names = cell(numel(lines), 1);
        merges = zeros(numel(lines), 1);
        
        for ii = 1:numel(lines)
            parts = strsplit(lines{ii}, ',');
            name_idx = find(strcmp(parts, 'name'), 1) + 1;
            name_str = parts{name_idx};
            
            % Base name for sorting: strip "Left " and "Right " prefix
            base_names{ii} = base_name_for_sort(name_str);
            
            merge_idx = find(strcmp(parts, 'merge'), 1);
            if ~isempty(merge_idx)
                merges(ii) = str2double(parts{merge_idx + 1});
            else
                merges(ii) = 0;
            end
        end
        
        % Sort by base name, then merge value (0=left/single before 1=right)
        [~, idx] = sortrows([base_names, num2cell(merges)], [1, 2]);
        sorted_lines = lines(idx);
    else
        % No sorting
        sorted_lines = lines;
    end
    
end % function

function base = base_name_for_sort(name_str)
    % Extract base name for sorting (strip Left/Right prefix)
    base = strtrim(name_str);
    base_lower = lower(base);
    if startsWith(base_lower, 'left ')
        base = strtrim(extractAfter(base, 5));
    elseif startsWith(base_lower, 'right ')
        base = strtrim(extractAfter(base, 6));
    end
end % function

function write_zef_file(filename, header_lines, seg_lines)
    % Write ZEF import file
    
    fid = fopen(filename, 'w');
    if fid == -1
        error('generate_zef_import:WriteFailed', ...
            'Could not open %s for writing', filename);
    end
    
    cleanup_obj = onCleanup(@() fclose(fid));
    
    % Write headers
    for ii = 1:numel(header_lines)
        fprintf(fid, '%s\n', header_lines{ii});
    end
    
    % Write segmentation lines
    for ii = 1:numel(seg_lines)
        fprintf(fid, '%s\n', seg_lines{ii});
    end
    
end % function
