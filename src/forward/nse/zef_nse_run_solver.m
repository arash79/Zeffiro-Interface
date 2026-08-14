%ZEF_NSE_RUN_SOLVER  NSE-tool "Solve system": dispatch by nse_field.solver_type.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Bound to zef.nse_field.h_solve_system in the NSE tool plugin
%   (zef_nse_tool_start). Always calls zef_nse_tool_update first. Does not
%   write zef.L.
%
%   solver_type
%     1  zef_nse_poisson, microcirculation_model=0
%     2  zef_nse_poisson, microcirculation_model=1
%     3  zef_nse_haemodynamic_response_solver, nse_type=2, microcirculation=1
%     4  zef_nse_poisson_dynamic, nse_type=1, microcirculation=0
%     5  dynamic, nse_type=1, microcirculation=1
%     6  dynamic, nse_type=2, microcirculation=0
%     7  dynamic, nse_type=2, microcirculation=1
%
%   Requires zef.nodes, zef.tetra, zef.domain_labels, zef.mvd_length.
%
%   See also zef_nse_poisson, zef_nse_poisson_dynamic, zef_nse_iteration.

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
