function zeffiro_downloader( kwargs )
%ZEFFIRO_DOWNLOADER  Shallow-clone Zeffiro Interface and optionally run setup.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Clones the official GitHub repository into install_directory/folder_name,
%   writes profile_name into profile/zeffiro_interface.ini, then optionally
%   runs zeffiro_setup in that clone. This helper is intended for a fresh
%   install, not for updating an existing working tree.
%
%   zeffiro_downloader
%   zeffiro_downloader(Name, Value, ...)
%
%   Name-value arguments
%     install_directory - existing folder that will contain the clone.
%                         Default pwd. Validated with mustBeFolder.
%     branch_name       - git branch to clone, default "master" (the official
%                         GitHub default). Ongoing development on the
%                         upstream project lives on main_development_branch;
%                         pass that name if you want the live line.
%     profile_name      - value written to the profile_name field of
%                         profile/zeffiro_interface.ini. Default
%                         "multicompartment_head".
%     folder_name       - clone directory name. Default "zeffiro_interface".
%                         If passed empty, becomes
%                         "zeffiro_interface-" + branch_name.
%     run_setup         - logical, default true. Call zeffiro_setup after clone.
%     git_address       - remote URL, default
%                         https://github.com/sampsapursiainen/zeffiro_interface.git
%                         Must start with https://, http://, git@, ssh://,
%                         or file://.
%     submodules        - forwarded to zeffiro_setup as "submodules".
%
%   Side effects
%     Creates a git working tree, rewrites the profile INI, and changes
%     directory to the clone while setup runs (restored afterwards, including
%     when setup throws). Git arguments are shell-quoted so paths with
%     spaces work and user-supplied strings are not interpolated by the shell.
%
%   Failure
%     Errors if git clone returns a non-zero status.
%
%   See also zeffiro_setup, zeffiro_interface.

arguments
    kwargs.install_directory (1,1) string { mustBeFolder } = pwd
    kwargs.branch_name (1,1) string = "master"
    kwargs.profile_name (1,1) string = "multicompartment_head"
    kwargs.folder_name (1,1) string = "zeffiro_interface"
    kwargs.run_setup (1,1) logical = true
    kwargs.git_address (1,1) string = "https://github.com/sampsapursiainen/zeffiro_interface.git"
    kwargs.submodules = string ([])
end

if isempty(kwargs.folder_name)
    kwargs.folder_name = "zeffiro_interface-" + kwargs.branch_name ;
end

program_path = fullfile ( kwargs.install_directory, kwargs.folder_name ) ;

i_assert_git_address(kwargs.git_address);

% Attempt cloning into the target folder. Quote every interpolated
% argument: install_directory may contain spaces, and an unquoted
% branch_name / git_address can be interpreted by the shell.

clone_cmd = strjoin({ ...
    "git", "clone", "--depth=1", "-b", ...
    i_shell_quote(kwargs.branch_name), ...
    i_shell_quote(kwargs.git_address), ...
    i_shell_quote(program_path)}, " ");

[status, cmdout] = system(clone_cmd);

if status ~= 0
    error ( ...
        "Downloading Zeffiro Interface with the branch name '" ...
        + kwargs.branch_name ...
        + "' and local destination folder '" ...
        + program_path ...
        + "' did not succeed. " ...
        + "The specific encountered error was as follows:" ...
        + newline + newline ...
        + "    " + cmdout ...
        + newline + newline ...
        + "Check your spelling and try again." ...
    ) ;
end

% Generate a profile file.

ini_cell = readcell ( fullfile ( program_path, "profile", "zeffiro_interface.ini" ), "FileType", "text" );
aux_row = find ( ismember ( ini_cell(:,3),"profile_name" ) );
ini_cell{aux_row,2} = kwargs.profile_name;
writecell ( ini_cell, fullfile ( program_path, "profile", "zeffiro_interface.ini" ), "FileType", "text");

% Run setup with the possible options

current_folder = pwd ;
restore_cwd = onCleanup(@() cd(current_folder)); %#ok<NASGU>

cd ( program_path ) ;

if kwargs.run_setup
    zeffiro_setup ( "submodules", kwargs.submodules ) ;
end

end % function

function i_assert_git_address(addr)
addr = strtrim(char(string(addr)));
ok = startsWith(addr, "https://") ...
    || startsWith(addr, "http://") ...
    || startsWith(addr, "git@") ...
    || startsWith(addr, "ssh://") ...
    || startsWith(addr, "file://");
if ~ok
    error("zeffiro_downloader:InvalidGitAddress", ...
        "git_address must be an https, http, git@, ssh://, or file:// URL.");
end
end

function q = i_shell_quote(s)
%I_SHELL_QUOTE  Quote a scalar string for MATLAB system() on this OS.
s = char(string(s));
if ispc
    q = ['"' strrep(s, '"', '""') '"'];
else
    q = ['''' strrep(s, '''', '''\''''') ''''];
end
end
