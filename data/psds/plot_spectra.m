adv_spectra_phase1.txt% PLOT_SPECTRA - This script loads the current official projected noise 
% spectra for aLIGO and AdV, and optionally generates plots.
%
% use: Define the following plot-making flags with either a 1 or 0; e.g.:
%   makeVirgo = 1;
%   makeLIGO = 1;


% ---- Formatting.
% axisLimits = [10 1e4 1e-24 1.01e-20];
axisLimits = [10 4e3 1e-24 1.01e-21];
% linestyle = {'b-','g--','r-','k-','m-'};
linestyle = {'b-','g-','r-','k-','m-','y'};
areacolour = {'b','g','r','k','m','y'};
linecolour = {'b',[0.0 0.5 0.0],'r','k','m','y'};
facecolour = [0.4, 0.4, 1; 0.4, 1, 0.4; 1, 0.4, 0.4; 0.2, 0.2, 0.2; 1, 0.4, 1];


% -------------------------------------------------------------------------
%    Read LIGO data.
% -------------------------------------------------------------------------

% ---- Read "Official" early LIGO noise curves.  These were supplied by
%      Lisa Barsotti by email on 2012/07/20.
%      Columns:
%        1  frequency [Hz]
%        2  early low range amplitude spectrum [Hz^-0.5]
%        3  early high range / mid low range amplitude spectrum [Hz^-0.5]
%        4  mid high range / late low range amplitude spectrum [Hz^-0.5]
%        5  late high range amplitude spectrum [Hz^-0.5]
%        6  final design wide-band amplitude spectrum [Hz^-0.5]
%      For the plot we'll use an average of the low- and high-range
%      curves with shading to indicate uncertainties.
data = load('aLIGO_spectra.txt');

% ---- Pack desired spectra into a single struct for convenience.
fligo = data(:,1);   %-- frequencies
jj = 0;         %-- counter
%
jj = jj + 1;
ligo(jj).low  = data(:,2);                      %-- 40 Mpc (from inspiralrange, below)
ligo(jj).high = data(:,3);                      %-- 81 Mpc
ligo(jj).rangelow  = inspiralrange(fligo,ligo(jj).low);
ligo(jj).rangehigh = inspiralrange(fligo,ligo(jj).high);
legendText{jj} = 'Early (2015, 40 - 80 Mpc)';
%
jj = jj + 1;
ligo(jj).low  = data(:,3);                      %--  81 Mpc
ligo(jj).high = data(:,4);                      %-- 121 Mpc
ligo(jj).rangelow  = inspiralrange(fligo,ligo(jj).low);
ligo(jj).rangehigh = inspiralrange(fligo,ligo(jj).high);
legendText{jj} = 'Mid (2016-17, 80 - 120 Mpc)';
%
jj = jj + 1;
ligo(jj).low  = data(:,4);                      %-- 121 Mpc
ligo(jj).high = data(:,5);                      %-- 172 Mpc
ligo(jj).rangelow  = inspiralrange(fligo,ligo(jj).low);
ligo(jj).rangehigh = inspiralrange(fligo,ligo(jj).high);
legendText{jj} = 'Late (2017-18, 120 - 170 Mpc)';
%
jj = jj + 1;
% ---- note: data(:,6) is identical to SRD output.
ligo(jj).low  = (SRD('aLIGO-ZDHP',fligo)).^0.5; %-- 198 Mpc
ligo(jj).high = ligo(jj).low;                   %-- 198 Mpc
ligo(jj).rangelow  = inspiralrange(fligo,ligo(jj).low);
ligo(jj).rangehigh = inspiralrange(fligo,ligo(jj).high);
legendText{jj} = 'Design (2019, 200 Mpc)';
%
jj = jj + 1;
ligo(jj).low  = (SRD('aLIGO-BNS',fligo)).^0.5;  %-- 213 Mpc
ligo(jj).high = ligo(jj).low;                   %-- 213 Mpc
ligo(jj).rangelow  = inspiralrange(fligo,ligo(jj).low);
ligo(jj).rangehigh = inspiralrange(fligo,ligo(jj).high);
legendText{jj} = 'BNS-optimized (215 Mpc)';


% -------------------------------------------------------------------------
%    Make LIGO plot.
% -------------------------------------------------------------------------

if makeLIGO

    % ---- Make plot.
    figure; set(gca,'fontsize',20)
    % ---- Plot shaded region covering best-to-worst-case spectra.
    %      Manually shift the worst-case (best-case) curve down (up) by 2% 
    %      so there is a small space between the bands on the plot -- I
    %      think this will help make the plot readable, especially if
    %      printed in black and white.   
    for ii = 1:length(ligo)
        % ---- Kludge: Sharp spike at ~480 Hz is distracting,
        %      and only one of many lines that will be in the real
        %      spectrum.  Remove it from plot.
        ind = find( fligo<475 | fligo>485 );
        %
        fill([fligo(ind);flipud(fligo(ind))],[0.98*ligo(ii).low(ind);flipud(1.02*ligo(ii).high(ind))], ...
            areacolour{ii},'FaceColor',facecolour(ii,:),'FaceAlpha',0.2, ...
            'LineStyle','none')
        grid on; hold on
    end
    set(gca,'xscale','log')
    set(gca,'yscale','log')
    %
    xlabel('frequency (Hz)')
    ylabel('strain noise amplitude (Hz^{-1/2})');
    title('Advanced LIGO')
    legend(legendText)
    axis(axisLimits);
    saveas(gcf,'fig1_aligo_sensitivity.fig','fig')
    % ---- This looks fine as a stand-alone plot:
    % saveas(gcf,'../fig1_adv_sensitivity.png','png')
    % ---- But this looks a hell of a lot better when imported into the
    %      PDF:
    % ---- Inflate size by 50%.
    pos = get(gcf,'position');
    set(gcf,'position',[pos(1) pos(2) 1.5*pos(3) 1.5*pos(4)]);
    % ---- White background.
    set(gcf,'Color',[1 1 1]);    
    export_fig fig1_aligo_sensitivity.pdf
    [status,result] = system('mv fig1_aligo_sensitivity.pdf ..');

end

% ---- Clean up.
clear fid data ii jj legendText pos


% -------------------------------------------------------------------------
%    Read Virgo data.
% -------------------------------------------------------------------------

% ---- Read "Official" Virgo data.
%      this version: July 24th 2012 AdV sensitivity curves provided by
%      Giovanni Losurdo, with update provided 03 Oct 2012. 
%      -> adv_spectra_phase1.txt contains the curves in power recycling
%         mode.  Columns:
%           1. frequency 
%           2. target sensitivity with 25W ("should not be considered")
%           3. 2015-16  "0" Mpc spectrum (about 0.7 Mpc)
%           4. 2015-16 "20" Mpc spectrum
%           5. 2016-17 "60" Mpc spectrum
%           6. 2017-18 "85" Mpc spectrum (PR mode)
%      -> adv_spectra_phase2.txt contains the curves in "tuned" signal    
%         recycling mode.  Columns:
%           1. frequency 
%           2. design sensitivity at 125W.
%           3. 2018     "85" Mpc spectrum (SR mode)
%           4. 2018-19 "100" Mpc spectrum
%           5. 2019-20 "115" Mpc spectrum
%      The 2018 "85" Mpc spectrum is a worst-case SR curve for the 2018
%      epoch, sent by G. Losurdo 03 Oct 2012.  It was originally committed
%      to CVS as SR2018.txt before being merged into adv_spectra_phase2.txt
%      on 10 Oct 2012. 
% ---- Power recycling spectra.
fid = fopen('adv_spectra_phase1.txt');
a = textscan(fid,'%f %f %f %f %f %f');
fclose(fid);
% ---- Signal recycling spectra.
fid = fopen('adv_spectra_phase2.txt');
b = textscan(fid,'%f %f %f %f %f');
fclose(fid);

% ---- Pack desired spectra into a single struct for convenience.
fvirgo = a{1};   %-- frequencies
jj = 0;          %-- counter
%
jj = jj + 1;
virgo(jj).low  = a{4};               %-- 21 Mpc (from inspiralrange, below)
virgo(jj).high = a{5};               %-- 63 Mpc
virgo(jj).rangelow  = inspiralrange(fvirgo,virgo(jj).low);
virgo(jj).rangehigh = inspiralrange(fvirgo,virgo(jj).high);
legendText{jj} = 'Early (2016-17, 20 - 60 Mpc)';
%
jj = jj + 1;
virgo(jj).low  = a{5};               %-- 63 Mpc
virgo(jj).high = a{6};               %-- 84 Mpc
virgo(jj).rangelow  = inspiralrange(fvirgo,virgo(jj).low);
virgo(jj).rangehigh = inspiralrange(fvirgo,virgo(jj).high);
legendText{jj} = 'Mid (2017-18, 60 - 85 Mpc)';
%
jj = jj + 1;
% ---- Need to take care with the low-frequency limit here - the
%      configuration has changed from no SR to SR, so using the no-SR 
%      curve as the upper limit gives a nonsensical plot at f>~100 Hz.
%      Instead, scale the 100 Mpc SR curve upwards by 15% to give an 85 Mpc
%      range curve.  Match this curve onto the no-SR 85 Mpc range
%      curve at low frequencies to avoid implying a sudden guaranteed leap
%      in low-frequency performance.  As a consequence the final range is
%      actually slightly worse: 81 Mpc.
% ---- Rescale 100 Mpc SR curve to 85Mpc. 
virgo(jj).low  = b{3};               %--  64 Mpc 
virgo(jj).high = b{5};               %-- 115 Mpc
virgo(jj).rangelow  = inspiralrange(fvirgo,virgo(jj).low);
virgo(jj).rangehigh = inspiralrange(fvirgo,virgo(jj).high);
legendText{jj} = 'Late (2018-20, 65 - 115 Mpc)';
%
jj = jj + 1;
virgo(jj).low  = b{2};    %-- 128 Mpc
virgo(jj).high = b{2};    %-- 128 Mpc
virgo(jj).rangelow  = inspiralrange(fvirgo,virgo(jj).low);
virgo(jj).rangehigh = inspiralrange(fvirgo,virgo(jj).high);
legendText{jj} = 'Design (2021, 130 Mpc)';
%
jj = jj + 1;
virgo(jj).low   = (SRD('aVirgo-BNS',fvirgo)).^0.5;    %-- 145 Mpc
virgo(jj).high  = virgo(jj).low;                      %-- 145 Mpc
virgo(jj).rangelow  = inspiralrange(fvirgo,virgo(jj).low);
virgo(jj).rangehigh = inspiralrange(fvirgo,virgo(jj).high);
legendText{jj} = 'BNS-optimized (145 Mpc)';


% -------------------------------------------------------------------------
%    Make Virgo plot.
% -------------------------------------------------------------------------

if makeVirgo

    % ---- Make plot.
    figure; set(gca,'fontsize',20)
    % ---- Now plot shaded error regions.
    for ii = 1:length(virgo)
        % ---- Kludge: Sharp spikes at ~16 Hz and ~437 Hz are distracting,
        %      and only two of many lines that will be in the real
        %      spectrum.  Remove them from plot.
        ind = find( fvirgo<14 | (fvirgo>20 & fvirgo<435) | fvirgo>440 );
        %
        fill([fvirgo(ind);flipud(fvirgo(ind))],[0.98*virgo(ii).low(ind);flipud(1.02*virgo(ii).high(ind))], ...
            areacolour{ii},'FaceColor',facecolour(ii,:),'FaceAlpha',0.2, ...
            'LineStyle','none')
        grid on; hold on
    end
    % ---- Replot 2016-17 and 2017-18 configurations so they appear above
    %      the 2018-20 configuration without screwing up the legend.
    for ii= 1:2
        ind = find( fvirgo<14 | (fvirgo>20 & fvirgo<435) | fvirgo>440 );
        fill([fvirgo(ind);flipud(fvirgo(ind))],[0.98*virgo(ii).low(ind);flipud(1.02*virgo(ii).high(ind))], ...
            areacolour{ii},'FaceColor',facecolour(ii,:),'FaceAlpha',0.2, ...
            'LineStyle','none')
    end
    % ---- Finally, add dotted line along top of 2018-20 configuration.
    ind = find(fvirgo>30 & fvirgo<300);
    loglog(fvirgo(ind),0.98*virgo(3).low(ind),'-.','linewidth',2,'Color',facecolour(3,:))
    %close all
    set(gca,'xscale','log')
    set(gca,'yscale','log')
    %
    xlabel('frequency (Hz)')
    ylabel('strain noise amplitude (Hz^{-1/2})');
    title('Advanced Virgo')
    legend(legendText)
    axis(axisLimits);
    saveas(gcf,'fig1_adv_sensitivity.fig','fig')
    % ---- This looks fine as a stand-alone plot:
    % saveas(gcf,'../fig1_adv_sensitivity.png','png')
    % ---- But this looks a hell of a lot better when imported into the
    %      PDF:
    % ---- Inflate size by 50%.
    pos = get(gcf,'position');
    set(gcf,'position',[pos(1) pos(2) 1.5*pos(3) 1.5*pos(4)]);
    % ---- White background.
    set(gcf,'Color',[1 1 1]);    
    export_fig fig1_adv_sensitivity.pdf
    [status,result] = system('mv fig1_adv_sensitivity.pdf ..');

end

% ---- Clean up.
clear fid a b ii jj w legendText ind pos
