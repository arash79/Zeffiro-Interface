function lf_tag = lf_tag_from_lf_type( lf_type )
% --- Zeffiro documentation header ---
% utilities.leadfield.lf_tag_from_lf_type — Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
%
% Purpose:
%   Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   lf_type
%
% Outputs:
%   lf_tag
%
% Calls (project):
%   utilities.leadfield.lf_tag_from_lf_type
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[lf_tag] = utilities.leadfield.lf_tag_from_lf_type(lf_type)` with project root and `src` on the path.
% --- End Zeffiro documentation header

arguments

    lf_type (1,1) double { mustBeMember( lf_type, [1, 2, 3, 4, 5] ) }

end

if lf_type == 1

    lf_tag = 'EEG' ;

elseif lf_type == 2

    lf_tag = 'MEG' ;

elseif lf_type == 3

    lf_tag = 'gMEG' ;

elseif lf_type == 4

    lf_tag = 'EIT' ;

elseif lf_type == 5

    lf_tag = 'tES' ;

else

    error ( "Unknown lead field type " + lf_type + ". Must be one of 1, 2, 3, 4 or 5." ) ;

end

end % function
