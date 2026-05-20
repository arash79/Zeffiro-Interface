function zef_delete_waitbar

h_waitbar = findall(groot,'-property','ZefWaitbarStartTime');
if isempty(h_waitbar)
    return;
end
try
    set(h_waitbar,'DeleteFcn','');
    delete(h_waitbar);
catch
    % Ignore errors so caller can rely on this not throwing
end

end