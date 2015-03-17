%% ------------------------------------------------------------------------
%% the timer callback function definition
function plotMarker(...
    obj, ...            % refers to the object that called this function (necessary parameter for all callback functions)
    eventdata, ...      % this parameter is not used but is necessary for all callback functions
    player, ...         % we pass the audioplayer object to the callback function
    figHandle, ...      % pass the figure handle also to the callback function
    plotdata)           % finally, we pass the data necessary to draw the new marker

% check if sound is playing, then only plot new marker
if strcmp(player.Running, 'on')
    
    % get the handle of current marker and delete the marker
    %hMarker = findobj(figHandle, 'Color', 'r');
    %delete(hMarker);
    
    % get the currently playing sample
    x = player.CurrentSample;
    
    % plot the new marker
    plot(repmat(x, size(plotdata)), plotdata, 'r');

end

