%% import from data_staging
task = 'Dichotic';
load_dir = '/labs/srslab/data_main/VJP_ICA/binned_clean/';
conds = {'full','odds','99','90'};
comp_names = {'N1','P3'};
comp_elecs_raw = {{'C25', 'C21', 'C12', 'C24', 'C23', 'C11', 'A01'},{'A05', 'A19', 'A32', 'A17', 'A30', 'A10'}};
meas_wind = [50, 150; 250, 500] ;
prestim = 150;
load('/labs/srslab/static_files/shared_apps/matlab_toolboxes/ssk_eegtoolbox/ICAcleanEEG.v.1.3/montage/BioSemi_128_elecN_cart.mat')
comp_elecs = {};
for j = 1:length(comp_elecs_raw)
    [~,inds]=ismember(comp_elecs_raw{j},elecnames);
    comp_elecs(j) = {inds};
end
erp_conditions = {'all','rare-frequent'};
dvs = {'mean_amp','mean_amp_odds','mean_amp_evens','SME'};
DV_vals = subIDs;
trial_report = subIDs;
for jj = 1:length(subIDs)
    subID = subIDs{jj};
    tic
    for j = 1:length(conds)
        try
        load([load_dir,[subID, '_', task,'_',conds{j},'_binned.mat']]);
        prestim = EEG.xmin*1000;
        for jjj = 1:length(comp_names)
            tbin_wind_seq = tbin_wind(jjj,1):tbin_wind(jjj,2);
            single_trial_avg = squeeze(mean(mean(EEG.data(comp_elecs{jjj},tbin_wind_seq,:),2),1));
            if strcmp(erp_conditions{jjj},'all')
                DV_vals(jj,j,jjj,1) = {mean(single_trial_avg)}; %mean amp
                DV_vals(jj,j,jjj,2) = {mean(single_trial_avg(1:2:end))}; %mean amp odds
                DV_vals(jj,j,jjj,3) = {mean(single_trial_avg(2:2:end))}; %mean amp evens
                DV_vals(jj,j,jjj,4) = {std(single_trial_avg)/sqrt(length(single_trial_avg))}; %SME
            end
            if strcmp(erp_conditions{jjj},'rare-frequent')
                avg_frequents = single_trial_avg(strcmp(binlabs_cln,'B1'));
                avg_rares = single_trial_avg(strcmp(binlabs_cln,'B2'));
                avg_diff = avg_rares-avg_frequents(randi(length(avg_frequents),1,length(avg_rares)));
                DV_vals(jj,j,jjj,1) = {mean(avg_diff)};
                DV_vals(jj,j,jjj,2) = {mean(avg_diff(1:2:end))}; %mean amp odds
                DV_vals(jj,j,jjj,3) = {mean(avg_diff(2:2:end))}; %mean amp evens
                DV_vals(jj,j,jjj,4) = {std(avg_diff)/sqrt(length(avg_diff))}; %SME
            end
        end
        catch
               DV_vals(jj,j,1:2,1:4) = {'NA'};
        end
    end
    disp(['done with sub #' ,num2str(jj),' ', num2str(toc)])
end

%reshape 4d to 2d
final = reshape(permute(DV_vals,[1,4,3,2]),[length(subIDs),length(conds)*length(comp_names)*4]); % have to permute to get the reshape algo to work the way I want

%% create col names
cond_labels = {};
comp_labels = {};
erpcond_labels = {};
dv_labels = {};
for j = 1:length(conds)
    cond_labels = [cond_labels,repmat(conds(j),[1,size(final,2)/length(conds)])];
    for jj = 1:length(comp_names)
        comp_labels = [comp_labels,repmat(comp_names(jj),[1,size(final,2)/length(conds)/length(comp_names)])];
        for jjj = 1:length(erp_conditions)
            erpcond_labels = [erpcond_labels,repmat(erp_conditions(jj),[1,size(final,2)/length(conds)/length(comp_names)/length(erp_conditions)])];
        end
    end
end
dv_labels = repmat(dvs,[1,size(final,2)/length(dvs)]);
colnames = ['subIDs',append(cond_labels,'_',comp_labels,'_',erpcond_labels,'_',dv_labels)];
final_table = cell2table([subIDs,final]);
final_table.Properties.VariableNames = colnames;
writetable(final_table,['/labs/srslab/data_main/VJP_ICA/csvs/' task '_amps_and_SME_clean.csv'])




      
