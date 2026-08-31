function zef_plot_dpq(type,zef)
%ZEF_PLOT_DPQ  Eval enabled queue rows of type 'static' or 'dynamical'.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Walks zef.dynamical_plot_queue_table. For each row whose column 2
%   passes str2num and whose column 3 equals type, evalin('caller',
%   column 1). That is how bank overlays (zef_plot_synthetic_source, …)
%   run on the current mesh axes. Called from zef_plot_meshes /
%   zef_plot_volume / zef_print_meshes / zef_play_cdata, not from the
%   queue window.
%
%   zef_plot_dpq(type)
%   zef_plot_dpq(type, zef)
%
%   type is 'static' or 'dynamical'. With one argument, zef is taken from
%   the caller if present. Empty zef is a no-op. Visualization wraps the
%   call in try/catch and warns on failure.
%
%   See also zef_dpq_window, zeffiro_interface_dynamical_plot_queue.

if nargin == 1
    if evalin('base','exist(''zef'',''var'');')
        zef = evalin('caller','zef');
    else
        zef = [];
    end
end

if not(isempty(zef))

    dpq_table = eval('zef.dynamical_plot_queue_table');

    for dpq_ind = 1 : size(dpq_table,1)

        if str2num(dpq_table{dpq_ind,2})
            if isequal(dpq_table{dpq_ind,3},type)

                evalin('caller', dpq_table{dpq_ind,1});

            end
        end
    end
end
end
