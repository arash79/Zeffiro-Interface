%GUI_RESPONSIVENESS_PROBE  Time startup and a programmatic resize loop.
%
%   Invoked by: matlab -batch "run('scripts/gui_responsiveness_probe.m')"
%   Maintainer helper; not on the default MATLAB path.

root = fileparts(fileparts(mfilename('fullpath')));
cd(root);
addpath(root);

n_run = 3;
t_start = nan(1, n_run);
log_chars = zeros(1, n_run);
n_pos = 0;
n_sz = 0;
t_layout = NaN;
n_layout = 40;

for i = 1:n_run
    try
        if evalin('base', 'exist(''zef'',''var'')')
            zef_old = evalin('base', 'zef');
            try
                zef_old.zeffiro_restart = 1;
                zef_close_all(zef_old);
            catch
            end
            evalin('base', 'clear zef');
        end
    catch
    end
    lastwarn('');
    t0 = tic;
    [txt, zef] = evalc(['zeffiro_interface(' ...
        '''start_mode'', ''nodisplay'', ' ...
        '''use_gpu'', false, ' ...
        '''skip_submodules'', true)']);
    t_start(i) = toc(t0);
    log_chars(i) = numel(txt);
    if i == 1
        h = [];
        try
            h = zef.h_zeffiro;
        catch
        end
        if ~isempty(h) && isgraphics(h) && isvalid(h)
            try
                if isappdata(h, 'ZefMinSizePosListener')
                    lh = getappdata(h, 'ZefMinSizePosListener');
                    n_pos = double(~isempty(lh) && isvalid(lh));
                end
                if isappdata(h, 'ZefMinSizeListener')
                    lh = getappdata(h, 'ZefMinSizeListener');
                    n_sz = double(~isempty(lh) && isvalid(lh));
                end
            catch
            end
            t1 = tic;
            for k = 1:n_layout
                p = h.Position;
                h.Position(3) = p(3) + 8 * (1 - 2 * mod(k, 2));
                zef_figure_tool_layout(h);
            end
            t_layout = toc(t1);
        end
        fprintf('\n--- first-launch captured console (%d chars) ---\n', log_chars(1));
        if numel(txt) > 4000
            fprintf('%s\n... [%d chars truncated] ...\n%s\n', ...
                txt(1:1500), numel(txt) - 3000, txt(end-1499:end));
        else
            fprintf('%s\n', txt);
        end
    end
    try
        zef.zeffiro_restart = 1;
        zef_close_all(zef);
    catch
    end
    evalin('base', 'clear zef');
end

fprintf('\nGUI responsiveness probe\n');
fprintf('  T_application_interactive (nodisplay) runs: %s s\n', mat2str(t_start, 3));
if ~isnan(t_layout)
    fprintf('  Programmatic resize+layout x%d: %.3f s (%.1f ms/call)\n', ...
        n_layout, t_layout, 1000 * t_layout / n_layout);
end
fprintf('  Position PostSet listener present: %d\n', n_pos);
fprintf('  Extra SizeChanged listener present: %d\n', n_sz);
fprintf('  Captured console chars per launch: %s\n', mat2str(log_chars));
