%% Read all SAC files
sacdir = '/home/sirawich/research/processed_data/MERMAID_reports/';
[allsacfiles, sndex] = sacdata(sacdir);

%% Containers for start/end time, timeshift, and correlation coefficient
DUMMY_DATETIME = datetime(2000,1,1,0,0,0,'TimeZone','UTC');
dt_B = DUMMY_DATETIME;
dt_E = DUMMY_DATETIME;
Cmax = zeros(1,sndex);
Cfmax = zeros(1,sndex);
t_shift = zeros(1,sndex);
t_shiftf = zeros(1,sndex);

%% Plots SAC files with respect to raw buffers
savedir = '/home/sirawich/research/plots/interp_matched_SACs/';
for ii = 1:sndex
    [dt_B(1,ii), dt_E(1,ii), Cmax(1,ii), Cfmax(1,ii), ...
        t_shift(1,ii), t_shiftf(1,ii)] = ...
        matchsac(allsacfiles{ii}, getenv('ONEYEAR'), savedir, true);
end

%% plot the time shift vs hour since the beginning
dt_begin = DUMMY_DATETIME;
for ii = 1:sndex
    [sections, intervals] = getsections(getenv('ONEYEAR'),dt_B(1,ii),dt_E(1,ii),40);
    dt_begin(1,ii) = file2datetime(sections{1});
end

t_since = hours((dt_B - dt_begin) + seconds(t_shift));
t_sincef = hours((dt_B - dt_begin) + seconds(t_shiftf));

% remove unmatched records
where = and(t_shiftf > 0, t_shift < 200);
t_since = t_since(where);
t_sincef = t_sincef(where);
t_shift = t_shift(where);
t_shiftf = t_shiftf(where);

% find best fit lines
P = polyfit(t_since, t_shift, 1);
Pf = polyfit(t_sincef, t_shiftf, 1);

figure(7)
scatter(t_since, t_shift, 'Marker', 'x');
hold on
scatter(t_sincef, t_shiftf, 'Marker', '+');
plot(t_since, P(1) * t_since + P(2));
plot(t_sincef, Pf(1) * t_sincef + Pf(2));
hold off
grid on
P_label = sprintf('t-shfit [Raw] = (%6.4f) H + (%6.4f)', P(1), P(2));
Pf_label = sprintf('t-shift [Filtered] = (%6.4f) H + (%6.4f)', Pf(1), Pf(2));
legend('Time shift [Raw]','Time shift [Filtered]',P_label,Pf_label,...
    'Location','northwest');
xlabel('Hours since the beginning of raw data section [hours]');
ylabel('Time shift [s]');
title('Time shift vs Hours since the beginning');
savefile = sprintf('%stimeshift_vs_hours_since_beginning.eps',savedir);
saveas(gcf,savefile,'epsc');

%% plot Raw CC histograms
figure(8)
h = histogram(Cmax(where));
h.BinWidth = 0.05;
grid on
xlabel('Correlation coefficient');
ylabel('Counts');
title_name = strcat('Histogram of Correlation Coefficients between ',...
    'the unfiltered raw buffer and the unfiltered SAC segments');
title(title_name);
savefile = sprintf('%sraw_cc_histogram.eps',savedir);
saveas(gcf,savefile,'epsc');


%% plot Filtered CC histograms
figure(9)
h = histogram(Cfmax(where));
h.BinWidth = 0.05;
grid on
xlabel('Correlation coefficient');
ylabel('Counts');
title_name = strcat('Histogram of Correlation Coefficients between ',...
    'the filtered buffer and the filtered SAC segments');
title(title_name);
savefile = sprintf('%sfiltered_cc_histogram.eps',savedir);
saveas(gcf,savefile,'epsc');
