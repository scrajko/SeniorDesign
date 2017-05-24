function WiFiCUPlots(file_names)
%Takes in a list of files and creates a plot of the amplitude of the 600th
%frequency for each file.
%
%Enter your list of file names in the following format:
%   WiFiCUPlots(['filename1.dat;filename2.dat;filename3.dat']);
%
%Author: Greg Palmer, Sean Rajkowski, Matt Blaschak
%Group: WiFiCU
%Date: 5/9/2017

%Determine number of filenames entered
num_files = size(file_names,1);

%Loop through each file
for i = 1:num_files
    
    %Get File name
    file_name = file_names(i,:);
    %Open file
    f = fopen(file_name);

    %Determine number of FFT's in file
    g = dir(file_name);
    N = (g.bytes/4)/1024;

    %Initialize variable
    freq = zeros(N,1);
    
    %Loop through each FFT
    for j = 1:N

        %Extract specific frequency
        data = fread(f,[1024,1],'float');
        freq(j) = data(530); %530th frequency of the 1024. Slightly off center

    end
    
    %Initialize
    window = 10001;
    half_win = double(idivide(uint32(window),uint32(2)));

    %Find Max
    padded_freq = apply_padding(freq',half_win)';
    freq_max = zeros(N,1);
    for j = half_win+1:N+half_win
        freq_max(j-half_win) = max(padded_freq(j-half_win:j+half_win));
    end
    
    %Convert sample njmber to time
    samp = 0:N-1;
    FFT_size = 1024;
    samp_rate = 10e6;
    samp = samp * (FFT_size/samp_rate);
    
    %Plot figure
    figure
    plot(samp, freq);
    axis([0,inf,0,1.5]);
    title(file_name,'interpreter','none');
    xlabel('Time');
    ylabel('Amplitude');
    
    %Apply median filter to max filter to remove outliers
    decimation_factor = 100;
    median_factor = 5;
    freq_max = decimate(freq_max, decimation_factor);
    freq_max = medfilt1(freq_max,half_win*median_factor/decimation_factor);
    freq_max = interp(freq_max, decimation_factor);
    
    %Plot Max
    figure
    samp3 = 0:size(freq_max, 1)-1;
    samp3 = samp3*(FFT_size/samp_rate);
    plot(samp3', freq_max);
    xlabel('Time (s)');
    ylabel('Max');
    title([file_name,' Max'],'interpreter','none');
    
    %Determine "blocking" threshold
    max_blocking = zeros(size(freq_max));
    lo = min(freq_max);
    hi = max(freq_max);
    threshold = (lo + hi) / 2.5;
    
    %If a value is below the threshold, then someone is blocking
    for j = 1:size(freq_max, 1);
        if (freq_max(j) < threshold)
            max_blocking(j) = 1;
        else
            max_blocking(j) = 0;
        end
    end
    
    %Plot Binary "Is Blocking" Graph
    figure
    plot(samp3, max_blocking);
    title([file_name,' Max Binary Blocking'],'interpreter','none')
    axis([0,inf,-1,2]);
    xlabel('Time (s)');
    ylabel('Blocking');
    
    
end

end

% Assume iamge is a row vector
% (transpose if you have a column vec)
function padded_data = apply_padding(data, pad_amount)
    vec = [0 pad_amount];
    padded_data = padarray(data, vec, 'symmetric', 'both');
end

% Assumes image is a row vector
% (tranpose if you have a column vec)
function unpadded_data = unapply_padding(data, pad_length)
    [~, n] = size(data);
    n = n - 2*pad_length;
    unpadded_data = data(1+pad_length : n+pad_length);
end
