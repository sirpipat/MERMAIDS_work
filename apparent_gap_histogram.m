function apparent_gap_histogram(direction)
% APPARENT_GAP_HISTOGRAM(direction)
% plots histograms of apparent gap between files
% assuming the sampling frequency to be 40 Hz
%
% INPUT:
% direction   0 - Using the filename as the start time  [Default]
%             1 - Using the filename as the end time
%
% OUTPUT:
% no output
%
% SEE ALSO:
% ONEYEARDATA, FILE2DATETIME, READ_FILESIZE
%
% Last modified by Sirawich Pipatprathanporn: 03/01/2020

defval('direction',0);

fs = 40;
DUMMY_DATETIME = datetime(0,0,0,0,0,0,'TimeZone','UTC');

% read the begin datetimes
ddir = getenv('ONEYEAR');
[allfiles, fndex] = oneyeardata(ddir);
allbegins = [DUMMY_DATETIME];
for ii = 1:fndex
    allbegins(ii) = file2datetime(allfiles{ii});
end

% read the length of the files. Then, convert to duration
[allfilelengths, ~] = read_filesize();
alldurs = seconds((allfilelengths - 1) / fs);
if direction == 1
    alldurs = circshift(alldurs,-1,2);
end

% calculate apparent gaps
allgaps = circshift(allbegins,-1,2) - allbegins - alldurs;
allgaps = allgaps(1:length(allgaps)-1);

% plot histogram
figure(2)
ax = subplot(3,1,1);
h = histogram(allgaps);
h.BinWidth = hours(1);
xlabel('Gap length (hh:mm:ss) [bin width = 1 hour]');
ylabel('Counts');
ax.TickDir = 'both';
ax.Title.String = 'Histogram of apparent gap lengths [filename = begin time]';
grid on

ax = subplot(3,1,2);
h = histogram(allgaps);
h.BinWidth = minutes(0.5);
xlim([minutes(-5) minutes(5)]);
xlabel('Gap length (hh:mm:ss) [bin width = 0.5 minute]');
ylabel('Counts');
ax.TickDir = 'both';
% ax.YScale = 'log';
% ylim([0.5 500]);
ax.Title.String = 'Histogram of apparent gap lengths';
grid on

ax = subplot(3,1,3);
h = histogram(allgaps);
h.BinWidth = minutes(5);
xlim([hours(22) hours(23)]);
ylim([0 20]);
grid on
xlabel('Gap length (hh:mm:ss) [bin width = 5 minutes]');
ylabel('Counts');
ax.TickDir = 'both';
ax.Title.String = 'Histogram of apparent gap lengths';
end