function C = zef_read_profile_cell(file_path)
%ZEF_READ_PROFILE_CELL  Fast cached CSV/INI cell reader for profile files.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Drop-in for readcell(..., 'FileType','text') on the small profile
%   INI/CSV files. A persistent cache keyed by path, byte size, and
%   modification time avoids re-parsing during a session. Quoted fields
%   (including commas) are preserved as character vectors; plain numeric
%   tokens become doubles, matching readcell.
%
%   C = zef_read_profile_cell(file_path)
%
%   See also zef_apply_system_settings, zef_plugin.

C = {};
if nargin < 1 || isempty(file_path)
    return
end
file_path = char(string(file_path));
stamp = local_stamp(file_path);

persistent cache_paths cache_stamps cache_vals
if isempty(cache_paths)
    cache_paths = {};
    cache_stamps = {};
    cache_vals = {};
end
idx = find(strcmp(cache_paths, file_path), 1);
if ~isempty(idx) && isequal(cache_stamps{idx}, stamp)
    C = cache_vals{idx};
    return
end

txt = '';
try
    txt = fileread(file_path);
catch
    C = readcell(file_path, 'FileType', 'text');
    local_store();
    return
end
txt = strrep(txt, sprintf('\r\n'), sprintf('\n'));
txt = strrep(txt, sprintf('\r'), sprintf('\n'));
lines = splitlines(txt);
rows = {};
width = 0;
for i = 1:numel(lines)
    line = lines{i};
    if isempty(strtrim(line))
        continue
    end
    row = local_csv_line(line);
    width = max(width, numel(row));
    rows{end+1} = row; %#ok<AGROW>
end
if isempty(rows)
    C = {};
    local_store();
    return
end
C = cell(numel(rows), width);
for i = 1:numel(rows)
    row = rows{i};
    C(i, 1:numel(row)) = row;
    for j = (numel(row)+1):width
        C{i, j} = [];
    end
end
local_store();

    function local_store()
        idx_store = find(strcmp(cache_paths, file_path), 1);
        if isempty(idx_store)
            cache_paths{end+1} = file_path; %#ok<AGROW>
            cache_stamps{end+1} = stamp; %#ok<AGROW>
            cache_vals{end+1} = C; %#ok<AGROW>
        else
            cache_stamps{idx_store} = stamp;
            cache_vals{idx_store} = C;
        end
    end

end

function stamp = local_stamp(file_path)

stamp = [0, 0];
try
    d = dir(file_path);
    if isempty(d)
        return
    end
    bytes = double(d(1).bytes);
    mtime = double(d(1).datenum);
    try
        mtime = double(java.io.File(file_path).lastModified());
    catch
    end
    stamp = [bytes, mtime];
catch
end

end

function row = local_csv_line(line)

row = {};
n = numel(line);
i = 1;
while i <= n
    if line(i) == '"'
        i = i + 1;
        tok = '';
        while i <= n
            if line(i) == '"'
                if i < n && line(i+1) == '"'
                    tok(end+1) = '"'; %#ok<AGROW>
                    i = i + 2;
                else
                    i = i + 1;
                    break
                end
            else
                tok(end+1) = line(i); %#ok<AGROW>
                i = i + 1;
            end
        end
        row{end+1} = tok; %#ok<AGROW>
        if i <= n && line(i) == ','
            i = i + 1;
        end
    else
        j = i;
        while j <= n && line(j) ~= ','
            j = j + 1;
        end
        tok = strtrim(line(i:j-1));
        row{end+1} = local_token(tok); %#ok<AGROW>
        i = j + 1;
    end
end

end

function tok = local_token(tok)

if isempty(tok)
    tok = [];
    return
end
if tok(1) == '@' || tok(1) == '[' || tok(1) == '{'
    return
end
num = str2double(tok);
if ~isnan(num) && ~isempty(regexp(tok, '^[+-]?(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?$', 'once'))
    tok = num;
end

end
