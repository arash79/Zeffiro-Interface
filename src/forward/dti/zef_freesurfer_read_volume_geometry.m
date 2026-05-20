%Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%
%ZEF_FREESURFER_READ_VOLUME_GEOMETRY
%
%Reads volume geometry from FreeSurfer MGZ/MGH files or NIfTI files using
%ONLY FreeSurfer's mri_info command. No fallbacks, no alternate parsers.
%
%Extracts all matrices needed for the DTI coordinate transformation chain:
%  - vox2ras      : 4×4 voxel-to-scanner-RAS (0-based voxel indices, as from mri_info)
%  - vox2ras_tkr  : 4×4 voxel-to-FreeSurfer-tkRAS (0-based; from mri_info --vox2ras-tkr)
%  - center_ras   : 3×1 volume center in scanner RAS [c_r; c_a; c_s]
%
%FreeSurfer convention: mri_info uses 0-based voxel indices. Both vox2ras and
%vox2ras_tkr are read directly from mri_info (voxel to ras transform and
%--vox2ras-tkr). Use voxel indices 0..dim-1 when applying.
%
%Inputs:
%   input - One of:
%           (a) File path (string/char) to .mgz, .mgh, .nii, or .nii.gz
%           (b) MATLAB niftiinfo struct (will attempt to extract Filename)
%
%Outputs:
%   geom  - Struct with fields:
%     .vox2ras      [4×4]  Voxel→scanner-RAS (0-based voxel, same as mri_info)
%     .vox2ras_tkr  [4×4]  Voxel→tkRAS (0-based voxel)
%     .center_ras   [3×1]  Volume center in scanner RAS (c_r, c_a, c_s)
%     .dimensions   [1×3]  Volume dimensions [nx ny nz]
%     .voxel_sizes  [1×3]  Voxel sizes in mm
%     .source       char   Description of how geometry was obtained
%
%See also: zef_dti_get_mesh2voxel, zef_freesurfer_load_fa
%
%Implementation Notes:
%  - Uses ONLY mri_info from FreeSurfer (no fallbacks)
%  - Requires FREESURFER_HOME environment variable to be set
%  - mri_info must be available in PATH (via FreeSurfer setup)
%  - If mri_info fails or returns incomplete data, function errors immediately
%  - All geometry is extracted from mri_info output parsing

function geom = zef_freesurfer_read_volume_geometry(input)

geom = struct('vox2ras', [], 'vox2ras_tkr', [], 'center_ras', [], ...
              'dimensions', [], 'voxel_sizes', [], 'source', '');

% ========================================================================
% STEP 1: Resolve input to file path
% ========================================================================

filepath = [];

if ischar(input) || isstring(input)
    % File path provided directly
    filepath = char(input);
    
elseif isstruct(input)
    % niftiinfo struct - try to extract filename from various possible fields
    filepath = [];
    
    % Check common field names where filename might be stored
    possible_fields = {'Filename', 'Source', 'File', 'Path', 'filepath'};
    for i = 1:length(possible_fields)
        if isfield(input, possible_fields{i})
            field_value = input.(possible_fields{i});
            if ischar(field_value) || isstring(field_value)
                filepath = char(field_value);
                if ~isempty(filepath)
                    break;
                end
            end
        end
    end
    
    if isempty(filepath)
        error('zef_freesurfer_read_volume_geometry:noFilename', ...
              ['niftiinfo struct provided but no filename field found.\n' ...
               'This function requires a file path to use mri_info.\n' ...
               'Checked fields: Filename, Source, File, Path\n' ...
               'Please provide the file path directly instead of the niftiinfo struct, or\n' ...
               'ensure the niftiinfo struct contains the original file path.']);
    end
    
else
    error('zef_freesurfer_read_volume_geometry:badInput', ...
          'Input must be a file path (string/char) or a niftiinfo struct with Filename field.');
end

% Validate file exists
if ~isfile(filepath)
    error('zef_freesurfer_read_volume_geometry:fileNotFound', ...
          'File not found: %s', filepath);
end

% Validate file format
if ~(endsWith(filepath, '.mgz', 'IgnoreCase', true) || ...
     endsWith(filepath, '.mgh', 'IgnoreCase', true) || ...
     endsWith(filepath, '.nii.gz', 'IgnoreCase', true) || ...
     endsWith(filepath, '.nii', 'IgnoreCase', true))
    error('zef_freesurfer_read_volume_geometry:unsupportedFormat', ...
          'Unsupported file format. Expected .mgz, .mgh, .nii, or .nii.gz');
end

% ========================================================================
% STEP 2: Validate FreeSurfer environment
% ========================================================================

fsHome = getenv('FREESURFER_HOME');
if isempty(fsHome)
    error('zef_freesurfer_read_volume_geometry:noFreeSurferHome', ...
          ['FREESURFER_HOME environment variable is not set.\n' ...
           'Please set it to your FreeSurfer installation directory, e.g.:\n' ...
           '  setenv(''FREESURFER_HOME'', ''/Applications/freesurfer/8.0.0'')']);
end

if ~isfolder(fsHome)
    error('zef_freesurfer_read_volume_geometry:invalidFreeSurferHome', ...
          'FREESURFER_HOME does not point to a valid directory: %s', fsHome);
end

% Check that mri_info exists
mri_info_path = fullfile(fsHome, 'bin', 'mri_info');
if ~isfile(mri_info_path)
    error('zef_freesurfer_read_volume_geometry:mriInfoNotFound', ...
          ['mri_info not found at expected location: %s\n' ...
           'Please verify your FreeSurfer installation is complete.'], mri_info_path);
end

% ========================================================================
% STEP 3: Call mri_info and capture output
% ========================================================================

% Set up FreeSurfer environment and run mri_info
% Use bash -lc to ensure proper environment setup via SetUpFreeSurfer.sh
setupCmd = sprintf('source %s/SetUpFreeSurfer.sh', fsHome);
bashCmd = sprintf('bash -lc "%s && mri_info %s"', setupCmd, filepath);

[status, output] = system(bashCmd);

% Check if mri_info executed successfully
if status ~= 0
    error('zef_freesurfer_read_volume_geometry:mriInfoFailed', ...
          ['mri_info failed with exit code %d:\n%s\n\n' ...
           'Please verify that:\n' ...
           '  1. FREESURFER_HOME is set correctly (%s)\n' ...
           '  2. mri_info is available in PATH\n' ...
           '  3. The input file is a valid FreeSurfer/NIfTI volume'], ...
          status, output, fsHome);
end

if isempty(output)
    error('zef_freesurfer_read_volume_geometry:emptyOutput', ...
          'mri_info returned empty output for file: %s', filepath);
end

% ========================================================================
% STEP 4: Parse mri_info default output (dimensions, voxel sizes, center)
% ========================================================================

% Check for "ras xform present" - required for geometry extraction
if ~contains(output, 'ras xform present')
    error('zef_freesurfer_read_volume_geometry:noRASXform', ...
          ['mri_info output indicates no RAS transform is present.\n' ...
           'File: %s\n' ...
           'This file may not have valid geometry information.'], filepath);
end

% Extract dimensions: "dimensions: 256 x 256 x 256"
dims_match = regexp(output, 'dimensions:\s*(\d+)\s*x\s*(\d+)\s*x\s*(\d+)', 'tokens', 'once');
if isempty(dims_match) || length(dims_match) < 3
    error('zef_freesurfer_read_volume_geometry:parseDimensions', ...
          'Failed to parse dimensions from mri_info output:\n%s', output);
end
dimensions = [str2double(dims_match{1}), str2double(dims_match{2}), str2double(dims_match{3})];
if any(isnan(dimensions))
    error('zef_freesurfer_read_volume_geometry:invalidDimensions', ...
          'Failed to convert dimensions to numbers: %s', strjoin(dims_match, ', '));
end

% Extract voxel sizes: "voxel sizes: 1.000000, 1.000000, 1.000000"
voxel_sizes_match = regexp(output, 'voxel sizes:\s*(\d+\.?\d*),\s*(\d+\.?\d*),\s*(\d+\.?\d*)', 'tokens', 'once');
if isempty(voxel_sizes_match) || length(voxel_sizes_match) < 3
    error('zef_freesurfer_read_volume_geometry:parseVoxelSizes', ...
          'Failed to parse voxel sizes from mri_info output:\n%s', output);
end
voxel_sizes = [str2double(voxel_sizes_match{1}), ...
               str2double(voxel_sizes_match{2}), ...
               str2double(voxel_sizes_match{3})];
if any(isnan(voxel_sizes))
    error('zef_freesurfer_read_volume_geometry:invalidVoxelSizes', ...
          'Failed to convert voxel sizes to numbers: %s', strjoin(voxel_sizes_match, ', '));
end

% Extract center RAS coordinates: "c_r = 0.5000", "c_a = -17.5000", "c_s = 22.5000"
cr_match = regexp(output, 'c_r\s*=\s*(-?\d+\.?\d*)', 'tokens', 'once');
ca_match = regexp(output, 'c_a\s*=\s*(-?\d+\.?\d*)', 'tokens', 'once');
cs_match = regexp(output, 'c_s\s*=\s*(-?\d+\.?\d*)', 'tokens', 'once');

if isempty(cr_match) || isempty(ca_match) || isempty(cs_match)
    error('zef_freesurfer_read_volume_geometry:parseCenterRAS', ...
          ['Failed to parse center RAS coordinates from mri_info output.\n' ...
           'Expected format: c_r = <value>, c_a = <value>, c_s = <value>\n' ...
           'Actual output:\n%s'], output);
end

center_ras = [str2double(cr_match{1}); ...
              str2double(ca_match{1}); ...
              str2double(cs_match{1})];

if any(isnan(center_ras))
    error('zef_freesurfer_read_volume_geometry:invalidCenterRAS', ...
          'Failed to convert center RAS coordinates to numbers.');
end

% ========================================================================
% STEP 5: Get vox2ras from mri_info --vox2ras
% ========================================================================
% Use dedicated --vox2ras output so parsing matches command-line exactly
% (avoids banner/format issues when parsing from default mri_info output).

bashCmd_ras = sprintf('bash -lc "%s && mri_info %s --vox2ras"', setupCmd, filepath);
[status_ras, output_ras] = system(bashCmd_ras);

if status_ras ~= 0
    error('zef_freesurfer_read_volume_geometry:mriInfoRasFailed', ...
          ['mri_info --vox2ras failed with exit code %d:\n%s'], status_ras, output_ras);
end

vox2ras = parse_4x4_from_mri_info_output(output_ras, 'vox2ras');

% ========================================================================
% STEP 6: Get vox2ras_tkr from mri_info --vox2ras-tkr
% ========================================================================

bashCmd_tkr = sprintf('bash -lc "%s && mri_info %s --vox2ras-tkr"', setupCmd, filepath);
[status_tkr, output_tkr] = system(bashCmd_tkr);

if status_tkr ~= 0
    error('zef_freesurfer_read_volume_geometry:mriInfoTkrFailed', ...
          ['mri_info --vox2ras-tkr failed with exit code %d:\n%s'], status_tkr, output_tkr);
end

vox2ras_tkr = parse_4x4_from_mri_info_output(output_tkr, 'vox2ras-tkr');

% ========================================================================
% STEP 7: Validate consistency
% ========================================================================

% Validate matrix dimensions
if ~isequal(size(vox2ras), [4, 4]) || ~isequal(size(vox2ras_tkr), [4, 4])
    error('zef_freesurfer_read_volume_geometry:invalidMatrixSize', ...
          'Computed matrices are not 4×4. vox2ras: [%s], vox2ras_tkr: [%s]', ...
          mat2str(size(vox2ras)), mat2str(size(vox2ras_tkr)));
end

% Validate dimensions consistency
if length(dimensions) ~= 3
    error('zef_freesurfer_read_volume_geometry:invalidDimensions', ...
          'Dimensions must be 1×3, got: [%s]', mat2str(size(dimensions)));
end

% Validate voxel sizes consistency
if length(voxel_sizes) ~= 3
    error('zef_freesurfer_read_volume_geometry:invalidVoxelSizes', ...
          'Voxel sizes must be 1×3, got: [%s]', mat2str(size(voxel_sizes)));
end

% Validate center_ras consistency
if ~isequal(size(center_ras), [3, 1])
    error('zef_freesurfer_read_volume_geometry:invalidCenterRAS', ...
          'center_ras must be 3×1, got: [%s]', mat2str(size(center_ras)));
end

% ========================================================================
% STEP 8: Assemble output
% ========================================================================

geom.vox2ras      = vox2ras;
geom.vox2ras_tkr  = vox2ras_tkr;
geom.center_ras   = center_ras;
geom.dimensions   = dimensions;
geom.voxel_sizes  = voxel_sizes;
geom.source       = sprintf('mri_info: %s', filepath);

end

%% -----------------------------------------------------------------------
%  Parse 4×4 matrix from mri_info output (--vox2ras or --vox2ras-tkr)
%  -----------------------------------------------------------------------
function M = parse_4x4_from_mri_info_output(output_str, label)
% Finds the first 4 lines that each contain at least 4 numbers and
% builds a 4×4 matrix (row-major). Skips INFO/banner lines.
lines = strsplit(output_str, {'\n', '\r'});
M = zeros(4, 4);
row_count = 0;
for i = 1:length(lines)
    line = strtrim(lines{i});
    if isempty(line), continue; end
    numbers = regexp(line, '(-?\d+\.?\d*)', 'tokens');
    if length(numbers) >= 4
        row_count = row_count + 1;
        if row_count > 4
            error('zef_freesurfer_read_volume_geometry:parseMatrix', ...
                  'Found more than 4 matrix rows in mri_info %s output.', label);
        end
        for j = 1:4
            M(row_count, j) = str2double(numbers{j}{1});
            if isnan(M(row_count, j))
                error('zef_freesurfer_read_volume_geometry:parseMatrix', ...
                      'Failed to parse %s element [%d,%d] from "%s".', label, row_count, j, line);
            end
        end
    end
end
if row_count ~= 4
    error('zef_freesurfer_read_volume_geometry:parseMatrix', ...
          'Failed to parse 4×4 matrix from mri_info %s (got %d rows).\nOutput:\n%s', ...
          label, row_count, output_str);
end
end
