function zeffiro_downloader( kwargs )
% --- Zeffiro documentation header ---
% zeffiro_downloader — Zeffiro downloader.
%
% Purpose:
%   Zeffiro downloader.
%   Folder: Repository root: startup (`zeffiro_interface`, `zeffiro_setup`), path configuration, and entry to `src/`, `+core`, `+inverse`, `+utilities`, `tools/plugins`, and bundled data.
%
% Inputs:
%   kwargs
%
% Outputs:
%   See function signature and code below.
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `zeffiro_downloader(kwargs)` with project root and `src` on the path.
% --- End Zeffiro documentation header

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

% Attempt cloning into the target folder.

[status, cmdout] = system ( ...
    "git clone --depth=1 -b " ...
    + " " ...
    + kwargs.branch_name ...
    + " " ...
    + kwargs.git_address ...
    + " " ...
    + program_path ...
);

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

cd ( program_path ) ;

if kwargs.run_setup
    zeffiro_setup ( "submodules", kwargs.submodules ) ;
end

cd ( current_folder ) ;

end % function
