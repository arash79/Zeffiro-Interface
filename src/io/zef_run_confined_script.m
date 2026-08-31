function zef_run_confined_script(script_path, allowed_root)
%ZEF_RUN_CONFINED_SCRIPT  run() a .m file only if it sits under allowed_root.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Replaces string-evalc of a manifest filename (quote breakout). Resolves
%   relative paths against allowed_root, requires isfile, and refuses paths
%   that escape the import folder.
%
%   zef_run_confined_script(script_path, allowed_root)
%
%   See also zef_import_segmentation.

arguments
    script_path {mustBeTextScalar}
    allowed_root {mustBeTextScalar}
end

script_path = char(script_path);
allowed_root = char(allowed_root);

if isempty(script_path)
    error("Zeffiro:Import:EmptyScript", "Segmentation script filename is empty.");
end
if ~isfile(script_path)
    candidate = fullfile(allowed_root, script_path);
    if isfile(candidate)
        script_path = candidate;
    else
        error("Zeffiro:Import:MissingScript", ...
            "Segmentation script not found: %s", script_path);
    end
end

[ok_root, root_attr] = fileattrib(allowed_root);
[ok_script, script_attr] = fileattrib(script_path);
if ~ok_root || ~ok_script
    error("Zeffiro:Import:ScriptPath", ...
        "Cannot resolve import script or allowed folder.");
end
root_name = root_attr.Name;
script_name = script_attr.Name;
if ispc
    root_name = lower(root_name);
    script_name = lower(script_name);
end
if ~(strcmp(script_name, root_name) || startsWith(script_name, [root_name filesep]))
    error("Zeffiro:Import:ScriptOutsideImportRoot", ...
        "Segmentation script %s is not under the import folder %s.", ...
        script_attr.Name, root_attr.Name);
end

cmd = ['run(''' strrep(script_attr.Name, '''', '''''') ''');'];
evalin('caller', cmd);

end
