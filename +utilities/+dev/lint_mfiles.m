function lint_mfiles(folder, kwargs)
%LINT_MFILES  Run code analyzer on all .m files under folder; error on violations.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   lint_mfiles(folder, kwargs)
%
%   kwargs.UNACCEPTABLE_MESSAGES (default NODEF, EVLDOT) and kwargs.linter_fn_name
%   ("codeIssues", "checkcode", or "mlint"). Uses codeIssues on R2022b+.
%   Throws if any unacceptable message or severity "error" is found.

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
