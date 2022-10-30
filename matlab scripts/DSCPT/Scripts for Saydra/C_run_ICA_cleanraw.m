%% run ICA

task = 'DSCPT';
ica_report = subIDs;
dir2load  = '/labs/srslab/data_main/VJP_ICA/prepped_clean/';
dir2sav = '/labs/srslab/data_main/VJP_ICA/ICAs_clean/';
dir2sav_report = '/labs/srslab/data_main/VJP_ICA/reports/';
for j = 1:length(subIDs)  %just run for problem people
    subID = subIDs{j};
    try
        EEG = pop_loadset( 'filename', [subID '_' task '_prepped.set'],'filepath',dir2load);    
        %% run ICA on full dataset
        chans2use = size(EEG.data,1);
        tic
        EEG = pop_runica(EEG, 'extended',1,'interupt','on','chanind',[1:chans2use]);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'gui','off','setname','ICA_all');
        pop_saveset( EEG, 'filename',[subID '_' task '_ICA.set'],'filepath',dir2sav);
        eeglab redraw
        ica_report(j,2) = {toc};
    catch
        ica_report(j,2) = {'unable to run ICA'};
    end
end
colnames = {'subIDs','full ica elapsed time'};
ica_report = cell2table(ica_report,'VariableNames',colnames);
ica_clean_report = ica_report;
save([dir2sav_report,task,'_ICA_clean_report.mat'],'ica_clean_report')

