function T = zef_freesurfer_read_register_dat(filepath)
%ZEF_FREESURFER_READ_REGISTER_DAT  Parse FreeSurfer register.dat 4×4 affine.
%
%   Zeffiro Interface.
%   Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Skips header lines; first four numeric 4-token rows become T. Stored on
%   zef as freesurfer_register_transform (FA voxel → mesh tkRAS).
%
%   T = zef_freesurfer_read_register_dat(filepath)
%
%   See also zef_dti_apply_to_sigma, zef_dti_get_mesh2voxel.




if isstring(filepath)
    filepath = char(filepath);
end
if ~ischar(filepath)
    error('filepath must be a string or char array.');
end
if ~isfile(filepath)
    error('File not found: %s', filepath);
end

text = fileread(filepath);
lines = strsplit(strtrim(text), {'\n','\r'});

% Find 4 lines that look like 4 numbers (the 4x4 matrix)
% FreeSurfer register.dat: optional header lines, then matrix rows
T = [];
for i = 1:length(lines)
    line = strtrim(lines{i});
    if isempty(line), continue; end
    parts = regexp(line, '\s+', 'split');
    parts = parts(~cellfun(@isempty, parts));
    if length(parts) >= 4
        row = str2double(parts(1:4));
        if all(~isnan(row))
            T = [T; row]; %#ok<AGROW>
            if size(T,1) == 4
                break
            end
        end
    end
end

if isempty(T) || size(T,1) ~= 4 || size(T,2) ~= 4
    error('Could not read 4×4 matrix from register.dat: %s', filepath);
end

% Ensure last row is [0 0 0 1] for affine
if abs(T(4,4) - 1) > 1e-6 || any(abs(T(4,1:3)) > 1e-6)
    % Some files may have different format; use as-is if valid
    if abs(det(T(1:3,1:3))) < 1e-10
        error('register.dat 3×3 rotation/scale part is singular.');
    end
end

end
