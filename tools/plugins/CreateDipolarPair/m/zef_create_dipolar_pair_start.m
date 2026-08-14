%ZEF_CREATE_DIPOLAR_PAIR_START  Open Create dipolar pair (no default menu).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Not in the default profile INI. Script. Add appends two points to
%   zef.<current_sensors>_points and a ± pair in zef.current_pattern.
%
%   See also zef_create_dipolar_pair_add.
%

zef_data = zeffiro_interface_create_dipolar_pair;
zef.h_create_dipolar_pair = zef_data.UIFigure;
zef.h_create_dipolar_pair_add = zef_data.h_create_dipolar_pair_add;
zef.h_create_dipolar_pair_table = zef_data.h_create_dipolar_pair_table;
zef.h_create_dipolar_pair_plot = zef_data.h_create_dipolar_pair_plot;

set(zef.h_create_dipolar_pair_add,'buttonpushedfcn','zef_create_dipolar_pair_add')

set(zef.h_create_dipolar_pair_plot,'buttonpushedfcn','zef_create_dipolar_pair_plot');

clear zef_data;

set(findobj(zef.h_create_dipolar_pair.Children,'-property','FontSize'),'FontSize',zef.font_size);
set(zef.h_create_dipolar_pair,'AutoResizeChildren','off');
zef.create_dipolar_pair_current_size  = get(zef.h_create_dipolar_pair,'Position');
zef.create_dipolar_pair_relative_size = zef_get_relative_size(zef.h_create_dipolar_pair);
set(zef.h_create_dipolar_pair,'SizeChangedFcn', 'zef.create_dipolar_pair_current_size = zef_change_size_function(zef.h_create_dipolar_pair,zef.create_dipolar_pair_current_size,zef.create_dipolar_pair_relative_size);');

zef.h_create_dipolar_pair.Name = 'ZEFFIRO Interface: Create Dipolar Pair';

zef_create_dipolar_pair_init
