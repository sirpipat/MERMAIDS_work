function [x, dt_begin, dt_end] = readsection(file, dt_begin, dt_end, fs)
% [x, dt_begin, dt_end] = READSECTION(file, dt_begin, dt_end, fs)
%
% Reads data from a file and slices the section between dt_begin and dt_end
%
% INPUT:
% file      Full filename
% dt_begin  Datetime of the beginning
% dt_end    Datetime of the end
% fs        Sampling rate in Hz [Default: 40.01406]
%
% OUTPUT:
% x         The data from the section
% dt_begin  Datetime of the beginning of the section
% dt_end    Datetime of the end of the section
%
% SEE ALSO:
% READONEYEARDATA
%
% Last modified by Sirawich Pipatprathanporn: 08/31/2020

defval('fs', 40.01406);

% reads the file
[x, dt_file_begin, dt_file_end] = readOneYearData(file, fs);

defval('dt_begin', dt_file_begin);
defval('dt_end', dt_file_end);

% check if dt_begin and dt_end is valid
if dt_begin >= dt_end || dt_begin > dt_file_end || dt_end < dt_file_begin
    fprintf('ERROR: invalid dt_begin or dt_end\n');
    return
end

dt_begin = max(dt_begin, dt_file_begin);
dt_end = min(dt_end, dt_file_end);

% slices the data
first_index = round(fs * seconds(dt_begin - dt_file_begin) + 1, 0);
last_index = round(fs * seconds(dt_end - dt_file_begin) + 1, 0);
x = x(first_index:last_index);

% fixed dt_begin and dt_end to match the datetimes of first and last 
% sample from the section respectively
dt_begin = dt_file_begin + seconds((first_index - 1) / fs);
dt_end = dt_file_begin + seconds((last_index - 1) / fs);
end