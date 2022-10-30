%% plot grand ave waveforms
addpath('../functions/')
task = 'DSCPT';
load(['/labs/srslab/data_main/VJP_ICA/concat.mats/' task '_concat.mat'])
cond_labs = {"Full","Half",'99%','90%'};
figure('units','normalized','outerposition',[.1 .1 .8 .8]);
meas_wind = [80, 130; 320, 400] ;
count = 1;
%% just do an if statement for now
for j = 1:length(conds)
    for jj=1:length(comp_names)
        subplot(length(conds),length(comp_names)*2,count);
        count = count+1;
        waveform = [concat_waveform{:,j,jj}];
        waveform(:,all(isnan(waveform),1)) = [];
        topo = [concat_topo{:,j,jj}];
        topo(:,all(isnan(topo),1)) = [];
        gavg_waveform = myBiweight(waveform);
        gavg_topo  = myBiweight(topo);
        plot(EEG.xmin:1/250:EEG.xmax,gavg_waveform,'LineWidth',1,'Color','black');
        xlim([-.1,.8])
        if jj == 1
        ylim([-2,6])
        elseif jj == 2
            ylim([-.5,1])
        end
        ax = gca;
        rectangle('position',[(meas_wind(jj,1)/1000),ax.YLim(1),(meas_wind(jj,2)/1000)-(meas_wind(jj,1)/1000),ax.YLim(2)-ax.YLim(1)]);
        if j ==4
        xlabel("Time (s)")
        end
        ylabel("Amplitude (µV)")

        title([cond_labs{j}],'FontWeight','normal', 'FontSize',12)
        title_pos = get(gca,'title');
        set(get(gca,'title'),'Position',title_pos.Position + [.55,0,0])
        subplot(length(conds),length(comp_names)*2,count)
        count = count+1;
        topoplot(gavg_topo,EEG.chanlocs); colorbar; colormap("parula"); 
        if jj == 1
            caxis([-2 2]);
        elseif jj == 2
            caxis([-1 1]);
        end 
    end
end
text(-6.05,5.25,'P1','FontSize',14, 'FontWeight','bold','HorizontalAlignment','center')
text(-1.1,5.25,'N2 Diff.','FontSize',14, 'FontWeight','bold','HorizontalAlignment','center')
%% adding some titles here
f = gcf;
exportgraphics(f,['../../pngs/' task '_GAVG_waveforms_and_topos.png'],'Resolution',150)