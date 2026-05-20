function lint_mfiles(folder, kwargs)
% --- Zeffiro documentation header ---
% utilities.dev.lint_mfiles — Lint mfiles.
%
% Purpose:
%   Lint mfiles.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   folder
%   kwargs
%
% Outputs:
%   See function signature and code below.
%
% Calls (project):
%   utilities.dev.get_mfile_paths
%   utilities.dev.lint_mfiles
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `utilities.dev.lint_mfiles(folder, kwargs)` with project root and `src` on the path.
% --- End Zeffiro documentation header

%LINT_MFILES Run code analyzer on all .m files under a folder; error if violations found.
%
% lint_mfiles(FOLDER, kwargs) runs the chosen MATLAB linter on every .m file
% in FOLDER and its subdirectories. If any message ID in UNACCEPTABLE_MESSAGES
% is found, or (with codeIssues) any issue has severity "error", they are
% reported and the function throws an error at the end.
%
% Inputs:
%   folder - (1,1) string, mustBeFolder
%             Root directory to search for .m files.
%   kwargs.UNACCEPTABLE_MESSAGES - (:,1) string, default ["NODEF"; "EVLDOT"]
%             Code analyzer message IDs that trigger a failure. See:
%             https://www.mathworks.com/help/matlab/matlab_env/index-of-code-analyzer-checks.html
%   kwargs.linter_fn_name - (1,1) string, mustBeMember(["mlint","checkcode","codeIssues"]), default "codeIssues"
%             Linter to use. "codeIssues" is preferred for MATLAB >= R2022b.
%
% Outputs:
%   None. Throws an error if any unacceptable issues are found.
%

arguments

    folder (1,1) string { mustBeFolder }

    kwargs.UNACCEPTABLE_MESSAGES (:,1) string = [ "NODEF" ; "EVLDOT" ]

    kwargs.linter_fn_name (1,1) string { mustBeMember(kwargs.linter_fn_name, ["mlint","checkcode","codeIssues"]) } = "codeIssues"

end

    disp( newline + "Linting m-files in " + folder + "..." ) ;

    matlab_release = version("-release");

    release_year = double ( string ( matlab_release(1:4) ) ) ;

    release_letter = matlab_release(5) ;

    mfile_paths = utilities.dev.get_mfile_paths ( folder ) ;

    n_of_issues = uint64( 0 ) ;

    for fpi = 1 : numel ( mfile_paths )

        fpath = mfile_paths ( fpi ) ;

        if ismember ( kwargs.linter_fn_name, [ "mlint" ; "checkcode" ] )

            n_of_issues = n_of_issues + lint_with_legacy_linter( fpath, kwargs.UNACCEPTABLE_MESSAGES ) ;

        elseif kwargs.linter_fn_name == "codeIssues" ...
        && release_year >= 2023 ...
        || ( release_year >= 2022 && release_letter == 'b' )

            n_of_issues = n_of_issues + lint_with_codeIssues( fpath, kwargs.UNACCEPTABLE_MESSAGES ) ;

        else

            error ( "Unknown linter function, or codeIssues was called with Matlab older than R2022b. Aborting..." ) ;

        end % if

    end % for

    if n_of_issues > 0

        error( newline + "During linting, unacceptable code style violations were found. See the above " + n_of_issues + " messages for details." ) ;

    end

end % function

%% Helper functions.

function n_of_issues = lint_with_legacy_linter(fpath, UNACCEPTABLE_MESSAGES)
%LINT_WITH_LEGACY_LINTER Run checkcode on file; count and display unacceptable messages.
% Does not use severity; only UNACCEPTABLE_MESSAGES IDs are counted. Prefer
% lint_with_codeIssues for MATLAB >= R2022b.
%

    linter_message_structs = checkcode ( fpath, "-id" ) ;

    n_of_issues = uint64 ( 0 ) ;

    for lmi = 1 : numel ( linter_message_structs )

        message = linter_message_structs ( lmi ) ;

        if ismember ( message.id, UNACCEPTABLE_MESSAGES, "rows" )

            n_of_issues = n_of_issues + 1 ;

            disp ( " " ) ; % This is needed for exactly one newline between the previous display and the next.

            disp ( "Found unacceptable linter message in " + fpath + ":" ) ;

            disp ( " " ) ; % This is needed for exactly one newline between the previous display and the next.

            disp ( message ) ;

        end % if

    end % for

end % function

function n_of_issues = lint_with_codeIssues(fpath, UNACCEPTABLE_MESSAGES)
%LINT_WITH_CODEISSUES Run codeIssues on file; count unacceptable IDs and errors.
% Counts issues whose CheckID is in UNACCEPTABLE_MESSAGES or whose Severity is "error".
%

    linter_message_struct = codeIssues ( fpath ) ;

    linter_issue_table = linter_message_struct.Issues;

    n_of_table_rows = size(linter_issue_table, 1);

    n_of_issues = uint64 ( 0 ) ;

    for ri = 1 : n_of_table_rows

        issue_table_row = linter_issue_table ( ri, : ) ;

        issue_id = string ( issue_table_row.CheckID );

        issue_severity = string ( issue_table_row.Severity ) ;

        issue_line = issue_table_row.LineStart ;

        issue_description = issue_table_row.Description ;

        if ismember ( issue_id, UNACCEPTABLE_MESSAGES, "rows" ) ...
        || issue_severity == "error"

            n_of_issues = n_of_issues + 1 ;

            disp( " " ) ;

            disp ("Found unacceptable linter message in " + fpath + ":" ) ;

            disp ( " " ) ; % This is needed for exactly one newline between the previous display and the next.

            disp ( "  ID: " + issue_id ) ;

            disp ( "  Severity: " + issue_severity ) ;

            disp ( "  On line: " + issue_line ) ;

            disp ( "  Description: " + issue_description ) ;

        end % if

    end % for

end % function
