function zef_ES_plot_error_chart(varargin)
%ZEF_ES_PLOT_ERROR_CHART  Heat maps of zef_ES_table columns on the α/ε grid.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Plot-data menu item 3 and plot_type 3. Does not call
%   zef_ES_error_criteria. Three uitabs (current pattern, volume current,
%   algorithm) with imagesc of table columns; yellow marker at (sc,sr)
%   from zef_ES_objective_function. Nested printing_imagesc draws one panel.
%
%   zef_ES_plot_error_chart()
%   zef_ES_plot_error_chart(zef)
%   zef_ES_plot_error_chart(zef, table_or_interval)
%
%   See also zef_ES_table, zef_ES_objective_function.
%

switch nargin
    case {0, 1}
        if nargin == 0
            zef = evalin('base','zef');
            warning('ZI: No zef were called as an input argument.')
            vec = zef_ES_table(zef.y_ES_interval);
            [sr, sc] = zef_ES_objective_function(zef);
        else
            if isstruct(varargin{1})
                zef = varargin{1};
                try
                    vec = zef_ES_table(zef.y_ES_interval);
                catch
                    error('ZI: Invalid input argument.')
                end
                [sr, sc] = zef_ES_objective_function(zef);
            elseif istable(varargin{1})
                vec = varargin{1};
                zef = evalin('base','zef');
                warning('ZI: No zef were called as an input argument.')
                [sr, sc] = zef_ES_objective_function(zef, vec);
            end
        end

    case {2}
        [zef, arg_aux] = deal(varargin{1}, varargin{2});
        if ~(istable(varargin{2}))
            vec = zef_ES_table(arg_aux);
        end
        [sr, sc] = zef_ES_objective_function(zef, vec);
        
    case {3}
        [vec, sr, sc] = deal(varargin{1}, varargin{2}, varargin{2});
        
    otherwise
        error('ZI: Invalid number of arguments.')
end
%% Figure & Axes
n_chart = 1 + length(findall(groot,'-regexp','Name','ZEFFIRO Interface: Error chart*'));
h_fig = figure('Name',['ZEFFIRO Interface: Error chart ' num2str(n_chart)], ...
    'NumberTitle','off', ...
    'ToolBar','none', ...
    'MenuBar','none');
try
    pos_aux = findall(groot,'Name','ZEFFIRO Interface: ES Workbench').Position;
    set(h_fig,'Position',[pos_aux(1) pos_aux(2) 800 600]);
catch
    movegui(h_fig,'center')
end
pbaspect([1 1 1])
h = uitabgroup();
tab_titles = [{'Current pattern'}; {'Volume current'}; {'Algorithm'}];
fieldnames_table    = {};
fieldnames_table{1} = fieldnames(vec(:, [ 2  1  4  5]));
fieldnames_table{2} = fieldnames(vec(:, [ 3  6  7  9]));
fieldnames_table{3} = fieldnames(vec(:, [12 15]));

for i_idx = 1:3
    fieldnames_table{i_idx} = fieldnames_table{i_idx}(1:end-3);
    tabs_aux = uitab(h, 'title', tab_titles{i_idx});
    axes('parent', tabs_aux);

    for w_aux = 1:length(fieldnames_table{i_idx})
        subplot(2,2,w_aux);
        printing_imagesc(vec, fieldnames_table{i_idx}{w_aux}, sr, sc);
    end
end
%% Wrapping up, functions and return of variables
    function printing_imagesc(vec, fieldnames_table, sr, sc)
        %PRINTING_IMAGESC  One imagesc panel; yellow star at (sc,sr).

        imagesc(vec.(fieldnames_table){:});
        %h_f.ButtonDownFcn = @(s,e) assignin('base', 'xy_click', [round(e.IntersectionPoint(1)), round(e.IntersectionPoint(2))]);
        colormap(gca, turbo(2048));
        pbaspect([1 1 1])

        ax = gca;
        ax.XLabel.String       = 'Alpha parameter (dB)';
        ax.XLabel.FontSize     = 10;
        ax.XLabel.FontWeight   = 'bold';
        ax.XTickLabel          = {num2str((vec.('Alpha'){:}),'%1.0f')};
        ax.XTick               = 1:length(vec.('Alpha'){:});
        ax.XTickLabelRotation  = 90;

        ax.YLabel.String       = 'Nuisance field weight (dB)';
        ax.YLabel.FontSize     = 10;
        ax.YLabel.FontWeight   = 'bold';
        ax.YTickLabel          = {num2str((vec.('Epsilon'){:}),'%1.0f')};
        ax.YTick               = 1:length(vec.('Epsilon'){:});
        ax.YTickLabelRotation  = 0;

        %%% Colorbar TickLabels
        cb = colorbar;
        colormap(cb, turbo(2048))

        %%% Numbers of ticks in the colorbar
        cb_num_ticks = 5;
        T = linspace(cb.Limits(1), cb.Limits(2), cb_num_ticks);
        cb.Ticks = T;

        if     contains(fieldnames_table, 'Total dose')
            TL = arrayfun(@(x) sprintf('%1.3e', x), T, 'un', 0);
        elseif contains(fieldnames_table, 'Maximum current')
            TL = arrayfun(@(x) sprintf('%1.3e', x), T, 'un', 0);
        elseif contains(fieldnames_table, 'Angle error')
            TL = arrayfun(@(x) sprintf('%3.3f', x), T, 'un', 0);
        elseif contains(fieldnames_table, 'Relative magnitude error')
            TL = arrayfun(@(x) sprintf('%1.3f', x), T, 'un', 0);
        else
            TL = arrayfun(@(x) sprintf('%1.3f', x), T, 'un', 0);
        end
        set(cb, 'TickLabels', TL);

        %%% Legend
        hold on;
        plot(ax, sc, sr, 'yp','MarkerFaceColor','y','MarkerEdgeColor','k','MarkerSize',12);
        plot(ax, sc, sr, 'yp','MarkerFaceColor','w','MarkerEdgeColor','w','MarkerSize',12);
        lgd = legend('Location','SouthWest', 'FontName', 'FixedWidth');
        lgd.String(1) = {['\alpha : '   num2str((vec.('Alpha'){:}(sc)), '%1.0f')]};
        lgd.String(2) = {['\epsilon : ' num2str((vec.('Epsilon'){:}(sr)), '%1.0f')]};
        lgd.AutoUpdate = 'off';
        plot(ax, sc, sr, 'yp','MarkerFaceColor','y','MarkerEdgeColor','k','MarkerSize',12);

        %%% Grid
        grid on
        ax.GridAlpha = 0.3;
        ax.GridColor = [0.3 0.3 0.3];

        hold off
        title(fieldnames_table);
    end

if nargin == 0
    h_fig.Visible = zef.use_display;
    zef.h_ES_error_chart = h_fig;
    assignin('caller','zef',zef);
end

end
