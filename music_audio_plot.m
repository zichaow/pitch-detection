function [] = music_audio_plot(file)
% read audio file
[music, fs] = audioread(file);
music_copy = music;
% create audioplayer object
player = audioplayer(music, fs);

% initialize plot axis range
figure
axis([0 230000 -1 1])

idx = 1;
[len, col] = size(music);
while idx*fs+1 < len
    if idx + fs > len
        play(player, [idx, len])
        plot(music(idx-1:len))
        hold on
    else
        play(player, [idx, idx + fs])
        plot(music(1:1+idx*fs))
        music(1:1+idx*fs) = 0;
        hold on
        
    end
    idx = idx + 1;
end
end
