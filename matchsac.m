function [Cmax, Cfmax, t_shift, t_shiftf] = matchsac(sacfile, merdir, savedir)
% Finds a section in OneYearData that SAC file belongs to
% Then plots xcorr and matched signals
%
% INPUT:
% sacfile       Full filename of the sacfile
% merdir        Directory of the MERMAID files [Default: $ONEYEAR]
% savedir       Directory you wish to save the figures
%
% OUTPUT:
% Cmax          Maximum cross correlation of raw signals
% Cfmax         Maximum cross correlation of filtered signals
% t_shift       Best-fitted time shift for raw signals
% t_shift       Best-fitted time shift for filtered signals
%
% SEE ALSO:
% READSAC, GETSECTIONS, READSECTION, 
%
% Last modified by Sirawich Pipatprathanporn, 02/06/2020

defval('merdir', getenv('ONEYEAR'));

% file name for figures
split_name = split(removepath(sacfile), '.');
filename = cell2mat(split_name(1));

% maximum margin from both end of SAC datetimes in seconds
max_margin = 1200;

% the number of seconds in a day
d2s = 86400;

% reads data from SAC file
[x_sac, Hdr, ~, ~, ~] = readsac(sacfile);
dt_ref = datetime(Hdr.NZYEAR, 1, 0, Hdr.NZHOUR, Hdr.NZMIN, Hdr.NZSEC, ...
    Hdr.NZMSEC) + Hdr.NZJDAY;
dt_B = dt_ref + Hdr.B / d2s;
dt_E = dt_ref + Hdr.E / d2s;

fprintf("Reported section: %s -- %s\n", string(dt_B), string(dt_E));

% finds MERMAID file(s) containing dt_B and dt_E
[sections, intervals] = getsections(merdir, dt_B - max_margin / d2s, ...
    dt_E + max_margin / d2s);
% update max_margin
max_margin = seconds(dt_B - intervals{1}{1});

% reads the section from MERMAID file(s)
% Assuming there is only 1 secion
[x_mer, dt_begin, dt_end] = readsection(sections{1}, intervals{1}{1}, ...
    intervals{1}{2});

% decimates to obtain sampling rate about 10 Hz
fs = 10;
x_sacd = decimate(x_sac, 2);
x_merd = decimate(x_mer, 4);

% applies Butterworth bandpass 0.05-0.10 Hz
x_sacf = bandpass(x_sacd, fs, 0.05, 0.10, 2, 2, 'butter', 'linear');
x_merf = bandpass(x_merd, fs, 0.05, 0.10, 2, 2, 'butter', 'linear');

% finds timeshift for raw SAC signal
C = xcorr(x_merd, x_sacd);
[Cmax, Imax] = max(C);
t_shift = ((Imax - length(x_merd)) / 10) - max_margin;
I = ((1:length(C)) - length(x_merd)) / 10 - max_margin;
figure(1)
plot(I, C);
grid on
title('XCORR [unfiltered]');
xlabel('time shift [s]');
ylabel('XCORR');
savefile = strcat(savedir, filename, '_xcorr_raw.eps');
saveas(gcf, savefile, 'epsc');

fprintf('shifted time [RAW]      = %f s\n', t_shift);

% find timeshift for filtered SAC signal
Cf = xcorr(x_merf, x_sacf);
[Cfmax, Ifmax] = max(Cf);
t_shiftf = ((Ifmax - length(x_merf)) / 10) - max_margin;
I = ((1:length(C)) - length(x_merd)) / 10 - max_margin;
figure(2)
plot(I, Cf);
grid on
title('XCORR [filtered, 0.05-0.10 Hz]');
xlabel('time shift [s]');
ylabel('XCORR');
savefile = strcat(savedir, filename, '_xcorr_fil.eps');
saveas(gcf, savefile, 'epsc');

fprintf('shifted time [FILTERED] = %f s\n', t_shiftf);

% plot raw signals
figure(3);
ax1 = subplot(2,1,2);
ax1 = signalplot(x_sacd, fs, dt_B, ax1, 'Unfiltered SAC');
ax2 = subplot(2,1,1);
ax2 = signalplot(x_merd, fs, dt_begin, ax2, 'Unfiltered MER');
ax1.XLim = ax2.XLim - t_shift / d2s;
ax1.YLim = ax2.YLim;

savefile = strcat(savedir, filename, '_match_raw.eps');
saveas(gcf, savefile, 'epsc');

% plot filtered signals
figure(4);
ax1 = subplot(2,1,2);
ax1 = signalplot(x_sacf, fs, dt_B, ax1, ...
    'Filtered SAC [0.05-0.10 Hz]');
ax2 = subplot(2,1,1);
ax2 = signalplot(x_merf, fs, dt_begin, ax2, ...
    'Filtered MER [0.05-0.10 Hz]');
ax1.XLim = ax2.XLim  - t_shiftf / d2s;
ax1.YLim = ax2.YLim;

savefile = strcat(savedir, filename, '_match_fil.eps');
saveas(gcf, savefile, 'epsc');
end