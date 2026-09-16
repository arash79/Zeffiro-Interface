classdef FigureViewContainmentTest < matlab.unittest.TestCase
%FIGUREVIEWCONTAINMENTTEST  Axes stay inside the Figure visualization slot.

    properties
        Figures = gobjects(0)
    end

    methods (TestMethodTeardown)
        function cleanupFigures(testCase)
            for i = 1:numel(testCase.Figures)
                if isgraphics(testCase.Figures(i)) && isvalid(testCase.Figures(i))
                    delete(testCase.Figures(i));
                end
            end
            testCase.Figures = gobjects(0);
        end
    end

    methods (Test)
        function repeatedLayoutDoesNotDrift(testCase)
            f = figure('Visible', 'off', 'Units', 'pixels', ...
                'Position', [40 40 1200 646], 'MenuBar', 'none', ...
                'Name', 'ZEFFIRO Interface: Figure tool', ...
                'AutoResizeChildren', 'off', 'Tag', 'figure_tool');
            testCase.Figures(end+1) = f;
            uipanel(f, 'Tag', 'figure_sidebar', 'Units', 'pixels', ...
                'Position', [650 200 300 400]);
            uipanel(f, 'Tag', 'figure_lists', 'Units', 'pixels', ...
                'Position', [20 12 500 168]);
            uiaxes(f, 'Tag', 'axes1', 'Units', 'pixels', ...
                'Position', [20 200 500 400]);
            uicontrol(f, 'Style', 'pushbutton', 'String', 'Toggle controls', ...
                'Tag', 'togglecontrolsbutton', 'UserData', 1, ...
                'Position', [650 600 120 28]);
            zef_ui_shell('build', f);
            zef_figure_tool_layout(f);
            ax = findall(f, 'Tag', 'axes1');
            view = findall(f, 'Tag', 'figure_view');
            testCase.verifyNotEmpty(view);
            first = local_box(ax);
            for k = 1:8
                zef_figure_tool_layout(f);
            end
            last = local_box(ax);
            testCase.verifyEqual(first, last, 'AbsTol', 1);
            vp = local_box(view);
            testCase.verifyGreaterThanOrEqual(first(1), vp(1) - 1);
            testCase.verifyGreaterThanOrEqual(first(2), vp(2) - 1);
            testCase.verifyLessThanOrEqual(first(1) + first(3), vp(1) + vp(3) + 2);
            testCase.verifyLessThanOrEqual(first(2) + first(4), vp(2) + vp(4) + 2);
        end

        function noThreeDViewTab(testCase)
            f = figure('Visible', 'off', 'Units', 'pixels', ...
                'Position', [40 40 1200 646], 'MenuBar', 'none', ...
                'AutoResizeChildren', 'off', 'Tag', 'figure_tool');
            testCase.Figures(end+1) = f;
            uiaxes(f, 'Tag', 'axes1', 'Units', 'pixels', 'Position', [20 200 500 400]);
            zef_ui_shell('build', f);
            testCase.verifyEmpty(findall(f, 'Tag', 'zef_tab_3d'));
            fig_tab = findall(f, 'Tag', 'zef_tab_figure');
            testCase.verifyNotEmpty(fig_tab);
            testCase.verifyEqual(char(fig_tab.String), 'Figure');
        end

        function gizmoStaysInsideViewOnResize(testCase)
            f = local_shell_figure(testCase, [40 40 1200 720]);
            ax = findall(f, 'Tag', 'axes1');
            testCase.assertNotEmpty(ax);
            ax = ax(1);
            imh = image(ax, 0.94 * ones(24, 32, 3));
            imh.Tag = 'zef_logo_img';
            ax.YDir = 'reverse';
            try
                rmappdata(ax, 'ZefHasVolumePlot');
            catch
            end
            try
                rmappdata(ax, 'ZefLogoSlot');
            catch
            end
            zef_figure_tool_layout(f);
            giz = findall(ax, 'Tag', 'zef_axes_gizmo_img');
            testCase.assertNotEmpty(giz, 'gizmo overlay missing after logo layout');
            inset0 = local_gizmo_inset(ax, giz(1));
            local_verify_gizmo_inside(testCase, ax, giz(1));
            sizes = {[1000 800], [1100 640], [1280 860]};
            for i = 1:numel(sizes)
                f.Position(3:4) = sizes{i};
                zef_figure_tool_layout(f);
                giz = findall(ax, 'Tag', 'zef_axes_gizmo_img');
                testCase.verifyNotEmpty(giz, mat2str(sizes{i}));
                local_verify_gizmo_inside(testCase, ax, giz(1));
                inset = local_gizmo_inset(ax, giz(1));
                testCase.verifyEqual(inset, inset0, 'AbsTol', 2, mat2str(sizes{i}));
            end
        end
    end
end

function f = local_shell_figure(testCase, pos)

if nargin < 2 || isempty(pos)
    pos = [40 40 1200 646];
end
f = figure('Visible', 'off', 'Units', 'pixels', ...
    'Position', pos, 'MenuBar', 'none', 'ToolBar', 'none', ...
    'Name', 'ZEFFIRO Interface: Figure tool', ...
    'AutoResizeChildren', 'off', 'Tag', 'figure_tool');
testCase.Figures(end+1) = f;
uipanel(f, 'Tag', 'figure_sidebar', 'Units', 'pixels', ...
    'Position', [650 200 300 400]);
uipanel(f, 'Tag', 'figure_lists', 'Units', 'pixels', ...
    'Position', [20 12 500 168]);
uiaxes(f, 'Tag', 'axes1', 'Units', 'pixels', ...
    'Position', [20 200 500 400]);
uicontrol(f, 'Style', 'pushbutton', 'String', 'Toggle controls', ...
    'Tag', 'togglecontrolsbutton', 'UserData', 1, ...
    'Position', [650 600 120 28]);
zef_ui_shell('build', f);
zef_figure_tool_layout(f);

end

function local_verify_gizmo_inside(testCase, ax, giz)

xl = double(ax.XLim);
yl = double(ax.YLim);
xd = sort(double(giz.XData));
yd = sort(double(giz.YData));
testCase.verifyGreaterThanOrEqual(xd(1), xl(1) - 0.51);
testCase.verifyLessThanOrEqual(xd(2), xl(2) + 0.51);
testCase.verifyGreaterThanOrEqual(yd(1), yl(1) - 0.51);
testCase.verifyLessThanOrEqual(yd(2), yl(2) + 0.51);
view = ancestor(ax, 'uipanel');
if ~isempty(view) && isvalid(view) && strcmp(char(view.Tag), 'figure_view')
    ap = local_box(ax);
    vp = local_box(view);
    testCase.verifyGreaterThanOrEqual(ap(1), vp(1) - 1);
    testCase.verifyGreaterThanOrEqual(ap(2), vp(2) - 1);
    testCase.verifyLessThanOrEqual(ap(1) + ap(3), vp(1) + vp(3) + 2);
    testCase.verifyLessThanOrEqual(ap(2) + ap(4), vp(2) + vp(4) + 2);
end

end

function inset = local_gizmo_inset(ax, giz)

p = ax.InnerPosition;
xl = double(ax.XLim);
yl = double(ax.YLim);
xd = double(giz.XData);
yd = double(giz.YData);
sx = (xl(2) - xl(1)) / max(1, p(3));
sy = (yl(2) - yl(1)) / max(1, p(4));
from_right = (xl(2) - max(xd)) / sx;
if strcmpi(char(ax.YDir), 'reverse')
    from_top = (min(yd) - yl(1)) / sy;
else
    from_top = (yl(2) - max(yd)) / sy;
end
inset = [from_right, from_top];

end

function pos = local_box(h)

orig = h.Units;
h.Units = 'pixels';
try
    typ = lower(char(h.Type));
catch
    typ = '';
end
try
    if any(strcmp(typ, {'axes', 'uiaxes'}))
        pos = h.InnerPosition;
    else
        pos = h.Position;
    end
catch
    pos = h.Position;
end
h.Units = orig;
p = h.Parent;
while ~isempty(p) && isgraphics(p) && ~strcmpi(char(p.Type), 'figure')
    try
        u = p.Units;
        p.Units = 'pixels';
        pp = p.Position;
        p.Units = u;
        pos(1) = pos(1) + pp(1);
        pos(2) = pos(2) + pp(2);
    catch
        break
    end
    p = p.Parent;
end

end
