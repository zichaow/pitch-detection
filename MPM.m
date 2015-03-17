%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Matlab Implementation of MPM pitch detection algorithm  %%
% Version V2.0
% Date: March 16, 2015
% Author: Zichao Wang
%% Documentation
% This Function implements the MPM pitch detection algorithm
% by Dr. Pilip McLeod. You can read more about this algorithm
% in his paper titled "a smarter way to find pitch". The
% algorithm first calculates a normalized square difference
% function, and then find all local maxima, then threshold 
% them, and use the first maxima as the key maxima. Its index
% is recorded as the pitch period. Using this pitch period, we
% are able to find the pitch of the sample.
%% Input
% filename: The file name of your music.
% W:        Window size to perform MPM algorithm. Typically
%           value is 2048. You can also use 512, 1024, 4096.
%% Output
% f:    detected frequency for the entire music file
% note: detected pitch in MIDI scale for the entire music file
%       (MIDI scale: http://newt.phys.unsw.edu.au/jw/notes.html)
%% Example:
%  filename = '153597__carlos-vaquero__violin-g-5-tenuto-non-vibrato.wav';
%  W = 2048;
%  [f,note] = MPM_pitch_detection('153597__carlos-vaquero__violin-g-5-...
% tenuto-non-vibrato.wav', 2048)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

function [F,NOTE] = MPM(filename, W)

    [violin,fs] = audioread(filename);
    violin = violin(:,1);
    %size(violin)

    %% initialize parameters and vectors
    step = W/4;                             % increment by W/4 (75% overlap)
    F = zeros(1,ceil(length(violin)/step)); % initialize the frequency vector
    NOTE = zeros(size(F));                  % initialize the pitch vector

    %%  getting samples
    t = 1; % start time
    sample = 1; % record which sample the algorithm is currently calculating
    while t + W < length(violin)
        x = violin(t:W+t-1); 
        th_amp = 0.01; % set amplitude threshold to ignore noise
        if length(find(x<th_amp)) >= 2/3*length(x) % if amplitude too small, ignore this sample
            F(sample) = -1;     % set this frequency to be "null"
            NOTE(sample) = -1;  % set this pitch to be "null"
        else % perform the algorithm when amplitude is larger than amplitude threshold
            [f, note] = find_pitch(x,W,fs);% find pitch for this sample
            F(sample) = f;              % assign frequency to F vector
            NOTE(sample) = note;        % assign pitch to NOTE vector
        end
        sample = sample + 1;% increment sample
        t = t + step;          % increment start time
    end
    figure
    plot(F)
    xlabel('sample')
    ylabel('frequency')
    Title1 = sprintf('frequency result on %s', filename);
    title(Title1)
    figure
    plot(NOTE)
    xlabel('sample')
    ylabel('pitch')
    Title2 = sprintf('pitch result on %s', filename);
    title(Title2)
    
function [f, note] = find_pitch(x,W,fs)
    r_tau = zeros(1,W);                     % initialize ACF
    m_tau = zeros(1,W);                     % initialize SDF
    n_tau = zeros(1,W);                     % initialize NSDF
    %% calculate NSDF (normalized square difference function)
    for tau = 0:W-1
       for j = 1:1+W-tau-1
          r_tau(tau+1) = r_tau(tau+1) + x(j)*x(j+tau); % calculate ACF
          m_tau(tau+1) = m_tau(tau+1) + (x(j)^2+ x(j+tau)^2);%calculate SDF
          n_tau(tau+1) = 2*r_tau(tau+1)/m_tau(tau+1); % calculate NSDF
       end
    end
    %% find local maxima
    MAX = max(n_tau); % maximum correlation in NSDF (usually 1)
    k = 0.8; % threshold parameter
    th = MAX*k; % threshold for selecting key maximum
    idx = 2; % starting index, excluding the first data point, which is 1
    max_idx = 0; % the index of the key maximum. To be changed later
    temp = find(n_tau<0); % for finding index of first negative element
    local_max = zeros(1,W); % local maximum in NSDF
    while idx < length(n_tau)-1 % for each sample
        temp_max = 0;
        while n_tau(idx) > 0 && idx < W && idx > temp(1) 
        % for sample starting from the second arising pattern
           if n_tau(idx+1) > n_tau(idx)
               if temp_max < n_tau(idx+1)
                   temp_max = n_tau(idx+1); 
               end
           end
           idx = idx + 1;
        end
        max_idx = find(n_tau==temp_max);
        local_max(max_idx) = temp_max;
        idx = idx + 1;
    end
    %% find pitch and fundamental frequency
    tau = find(local_max>th); % pitch period
    if ~isempty(tau) % check if there is a key maximum
        f = fs / tau(1); % corresponding frequency
        %note = log10(f/27.5)/log10(2^(1/12));
        note = round((12 * log10(f/440)/log10(2)) + 69); % Convert to midi mappings
    else
        f = -1;
        note = -1;
    end
    if note < 0 % deal with noise / no sound
        f = -1;
        note = -1;
    end
    %plot(n_tau);
