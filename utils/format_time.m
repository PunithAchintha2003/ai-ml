function timeStr = format_time(seconds)
%% FORMAT_TIME - Format elapsed time in human-readable format
% Input:
%   seconds: elapsed time in seconds
% Output:
%   timeStr: formatted string (e.g., "2h 15m 30s")

    if seconds < 60
        timeStr = sprintf('%.1f seconds', seconds);
    elseif seconds < 3600
        minutes = floor(seconds / 60);
        secs = mod(seconds, 60);
        timeStr = sprintf('%dm %.1fs', minutes, secs);
    else
        hours = floor(seconds / 3600);
        minutes = floor(mod(seconds, 3600) / 60);
        secs = mod(seconds, 60);
        timeStr = sprintf('%dh %dm %.1fs', hours, minutes, secs);
    end
end

