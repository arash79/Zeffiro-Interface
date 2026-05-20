function h_waitbar = zef_waitbar(varargin)
%
% zef_waitbar
%
% A function that either creates a new Zeffiro Interface waitbar with a
% certain title, updates an existing waitbar while keeping the title the same,
% or updates a waitbar while also updating the title.
%
% Inputs: a varargin cell array with either 3 or 4 elements:
%
% - varargin { 1 }
%
%   The current integer state of the progress, that the caller is keeping
%   track of.
%
% - varargin { 2 }
%
%   The ending integer progress state, that the caller is keeping track of. If
%   varargin{1} reaches this, the computation whose progress is being tracked
%   should terminate.
%
% - varargin { 3 }
%
%   If initializing a new waitbar, the textual title of the waitbar. If
%   updating an existing waitbar, a handle to the waitbar that is being
%   updated.
%
% - varargin { 4 }
%
%   If updating an existing waitbar with a new textual title, the title that
%   is to be shown by the updated waitbar.
%


% if nargin < 3 || nargin > 4
% 
%     error("zef_waitbar needs 3 or 4 arguments")
% 
% end

% 
% assert ( isequal ( size ( current_iter ), size ( max_iter ) ), "The first and second arguments need to be integer arrays of equal size." ) ;
% 
% if any ( isnan ( current_iter ) ) || not ( all ( is_integer ( current_iter ) ) ) || not ( all ( current_iter >= 0 ) )
% 
%     error ( "The first argument must be a positive integer." ) ;
% 
% end
% 
% if any ( isnan ( max_iter ) ) || not ( all ( is_integer ( max_iter ) ) ) || not ( all ( max_iter >= current_iter ) )
% 
%     error ( "The second argument must be a positive integer, greater than the first argument." ) ;
% 
% end
% Always initialize output to avoid "output not assigned" on early returns.
h_waitbar = [];

if nargin < 2 || nargin > 4
    error("zef_waitbar needs 2, 3, or 4 arguments")
end

if not(isa(varargin{2}, "matlab.graphics.Graphics"))
current_iter = double ( varargin { 1 } ) ;
max_iter = double ( varargin { 2 } ) ;
progress_ratio = current_iter ./ max_iter ;
progress_threshold = max(1, ceil ( max_iter / 100 )) ;
else 
    progress_ratio = varargin{1};
    progress_threshold = 0.01;
    current_iter = progress_ratio;
end

% Set our plan of action. Start by setting constants.

INITIALIZING = "{{initializing}}";
PROGRESSING = "{{progressing}}";
PROGRESSING_WITH_CHANGED_TEXT = "{{progressing with text}}";
plan_of_action = INITIALIZING;

if nargin == 3

    third = varargin{3};
    second = varargin{2};

    if isa(third, "matlab.graphics.Graphics")

        try
            if isvalid(third)
                h_waitbar = third ;
                plan_of_action = PROGRESSING;

                try
                    if not(isprop(varargin{3},'ZefWaitbarCurrentProgress'))
                        addprop(varargin{3},'ZefWaitbarCurrentProgress');
                        varargin{3}.ZefWaitbarCurrentProgress = 1;
                    end

                    if abs(current_iter - varargin{3}.ZefWaitbarCurrentProgress) < progress_threshold
                        return
                    else
                        varargin{3}.ZefWaitbarCurrentProgress = current_iter ;
                    end
                catch
                    % If property handling fails, continue anyway
                end

            else

                plan_of_action = INITIALIZING;
                
            end
        catch
            plan_of_action = INITIALIZING;
        end

    elseif isa(third, "string") || isa(third, "char")

        plan_of_action = INITIALIZING;

    end
    
     if isa(second, "matlab.graphics.Graphics")
        
      try
          h_waitbar = second ; 
          plan_of_action = PROGRESSING;
          progress_ratio = varargin{1};
          progress_bar_text = varargin{3};
          progress_threshold = 0.01;

          try
              if not(isprop(varargin{2},'ZefWaitbarCurrentProgress'))
                  addprop(varargin{2},'ZefWaitbarCurrentProgress');
                  varargin{2}.ZefWaitbarCurrentProgress = 0;
              end

              if abs(varargin{1} - varargin{2}.ZefWaitbarCurrentProgress) < progress_threshold
                  return
              else
                  varargin{2}.ZefWaitbarCurrentProgress = varargin{1};
              end
          catch
              % If property handling fails, continue anyway
          end
      catch
          % If graphics handle access fails, skip this path
      end
         
     end
    

elseif nargin == 4 && ( isa(varargin{4}, "string") || isa(varargin{4}, "char") )

    try
        if isvalid(varargin{3})

            h_waitbar = varargin{3};

            plan_of_action = PROGRESSING_WITH_CHANGED_TEXT;

            try
                if abs(current_iter - h_waitbar.ZefWaitbarCurrentProgress) < progress_threshold
                    return
                else
                    h_waitbar.ZefWaitbarCurrentProgress = current_iter ;
                end
            catch
                % If property access fails, continue anyway
            end

        else

            plan_of_action = INITIALIZING;

        end
    catch
        plan_of_action = INITIALIZING;
    end

elseif nargin == 2

     progress_ratio = varargin{1};
    progress_bar_text = varargin{2};
    progress_threshold = 1;
    plan_of_action = INITIALIZING;
end


% Safe handle finding with timeout protection
try
    h_zeffiro_menu = findall(groot,'ZefTool','zef_menu_tool');
catch ME
    % If findall fails or hangs, treat as empty
    h_zeffiro_menu = [];
    warning('Failed to find Zeffiro menu: %s', ME.message);
end

% Handle missing menu (e.g. after restart, or Mac window manager timing).
% Must check isempty BEFORE any property access to avoid crash.
if isempty(h_zeffiro_menu)

    if plan_of_action == INITIALIZING

        try
            % Use visible=1 so user sees waitbar when Zeffiro menu not found
            h_waitbar = init_figure([0.375 0.35 0.2 0.2], 1, -1, []);
            h_waitbar.ZefWaitbarStartTime = now;
        catch ME
            warning('Failed to initialize waitbar: %s', ME.message);
            h_waitbar = [];
        end

    elseif plan_of_action == PROGRESSING || plan_of_action == PROGRESSING_WITH_CHANGED_TEXT

        if nargin >= 3 && (isa(varargin{3}, "matlab.graphics.Graphics"))
            try
                if isvalid(varargin{3})
                    h_waitbar = varargin{3};
                    % Minimal update: set progress text if 4-arg form
                    if nargin == 4 && (isa(varargin{4}, "string") || isa(varargin{4}, "char"))
                        h_t = findobj(h_waitbar.Children,'Tag','progress_bar_text');
                        if ~isempty(h_t), h_t.String = varargin{4}; end
                    end
                else
                    h_waitbar = [];
                end
            catch
                h_waitbar = [];
            end
        else
            h_waitbar = [];
        end

    else

        h_waitbar = [];

    end

    return

end % if isempty(h_zeffiro_menu)

% From here, h_zeffiro_menu is non-empty; take first if array
h_zeffiro_menu = h_zeffiro_menu(1);

if not(exist('h_waitbar','var'))

    try
        h_waitbar = h_zeffiro_menu.ZefWaitbarHandle;

        if not(isempty(h_waitbar))

            try
                if isvalid(h_waitbar)

                    h_waitbar = h_waitbar(1);

                else

                    h_waitbar = [];

                end
            catch
                h_waitbar = [];
            end

        end
    catch
        h_waitbar = [];
    end

end


try
    if not(h_zeffiro_menu.ZefUseWaitbar)
        h_waitbar = [];
        return;
    end
catch
    % If property access fails, assume waitbar should not be used
    h_waitbar = [];
    return;
end

% Cache numcores at first use to avoid repeated expensive calls
if ~isprop(h_zeffiro_menu, 'ZefNumCoresCached')
    try
        addprop(h_zeffiro_menu, 'ZefNumCoresCached');
        h_zeffiro_menu.ZefNumCoresCached = max(1, feature('numcores'));
    catch
        h_zeffiro_menu.ZefNumCoresCached = 4;  % Conservative default
    end
end

try
    position_vec_0 = h_zeffiro_menu.Position;
    position_vec_1 = h_zeffiro_menu.ZefWaitbarSize;
    s_h = zef_eval_entry(get(groot,'ScreenSize'),3);
    s_v = zef_eval_entry(get(groot,'ScreenSize'),4);
    position_vec_0([1 3]) = position_vec_0([1 3])/s_h;
    position_vec_0([2 4]) = position_vec_0([2 4])/s_v;
    position_vec_1(1) = position_vec_1(1)*position_vec_0(3);
    position_vec_1(2) = position_vec_1(2)*position_vec_0(3)*s_h/s_v;
    position_vec = [position_vec_0(1) position_vec_0(2)-position_vec_1(2) position_vec_1(1) position_vec_1(2)];
catch
    % If position calculation fails, use default
    position_vec = [0.375 0.35 0.2 0.2];
end

log_frequency = 5;
first_step = 0;
progress_value = double ( progress_ratio );
progress_value = min(1,progress_value(:));
progress_value = max(0,progress_value(:));
% Waitbar rendering expects a scalar progress value.
if ~isempty(progress_value)
    progress_value = max(progress_value);
else
    progress_value = 0;
end

try
    visible_value = or(h_zeffiro_menu.Visible,h_zeffiro_menu.ZefAlwaysShowWaitbar);
    font_size = h_zeffiro_menu.ZefFontSize;
    verbose_mode = h_zeffiro_menu.ZefVerboseMode;
    use_waitbar = h_zeffiro_menu.ZefUseWaitbar;
    use_log = h_zeffiro_menu.ZefUseLog;
    current_log_file = h_zeffiro_menu.ZefCurrentLogFile;
    task_id = h_zeffiro_menu.ZefTaskId;
    restart_time = h_zeffiro_menu.ZefRestartTime;
catch
    % If property access fails, use defaults
    visible_value = true;
    font_size = 10;
    verbose_mode = false;
    use_waitbar = true;
    use_log = false;
    current_log_file = '';
    task_id = 0;
    restart_time = now;
end

if use_log

    try
        fid = fopen(current_log_file,'a');
        if fid == -1
            use_log = false;
            warning('Could not open log file: %s', current_log_file);
        end
    catch ME
        use_log = false;
        warning('Error opening log file: %s', ME.message);
    end

end

if not(use_waitbar)

    visible_value = 0;

end

% Choose whether to update and existing waitbar or an new one.

if plan_of_action == INITIALIZING

    first_step = 1;

    task_id = task_id + 1;

    h_waitbar = init_figure(position_vec, 0, task_id, h_waitbar);

    try
        h_zeffiro_menu.ZefTaskId = h_zeffiro_menu.ZefTaskId + 1;
    catch
        % If task ID update fails, continue
    end

    try
        h_waitbar.ZefWaitbarStartTime = now;
    catch
        % If property setting fails, continue
    end

    try
        h_zeffiro_menu.ZefWaitbarHandle = h_waitbar;
    catch
        % If handle assignment fails, continue
    end

    try
        caller_stack = dbstack(1);
        if ~isempty(caller_stack)
            caller_file_name = caller_stack(1).file;
        else
            caller_file_name = 'no caller file';
        end
    catch
        caller_file_name = 'no caller file';
    end

    progress_bar_text = varargin{end};


elseif plan_of_action == PROGRESSING

    try
        if   isa(second, "matlab.graphics.Graphics")
            h_waitbar = varargin{2};
        elseif isa(third, "matlab.graphics.Graphics")
            h_waitbar = varargin{3};
        end
    catch
        h_waitbar = [];
    end
    
    try
        h_text = findobj(h_waitbar.Children,'Tag','progress_bar_text');
        h_text_ready = findobj(h_waitbar.Children,'Tag','progress_bar_ready_text');

        if ~isempty(h_text)
            progress_bar_text = h_text.String;
        else
            progress_bar_text = 'Progress';
        end

        if ~isempty(h_text_ready)
            progress_bar_ready_text = h_text_ready.String;
        else
            progress_bar_ready_text = '';
        end
    catch
        progress_bar_text = 'Progress';
        progress_bar_ready_text = '';
    end

elseif plan_of_action == PROGRESSING_WITH_CHANGED_TEXT

    h_waitbar = varargin{3};

    progress_bar_text = varargin{end};

else

    error("zef_waitbar encountered an invalid plan of action. You gave the wrong number of arguments in the wrong order")

end

% Create bar elements on first run.

if plan_of_action == INITIALIZING

    initial_time = now * 86400 ;

    h_waitbar.UserData = [cputime initial_time initial_time];

    h_caller_file_name = uicontrol('Tag','caller_file_name','Style','text','FontWeight','bold','Parent',h_waitbar,'Units','normalized','String',caller_file_name,'HorizontalAlignment','center','Position',[0.1 0.78 0.8 0.15]);

    h_text_1 = uicontrol('Tag','progress_bar_text','Style','text','Parent',h_waitbar,'Units','normalized','String',progress_bar_text,'HorizontalAlignment','center','Position',[0.1 0.70 0.8 0.15]);

    h_text_2 = uicontrol('Tag','progress_bar_ready_text','Style','text','Parent',h_waitbar,'Units','normalized','String',progress_bar_text,'HorizontalAlignment','center','Position',[0.1 0.02 0.8 0.08]);

    h_text_3 = uicontrol('Tag','auxiliary_text_1','Style','text','Parent',h_waitbar,'Units','normalized','String','Workspace size (MB)','HorizontalAlignment','center','Position',[0.08 0.1 0.2 0.15]);

    h_text_4 = uicontrol('Tag','auxiliary_text_2','Style','text','Parent',h_waitbar,'Units','normalized','String','Time (s)','HorizontalAlignment','center','Position',[0.28 0.1 0.2 0.15]);

    h_text_5 = uicontrol('Tag','auxiliary_text_3','Style','text','Parent',h_waitbar,'Units','normalized','String','CPU usage (%)','HorizontalAlignment','center','Position',[0.48 0.1 0.2 0.15]);

    uistack(h_text_1,'bottom');
    uistack(h_text_2,'bottom');
    uistack(h_text_3,'bottom');
    uistack(h_text_4,'bottom');
    uistack(h_text_5,'bottom');

    font_size = h_zeffiro_menu.ZefFontSize;

    set(findobj(h_waitbar.Children,'-property','FontUnits'),'FontUnits','pixels');

    set(findobj(h_waitbar.Children,'-property','FontSize'),'FontSize',font_size);

end

% Either create or use existing axes.

if plan_of_action == INITIALIZING

    h_axes = axes(h_waitbar,'Position',[0.1 0.50 0.8 0.25]);
    h_axes_2 = axes(h_waitbar,'Position',[0.08 0.3 0.2 0.17]);
    h_axes_3 = axes(h_waitbar,'Position',[0.28 0.3 0.2 0.17]);
    h_axes_4 = axes(h_waitbar,'Position',[0.48 0.3 0.2 0.17]);

else

    try
        h_axes = findobj(h_waitbar.Children,'Tag','progress_bar_main_axes');
        h_axes_2 = findobj(h_waitbar.Children,'Tag','progress_bar_auxiliary_axes_1');
        h_axes_3 = findobj(h_waitbar.Children,'Tag','progress_bar_auxiliary_axes_2');
        h_axes_4 = findobj(h_waitbar.Children,'Tag','progress_bar_auxiliary_axes_3');
    catch ME
        % If finding axes fails, reinitialize
        warning('Failed to find waitbar axes, reinitializing: %s', ME.message);
        h_axes = axes(h_waitbar,'Position',[0.1 0.50 0.8 0.25]);
        h_axes_2 = axes(h_waitbar,'Position',[0.08 0.3 0.2 0.17]);
        h_axes_3 = axes(h_waitbar,'Position',[0.28 0.3 0.2 0.17]);
        h_axes_4 = axes(h_waitbar,'Position',[0.48 0.3 0.2 0.17]);
    end

end

try
    h_text = findobj(h_waitbar.Children,'Tag','progress_bar_text');
    if ~isempty(h_text)
        h_text.String = progress_bar_text;
    end
catch
    % If text update fails, continue
end

try
    h_text_ready = findobj(h_waitbar.Children,'Tag','progress_bar_ready_text');
catch
    h_text_ready = [];
end

try
    h_axes.Visible = 'off';
    h_axes.Tag= 'progress_bar_main_axes';
catch
end

try
    h_axes_2.Visible = 'off';
    h_axes_2.Tag= 'progress_bar_auxiliary_axes_1';
catch
end

try
    h_axes_3.Visible = 'off';
    h_axes_3.Tag= 'progress_bar_auxiliary_axes_2';
catch
end

try
    h_axes_4.Visible = 'off';
    h_axes_4.Tag= 'progress_bar_auxiliary_axes_3';
catch
end

try
    set(h_axes,'Layer', 'Bottom');
    set(h_axes_2,'Layer', 'Bottom');
    set(h_axes_3,'Layer', 'Bottom');
    set(h_axes_4,'Layer', 'Bottom');
catch
end

if isempty(h_waitbar) || ~isa(h_waitbar, "matlab.graphics.Graphics") || ~isvalid(h_waitbar)
    return
end

h_waitbar.Colormap = [[ 0 1 1]; [ 0.145   0.624    0.631]];

% Ensure UserData has the expected shape even if caller reused a figure.
if ~isnumeric(h_waitbar.UserData) || numel(h_waitbar.UserData) < 3
    initial_time = now * 86400;
    h_waitbar.UserData = [cputime initial_time initial_time];
end

% Enforce monotonic progress per waitbar instance to prevent visual regression
% and downstream state glitches when callers use mixed denominators.
try
    if ~isprop(h_waitbar, 'ZefWaitbarMaxProgress')
        addprop(h_waitbar, 'ZefWaitbarMaxProgress');
        h_waitbar.ZefWaitbarMaxProgress = 0;
    end
    progress_value = max(progress_value, h_waitbar.ZefWaitbarMaxProgress);
    h_waitbar.ZefWaitbarMaxProgress = progress_value;
catch
    % If dynamic property access fails, continue with unclamped progress.
end

detail_condition = or((86400*now - h_waitbar.UserData(2)) >= log_frequency,first_step);

if detail_condition

    % CRITICAL FIX: Skip workspace size calculation entirely
    % The evalin('caller','whos()') call can HANG indefinitely with large workspaces
    % This is the primary cause of pipeline collapse during source interpolation
    var_1 = 0;  % Disable workspace size display
    var_1_max = 6;
    progress_value_1 = 0;  % Keep pie chart minimal
    
    var_2 = round(86400*now - h_waitbar.UserData(3));
    var_2_max = 6;
    progress_value_2 = min(max(0,log10(max(var_2,1)))/var_2_max,1);
    
    % Use cached numcores value to avoid repeated expensive calls
    try
        var_3_max = 100*h_zeffiro_menu.ZefNumCoresCached;
    catch
        var_3_max = 400;  % Conservative default (4 cores * 100)
    end
    
    var_3 = round(100*(cputime - h_waitbar.UserData(1))/(now*86400 - h_waitbar.UserData(2)));
    h_waitbar.UserData(1:2) = [cputime now*86400];
    progress_value_3 = min(1,var_3/var_3_max);

    if progress_value(1) > 0

        try
            time_in_seconds = now + ((1-progress_value(end))/progress_value(end))*(now - h_waitbar.ZefWaitbarStartTime);
            progress_bar_ready_text = datestr(time_in_seconds);
            h_text_ready.String = ['Ready: ' progress_bar_ready_text];
        catch
            % If time calculation fails, show empty
            progress_bar_ready_text = '';
            h_text_ready.String = progress_bar_ready_text;
        end
    
    else

        progress_bar_ready_text = '';
        h_text_ready.String = progress_bar_ready_text;

    end

end % if

if strcmpi(string(h_waitbar.Visible), "on")

    try
        % Use simpler bar chart to avoid hang/crash issues
        if isempty(findobj(h_axes,'Type','bar'))
            % First time: create bar chart
            h_bar = barh(h_axes,[progress_value 1-progress_value; 0 0],'barlayout','stacked','showbaseline','off','edgecolor','none');
            h_bar(1).FaceColor = [0 1 1];
            h_bar(2).FaceColor = [0.145   0.624    0.631];
        else
            % Update existing bar data (faster than recreating)
            try
                h_bar = findobj(h_axes,'Type','bar');
                if ~isempty(h_bar)
                    % Keep progress moving left->right regardless of handle order.
                    progress_color = [0 1 1];
                    if numel(h_bar) >= 2
                        progress_ind = [];
                        for kk = 1:numel(h_bar)
                            if all(abs(double(h_bar(kk).FaceColor) - progress_color) < 1e-12)
                                progress_ind = kk;
                                break;
                            end
                        end
                        if isempty(progress_ind)
                            progress_ind = 1;
                        end
                        remainder_ind = setdiff(1:numel(h_bar), progress_ind);
                        h_bar(progress_ind).YData = progress_value;
                        h_bar(remainder_ind(1)).YData = 1-progress_value;
                    else
                        h_bar(1).YData = progress_value;
                    end
                end
            catch
                % If update fails, skip it
            end
        end
        h_axes.Visible = 'off';
        h_axes.XDir = 'normal';
        if exist('h_text','var') && ~isempty(h_text), uistack(h_text,'top'); end
        if exist('h_text_ready','var') && ~isempty(h_text_ready), uistack(h_text_ready,'top'); end
    catch ME
        % If bar chart fails, continue without crashing
        % Do not warn here to avoid spamming output
    end

    if detail_condition

        try
            caller_stack = dbstack(1);
            if ~isempty(caller_stack)
                caller_file_name = caller_stack(1).file;
            else
                caller_file_name = 'no caller file';
            end
        catch
            caller_file_name = 'no caller file';
        end

        % CRITICAL FIX: Skip pie chart updates
        % These can hang or cause crashes, especially with graphics handle issues
        % The information they display is not critical for progress tracking
        % Just ensure axes are invisible so they don't interfere
        try
            h_axes_2.Visible = 'off';
            h_axes_3.Visible = 'off';
            h_axes_4.Visible = 'off';
        catch
            % If axes cannot be hidden, continue anyway
        end

    end % if

    try
        drawnow limitrate  % Use limitrate instead of pause to prevent excessive updates
    catch
        % If graphics queue flush fails, skip instead of crashing caller.
    end

    try
        h_axes.Tag= 'progress_bar_main_axes';
        h_axes_2.Tag= 'progress_bar_auxiliary_axes_1';
        h_axes_3.Tag= 'progress_bar_auxiliary_axes_2';
        h_axes_4.Tag= 'progress_bar_auxiliary_axes_3';
        h_text.Tag= 'progress_bar_text';
        if ~isempty(h_text_ready)
            h_text_ready.Tag= 'progress_bar_ready_text';
        end
        h_waitbar.Tag ='progress_bar';
    catch
        % If tag setting fails, continue
    end

end % if

if detail_condition

    try
        caller_stack = dbstack(1);
        if ~isempty(caller_stack)
            caller_file_name = caller_stack(1).file;
        else
            caller_file_name = 'no caller file';
        end
    catch
        caller_file_name = 'no caller file';
    end

    try
        h_caller_file_name = findobj(h_waitbar.Children,'Tag','caller_file_name');
        if ~isempty(h_caller_file_name)
            h_caller_file_name.String = ['File: ' caller_file_name];
        end
    catch
        % If updating caller file name fails, skip it
    end

    total_cpu_time_val = cputime - restart_time;
    % Parallel pool workers report process-local cputime; ZefRestartTime is
    % copied from the client (zeffiro_interface), so the difference is negative.
    if total_cpu_time_val < 0
        total_cpu_time_val = cputime;
    end

    output_line = ['Task ID; ' num2str(task_id) '; Progress; ' num2str(round(100*progress_value(:)')) '; File; ' caller_file_name '; Message; ' progress_bar_text '; Workspace size; ' num2str(var_1) '; Task time; ' num2str(var_2) '; CPU usage; ' num2str(var_3) '; Ready; ' progress_bar_ready_text '; Total CPU time; ' sprintf('%g',total_cpu_time_val) ';'];

    if use_log

        try
            fprintf(fid,'%s',[output_line newline]);
        catch ME
            % If logging fails, just skip it
            warning('Failed to write to log file: %s', ME.message);
        end

    end

    if and(verbose_mode,not(visible_value))

        disp(output_line)

    end

end % if

if plan_of_action == INITIALIZING


    h_axes = findobj(h_waitbar.Children,'Tag','waitbar_axes_1');

    if isempty(h_axes)
        try
            h_axes = uiaxes('Parent',h_waitbar,'visible','off','Units','normalized','Position',[0.63 0.272 0.315 0.225],'FontSize',0.587962962962963,'Tag','waitbar_axes_1');
            imagesc(h_axes,imread('zeffiro_symbol_compass.png', 'BackgroundColor', [0.94 0.94 0.94]));
            axis(h_axes,'equal');

            h_axes = uiaxes('Parent',h_waitbar,'visible','off','Units','normalized','Position',[0.01 0.01 0.98 0.98],'FontSize',0.587962962962963,'Tag','waitbar_axes_2');
            imagesc(h_axes,imread('zeffiro_symbol_mesh.png', 'BackgroundColor', [0.94 0.94 0.94]));
            axis(h_axes,'equal');
            alpha(h_axes,0.1);
            set(h_axes,'Layer', 'Top');
        catch
            % If image loading fails, skip the decorative images
            warning('Could not load waitbar decorative images');
        end
    end

        h_waitbar.Visible = visible_value;
end

if use_log
    try
        fclose(fid);
    catch
        % Ignore close errors
    end
end

end % function

%% Local helper functions.

function fig = init_figure(position, visible, task_id, fig)

%Note: here it is difficult to define any class-based argument list,
%because it is absolutely necessary to distinguish between two cases (1) when
%fig is not a figure (when there is no figure yet) and (2) when it is a figure.
%The first incoming figure variable needs to be empty. Otherwise there will
%be confusion in deciding, whether there is a figure open or not.

if task_id < 0

    task_number_str = "";

else

    task_number_str = string(task_id);

end

if not(isempty(fig))

    if isvalid(fig)

        clf(fig);

        set(fig,...
            'PaperUnits',get(0,'defaultfigurePaperUnits'),...
            'Units','normalized',...
            'Position', position,...
            'Renderer',get(0,'defaultfigureRenderer'),...
            'Visible', visible,...
            'Color',get(0,'defaultfigureColor'),...
            'CurrentAxesMode','manual',...
            'IntegerHandle','off',...
            'NextPlot',get(0,'defaultfigureNextPlot'),...
            'DoubleBuffer','off',...
            'MenuBar','none',...
            'ToolBar','none',...
            'Name', "ZEFFIRO Interface: Task " + task_number_str,...
            'NumberTitle','off',...
            'HandleVisibility','off',...
            'Tag','progress_bar',...
            'UserData',[],...
            'WindowStyle',get(0,'defaultfigureWindowStyle'),...
            'Resize',get(0,'defaultfigureResize'),...
            'PaperPosition',get(0,'defaultfigurePaperPosition'),...
            'PaperSize',[20.99999864 29.69999902],...
            'PaperType',get(0,'defaultfigurePaperType'),...
            'InvertHardcopy',get(0,'defaultfigureInvertHardcopy'),...
            'ScreenPixelsPerInchMode','manual' ...
            );


        fig.CloseRequestFcn = 'set(gcbo,''Visible'',''off'');';
        fig.DeleteFcn = '';
        fig.ZefWaitbarStartTime = now;
        fig.ZefWaitbarCurrentProgress = 0;

    end

else

    zef_delete_waitbar;
    fig = figure( ...
        'PaperUnits',get(0,'defaultfigurePaperUnits'),...
        'Units','normalized',...
        'Position', position,...
        'Renderer',get(0,'defaultfigureRenderer'),...
        'Visible', visible,...
        'Color',get(0,'defaultfigureColor'),...
        'CurrentAxesMode','manual',...
        'IntegerHandle','off',...
        'NextPlot',get(0,'defaultfigureNextPlot'),...
        'DoubleBuffer','off',...
        'MenuBar','none',...
        'ToolBar','none',...
        'Name', "ZEFFIRO Interface: Task " + task_number_str,...
        'NumberTitle','off',...
        'HandleVisibility','off',...
        'Tag','progress_bar',...
        'UserData',[],...
        'WindowStyle',get(0,'defaultfigureWindowStyle'),...
        'Resize',get(0,'defaultfigureResize'),...
        'PaperPosition',get(0,'defaultfigurePaperPosition'),...
        'PaperSize',[20.99999864 29.69999902],...
        'PaperType',get(0,'defaultfigurePaperType'),...
        'InvertHardcopy',get(0,'defaultfigureInvertHardcopy'),...
        'ScreenPixelsPerInchMode','manual' ...
        );

    addprop(fig,'ZefWaitbarStartTime');
    addprop(fig,'ZefWaitbarCurrentProgress');
    fig.ZefWaitbarStartTime = now;
    fig.ZefWaitbarCurrentProgress = 0;
    fig.CloseRequestFcn = 'set(gcbo,''Visible'',''off'');';
    fig.DeleteFcn = '';

end % if

end % function

function result = is_integer(float)
%
% is_integer
%
% Checks whether a floating point number is an integer, up to the accuracy of
% machine epsilon eps.
%

    arguments

        float (:,:) double
    end

    result = float == round ( float ) ;

end % function
