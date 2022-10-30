%% import from data_staging
task = 'Dichotic';
load_dir = '/labs/srslab/data_main/VJP_ICA/denoised_clean/';
dir2sav = '/labs/srslab/data_main/VJP_ICA/binned_clean/';
conds = {'full','odds','99','90'};
SME_vals = subIDs;
SME_vals_P3_freq = subIDs;
SME_vals_P3_rare = subIDs;
trial_report = subIDs;
for jj = 1:length(subIDs)
    subID = subIDs{jj};
    for j = 1:length(conds)
        try
            EEG = pop_loadset( 'filename', [subID '_' task '_denoised_' conds{j} '.set'],'filepath',load_dir);
            EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } ); 
            EEG  = pop_binlister( EEG , 'BDF', '/labs/srslab/data_main/VJP_ICA/scripts/Dichotic/binlister.txt', 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' ); 
            EEG = pop_epochbin( EEG , [-150.0  893.0],  'pre');
            binlabs = {EEG.epoch(:).eventtype};
            final_events = [];
            for i = 1:length(binlabs)
                event = [EEG.epoch(i).eventtype];
                if ~any(contains(event,'-99'))
                    final_events = [final_events;event(1)];
                elseif any(contains(event,'-99'))
                    final_events = [final_events;'-99'];
                end
            end

            binlabs_cln = char(final_events(~strcmp(final_events,'-99')));
            binlabs_cln = cellstr(binlabs_cln(:,1:2));
            save([dir2sav,subID, '_', task,'_',conds{j},'_binned.mat'],'EEG','binlabs_cln')
            trial_report(jj,((j-1)*2)+2) = {sum(strcmp(binlabs_cln,'B1'))};
            trial_report(jj,((j-1)*2)+3) = {sum(strcmp(binlabs_cln,'B2'))};
        catch
            trial_report(jj,((j-1)*2)+2) = {'no trial info'};
            trial_report(jj,((j-1)*2)+3) = {'no trial info'};
        end
    end
end
colnames = {'subIDs','# of freq trials full','# of rare trials full', ...
                     '# of freq trials odds','# of rare trials odds', ...
                     '# of freq trials 99','# of rare trials 99', ...
                     '# of freq trials 90','# of rare trials 90'};
trial_report_clean = cell2table(trial_report,'VariableNames',colnames);
save(['/labs/srslab/data_main/VJP_ICA/reports/',task,'_trial_report_clean.mat'],'trial_report_clean')

