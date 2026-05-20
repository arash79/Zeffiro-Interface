% --- Zeffiro documentation header ---
% if zef.nse_field — If zef.nse field.
%
% Purpose:
%   If zef.nse field.
%   Folder: Forward modeling: lead-field FEM assembly, DTI conductivity, NSE, wave models, and PCG solvers.
%
% Zef fields (observed):
%   zef.domain_labels (read)
%   zef.mvd_length (read)
%   zef.nodes (read)
%   zef.nse_field (read, write)
%   zef.tetra (read)
%
% Calls (project):
%   zef_nse_haemodynamic_response_solver
%   zef_nse_poisson
%   zef_nse_poisson_dynamic
%   zef_nse_tool_update
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if zef.nse_field` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

if zef.nse_field.solver_type == 1
    zef = zef_nse_tool_update(zef);
    zef.nse_field.microcirculation_model = 0;
    zef.nse_field = zef_nse_poisson(zef.nse_field,zef.nodes,zef.tetra,zef.domain_labels,zef.mvd_length);
elseif zef.nse_field.solver_type == 2
    zef = zef_nse_tool_update(zef);
    zef.nse_field.microcirculation_model = 1;
    zef.nse_field = zef_nse_poisson(zef.nse_field,zef.nodes,zef.tetra,zef.domain_labels,zef.mvd_length);
elseif zef.nse_field.solver_type == 3
    zef = zef_nse_tool_update(zef);
    zef.nse_field.nse_type = 2;
    zef.nse_field.microcirculation_model = 1;
    zef.nse_field = zef_nse_haemodynamic_response_solver(zef, zef.nse_field,zef.nodes,zef.tetra,zef.domain_labels,zef.mvd_length);
elseif zef.nse_field.solver_type == 4
    zef = zef_nse_tool_update(zef);
    zef.nse_field.nse_type = 1;
    zef.nse_field.microcirculation_model = 0;
    zef.nse_field = zef_nse_poisson_dynamic(zef.nse_field,zef.nodes,zef.tetra,zef.domain_labels,zef.mvd_length);
elseif zef.nse_field.solver_type == 5
    zef = zef_nse_tool_update(zef);
    zef.nse_field.nse_type = 1;
    zef.nse_field.microcirculation_model = 1;
    zef.nse_field = zef_nse_poisson_dynamic(zef.nse_field,zef.nodes,zef.tetra,zef.domain_labels,zef.mvd_length);
elseif zef.nse_field.solver_type == 6
    zef = zef_nse_tool_update(zef);
    zef.nse_field.nse_type = 2;
    zef.nse_field.microcirculation_model = 0;
    zef.nse_field = zef_nse_poisson_dynamic(zef.nse_field,zef.nodes,zef.tetra,zef.domain_labels,zef.mvd_length);
elseif zef.nse_field.solver_type == 7
    zef = zef_nse_tool_update(zef);
    zef.nse_field.nse_type = 2;
    zef.nse_field.microcirculation_model = 1;
    zef.nse_field = zef_nse_poisson_dynamic(zef.nse_field,zef.nodes,zef.tetra,zef.domain_labels,zef.mvd_length);
end
