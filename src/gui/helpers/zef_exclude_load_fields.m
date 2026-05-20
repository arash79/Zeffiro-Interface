%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%
%ZEF_EXCLUDE_LOAD_FIELDS
%
%Returns list of field names that should be excluded from automatic loading
%during project load. This prevents loading of very large or problematic
%fields that could cause memory issues or crashes.

function exclude_fields = zef_exclude_load_fields

% Fields that should NOT be automatically loaded
% These are either too large, or should only be loaded on demand
exclude_fields = {
    'dti_tensor'  % DTI tensors can be very large (GB), load only when needed
    % Add other fields here if needed
};

end
