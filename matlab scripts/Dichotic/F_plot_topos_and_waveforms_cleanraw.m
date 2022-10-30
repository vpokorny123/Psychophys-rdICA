  %the elecs we want for the P3 are P1, Pz,P2, PO3, PO4, POz
  % which is A05, A19, A32, A17, A30, A10
  %N1 is F1, Fz, F2, FC1, FCz, FC2, Cz
  % which is C25, C21, C12, C24, C23, C11, A01

close all
prestim = 150; 
load_dir = '/labs/srslab/data_main/VJP_ICA/binned_clean/';
conds = {'full','odds','99','90'};
task = 'Dichotic';
comp_names = {'N1','P3'};
comp_elecs_raw = {{'C25', 'C21', 'C12', 'C24', 'C23', 'C11', 'A01'},{'A05', 'A19', 'A32', 'A17', 'A30', 'A10'}};
meas_wind = [50, 180; 250, 500] ;

load('/labs/srslab/static_files/shared_apps/matlab_toolboxes/ssk_eegtoolbox/ICAcleanEEG.v.1.3/montage/BioSemi_128_elecN_cart.mat')

comp_elecs = {};
for j = 1:length(comp_elecs_raw)
    [~,inds]=ismember(comp_elecs_raw{j},elecnames);
    comp_elecs(j) = {inds};
end

tbin_wind = round((prestim*250/1000) + (meas_wind*250/1000));
% just using this to get the indices for the different elec numbers
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
                timebytrial = squeeze(mean(EEG.data(comp_elecs{jjj},:,:),1));
                chanbytrial = squeeze(mean(EEG.data(:,tbin_wind(jjj,1):tbin_wind(jjj,2),:),2));
                if strcmp(comp_names{jjj},'N1')
                    waveform = mean(timebytrial,2);
                    topo = mean(chanbytrial,2);
                    subplot(length(conds),length(comp_names)*2,((jj-1)*length(comp_names)*2)+jjj)
                    plot(EEG.xmin:1/250:EEG.xmax,waveform);
                    ax = gca;
                    rectangle('position',[(meas_wind(jjj,1)/1000),ax.YLim(1),(meas_wind(jjj,2)/1000)-(meas_wind(jjj,1)/1000),ax.YLim(2)-ax.YLim(1)]);
                    title([subID ' ' conds{jj} ' ' comp_names{jjj}])
                    subplot(length(conds),length(comp_names)*2,((jj-1)*length(comp_names)*2)+jjj+1)
                    topoplot(topo,EEG.chanlocs);
                    concat_topo(j,jj,jjj) =  {topo};
                    concat_waveform(j,jj,jjj) =  {waveform};
                elseif strcmp(comp_names{jjj},'P3')
                    waveform_nontarg =  mean(timebytrial(:,strcmp(binlabs_cln,'B1')),2);
                    waveform_targ =  mean(timebytrial(:,strcmp(binlabs_cln,'B2')),2);
                    topo_nontarg = mean(chanbytrial(:,strcmp(binlabs_cln,'B1')),2);
                    topo_targ = mean(chanbytrial(:,strcmp(binlabs_cln,'B2')),2);
                    topo = topo_targ-topo_nontarg;
                    waveform = waveform_targ-waveform_nontarg;
                    subplot(length(conds),length(comp_names)*2,((jj-1)*length(comp_names)*2)+jjj+1)
                    plot(EEG.xmin:1/250:EEG.xmax,waveform);
                    title([subID ' ' conds{jj} ' ' comp_names{jjj}]);
                    ax = gca;
                    rectangle('position',[(meas_wind(jjj,1)/1000),ax.YLim(1),(meas_wind(jjj,2)/1000)-(meas_wind(jjj,1)/1000),ax.YLim(2)-ax.YLim(1)]);
                    subplot(length(conds),length(comp_names)*2,((jj-1)*length(comp_names)*2)+jjj+2);
                    topoplot(topo,EEG.chanlocs);
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



