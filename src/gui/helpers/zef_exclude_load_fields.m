%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%
%ZEF_EXCLUDE_LOAD_FIELDS
%
%Returns list of field names that should be excluded from automatic loading
%during project load. This prevents loading of very large or problematic
%fields that could cause memory issues or crashes.

function exclude_fields = zef_exclude_load_fields
% --- Zeffiro documentation header ---
% exclude_fields — Exclude fields.
%
% Purpose:
%   Exclude fields.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Calls (project):
%   zef_exclude_load_fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `exclude_fields` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

exclude_fields = {
    'dti_tensor'  % DTI tensors can be very large (GB), load only when needed
    % Add other fields here if needed
};

end
