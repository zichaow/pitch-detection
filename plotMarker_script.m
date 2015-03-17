%% load some audio data (available with MATLAB)
[y,Fs] = audioread('violin_test_song.wav');

%% create the plot of audio samples
figure; hold on;
%plot(y, 'b'); % plot audio data
title('Audio Data');
xlabel(strcat('Sample Number (fs = ', num2str(Fs), ')'));
ylabel('Amplitude');
ylimits = get(gca, 'YLim'); % get the y-axis limits
plotdata = [ylimits(1):0.1:ylimits(2)];
%hline = plot(repmat(0, size(plotdata)), plotdata, 'r'); % plot the marker

%% instantiate the audioplayer object
player = audioplayer(y, Fs);

%% setup the timer for the audioplayer object
player.TimerFcn = {@plotMarker, player, gcf, plotdata}; % timer callback function (defined below)
player.TimerPeriod = 0.01; % period of the timer in seconds

%% start playing the audio
% this will move the marker over the audio plot at intervals of 0.01 s
play(player);

