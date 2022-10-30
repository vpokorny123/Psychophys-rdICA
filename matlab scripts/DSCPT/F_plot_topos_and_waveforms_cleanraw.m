close all
load_dir = '/labs/srslab/data_main/VJP_ICA/binned_clean/';
comp_names = {'P1','N2'};
comp_elecs = {{'PO7', 'PO8', 'P7', 'P8'}, {'Cz','FCz','Fz'}};
meas_wind = [80, 130; 320, 400] ;
prestim = 100;
tbin_wind = round((prestim*250/1000) + (meas_wind*250/1000));
elec_loc = '/labs/srslab/data_main/VJP_ICA/scripts/montages/BrainVision_128_10-10.elp';
conds = {'full','odds','99','90'};
task = 'DSCPT';
concat_waveform = cell(length(subIDs),length(conds),length(comp_names));
concat_topo = cell(length(subIDs),length(conds),length(comp_names));

for j = 1:length(subIDs)
    %% plot individual waveforms
    try
        figure(j)
        subID = subIDs{j};
        sgtitle(subID)
        tic
        for jj = 1:length(conds)
            load([load_dir, subID, '_', task,'_',conds{jj},'_binned.mat'])
            for jjj = 1:length(comp_names)
                timebytrial = squeeze(mean(EEG.data(ismember({EEG.chanlocs.labels}, comp_elecs{jjj}),:,:),1));
                chanbytrial = squeeze(mean(EEG.data(:,tbin_wind(jjj,1):tbin_wind(jjj,2),:),2));
                if strcmp(comp_names{jjj},'P1')
                    waveform = mean(timebytrial,2);
                    topo = mean(chanbytrial,2);
                    subplot(length(conds),length(comp_names)*2,((jj-1)*length(comp_names)*2)+jjj)
                    plot(EEG.xmin:1/250:EEG.xmax,waveform);
                    ax = gca;
                    rectangle('position',[(meas_wind(jjj,1)/1000),ax.YLim(1),(meas_wind(jjj,2)/1000)-(meas_wind(jjj,1)/1000),ax.YLim(2)-ax.YLim(1)]);
                    title([subID ' ' conds{jj} ' ' comp_names{jjj}])
                    subplot(length(conds),length(comp_names)*2,((jj-1)*length(comp_names)*2)+jjj+1)
                    topoplot(topo,elec_loc);
                    concat_topo(j,jj,jjj) =  {topo};
                    concat_waveform(j,jj,jjj) =  {waveform};
                elseif strcmp(comp_names{jjj},'N2')
                    waveform_targ =  mean(timebytrial(:,strcmp(binlabs_cln,'B1')),2);
                    waveform_nontarg =  mean(timebytrial(:,strcmp(binlabs_cln,'B2')),2);
                    topo_targ = mean(chanbytrial(:,strcmp(binlabs_cln,'B1')),2);
                    topo_nontarg = mean(chanbytrial(:,strcmp(binlabs_cln,'B2')),2);
                    topo = topo_targ-topo_nontarg;
                    waveform = waveform_targ-waveform_nontarg;
                    subplot(length(conds),length(comp_names)*2,((jj-1)*length(comp_names)*2)+jjj+1)
                    plot(EEG.xmin:1/250:EEG.xmax,waveform_targ); hold on
                    plot(EEG.xmin:1/250:EEG.xmax,waveform_nontarg); hold on
                    plot(EEG.xmin:1/250:EEG.xmax,waveform);
                    title([subID ' ' conds{jj} ' ' comp_names{jjj}]);
                    ax = gca;
                    rectangle('position',[(meas_wind(jjj,1)/1000),ax.YLim(1),(meas_wind(jjj,2)/1000)-(meas_wind(jjj,1)/1000),ax.YLim(2)-ax.YLim(1)]);
                    subplot(length(conds),length(comp_names)*2,((jj-1)*length(comp_names)*2)+jjj+2);
                    topoplot(topo,elec_loc);
                    concat_topo(j,jj,jjj) =  {topo};
                    concat_waveform(j,jj,jjj) =  {waveform};
                end
            end
        end
    catch
        continue
    end
    toc
end
save(['../../concat.mats/' task '_concat.mat'],'concat_topo','concat_waveform','comp_names','conds','EEG')
