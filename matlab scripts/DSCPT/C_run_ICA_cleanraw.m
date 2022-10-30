%% run ICA

task = 'DSCPT';
ica_report = subIDs;
dir2load  = '/labs/srslab/data_main/VJP_ICA/prepped_clean/';
dir2sav = '/labs/srslab/data_main/VJP_ICA/ICAs_clean/';
for j = 1:length(subIDs) 
    subID = subIDs{j};
    try
        EEG = pop_loadset( 'filename', [subID '_' task '_prepped.set'],'filepath',dir2load);    
        %% run ICA on full dataset
        chans2use = size(EEG.data,1);
        tic
        EEG = pop_runica(EEG, 'extended',1,'interupt','on','chanind',[1:chans2use]);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'gui','off','setname','ICA_all');
        pop_saveset( EEG, 'filename',[subID '_' task '_ICA_full.set'],'filepath',dir2sav);
        eeglab redraw
        ica_report(j,2) = {toc};
    catch
        ica_report(j,2) = {'unable to run ICA'};
    end
    try
        %% run ICA on only odd electrods
        tic
        EEG = pop_runica(EEG, 'extended',1,'interupt','on','chanind',[1:2:chans2use]);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'gui','off','setname','ICA_odds');
        pop_saveset( EEG, 'filename',[subID '_' task '_ICA_odds.set'],'filepath',dir2sav);
        eeglab redraw
        ica_report(j,3) = {toc};
    catch
        ica_report(j,3) = {'unable to run ICA'};
    end

        
        %% run ICA with PCA 99%
    try
        tic
        [~,~,~,~,explained,~]=pca(EEG.data','Economy',false);
        percent_var = cumsum(explained)/sum(explained);
        ncomps99 = sum(percent_var < .99);
        if ncomps99 ==0
            ncomps99 = 1;
        end
        EEG = pop_runica(EEG, 'extended',1,'interupt','on','chanind',[1:chans2use],'pca',ncomps99);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'gui','off','setname','ICA_all');
        pop_saveset( EEG, 'filename',[subID '_' task '_ICA_99.set'],'filepath',dir2sav);
        eeglab redraw
        ica_report(j,4) = {toc};
    catch
        ica_report(j,4) = {'unable to run ICA'};
    end    
        
        %% run ICA with PCA 90%
    try
        tic
        [~,~,~,~,explained,~]=pca(EEG.data','Economy',false);
        percent_var = cumsum(explained)/sum(explained);
        ncomps90 = sum(percent_var < .90);
        if ncomps90 ==0
            ncomps90 = 1;
        end
        EEG = pop_runica(EEG, 'extended',1,'interupt','on','chanind',[1:chans2use],'pca',ncomps90);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'gui','off','setname','ICA_all');
        pop_saveset( EEG, 'filename',[subID '_' task '_ICA_90.set'],'filepath',dir2sav);
        eeglab redraw
        ica_report(j,5) = {toc}; 
    catch
        ica_report(j,5) = {'unable to run ICA'};
    end
    ica_report(j,6) = {ncomps99};
    ica_report(j,7) = {ncomps90};
end
colnames = {'subIDs','full ica elapsed time','odds ica elapsed time','99% PCA-ICA elapsed time','90% PCA-ICA elapsed time' ...
            '99% thresh # of PCs','90% thresh # of PCs'};
ica_report = cell2table(ica_report,'VariableNames',colnames);
ica_clean_report = ica_report;
save(['/labs/srslab/data_main/VJP_ICA/reports/',task,'_ICA_clean_report.mat'],'ica_clean_report')

