function zef = zef_ES_optimizer_properties(zef)
%ZEF_ES_OPTIMIZER_PROPERTIES  Create the optimizer-properties table window (not the solver).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Instantiates zef_ES_optimizer_properties_app. Copy-all menu writes the
%   table to the clipboard. Called from zef_ES_optimizer_properties_show,
%   not from a workbench ButtonPushedFcn by itself.
%
%   zef = zef_ES_optimizer_properties()
%   zef = zef_ES_optimizer_properties(zef)
%
%   See also zef_ES_optimizer_properties_show.
%

if nargin == 0
    zef = evalin('base','zef');
end

zef_data = zef_ES_optimizer_properties_app;

zef.h_ES_optimizer_properties_copy_all  = zef_data.h_ES_optimizer_properties_copy_all;
zef.h_ES_optimizer_properties           = zef_data.h_ES_optimizer_properties;
zef.h_ES_optimizer_properties_table     = zef_data.h_ES_optimizer_properties_table;

zef.h_ES_optimizer_properties.Position(3)       = 1.5 * zef.h_ES_optimizer_properties.Position(3);
zef.h_ES_optimizer_properties_table.Position(3) = 1.54* zef.h_ES_optimizer_properties_table.Position(3);
zef.h_ES_optimizer_properties_table.ColumnName  = {'Parameter name','Unit','Value','Average deviation','Maximum deviation'};

set(findobj(zef.h_ES_optimizer_properties.Children,'-property','FontUnits'),'FontUnits','pixels');
set(findobj(zef.h_ES_optimizer_properties.Children,'-property','FontSize'), 'FontSize',  zef.font_size);

zef.h_ES_optimizer_properties_copy_all.MenuSelectedFcn = 'zef.ES_temp = zef.h_ES_optimizer_properties_table.Data''; clipboard(''copy'',sprintf(''%s\t%5.10g\n'', zef.ES_temp{:})); zef = rmfield(zef,''ES_temp'');';
%% Autoresize
set(zef.h_ES_optimizer_properties,'Name',['ZEFFIRO Interface: ES optimizer properties ' num2str(1+length(findall(groot,'-regexp','Name','ZEFFIRO Interface: ES optimizer properties*')))]);
set(zef.h_ES_optimizer_properties,'AutoResizeChildren','off');
zef.h_ES_optimizer_properties_current_size = get(zef.h_ES_optimizer_properties,'Position');
set(zef.h_ES_optimizer_properties,'SizeChangedFcn', 'zef.h_ES_optimizer_properties_current_size = zef_change_size_function(zef.h_ES_optimizer_properties, zef.h_ES_optimizer_properties_current_size);');

if nargout == 0
    assignin('base','zef',zef);
end
end
