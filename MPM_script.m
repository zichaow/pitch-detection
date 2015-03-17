W = 2048; % window size
[data, fs] = audioread('violin_test_g4.wav');
f = zeros(1,ceil(length(data)/W));
pointer = 1;
while pointer < length(f)
    f(pointer) = MPM_pitch_detection('violin_test_g4.wav',1+(pointer-1)*W, W);
    pointer = pointer + 1;
end
%f(pointer) = MPM_pitch_detection('violin_test_g4.wav',1+(pointer-1)*W, W);