%% import from data_staging
task = 'DSCPT';
directory = '/labs/srslab/data_staging/PENS_EEG/';
dir2save = '/labs/srslab/data_main/VJP_ICA/prepped_clean/';
prep_report = subIDs;
all_oevent = [];
nchans = 127;
for j = 1:length(subIDs)
    subID = subIDs{j};
    tic
    %% import with ear elecs
    try
        EEG = pop_loadbv([directory subID '/'], [subID '_' task '.vhdr']);
        %get rid of aux elecs 
        EEG = pop_select( EEG, 'nochannel',{'VEOG','HEOG','lEMG','rEMG','ButtonBox'});
      
     %% downsample and filter
        EEG = pop_resample( EEG, 250);
        EEG  = pop_basicfilter( EEG,  1:length(EEG.chanlocs) , 'Cutoff',  0.1, 'Design', 'butter', 'Filter', 'highpass', 'Order',  2, 'RemoveDC', 'on' );
        EEG.urchanlocs = EEG.chanlocs;
        
     %% automatic bad elec and bad epoch rejection
        EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion',5,'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass','off','BurstCriterion','off','WindowCriterion','off','BurstRejection','off','Distance','Euclidian');
        indelec = find(EEG.etc.clean_channel_mask == 0 );
        [EEG, selectedregions]= pop_rejcont(EEG, 'elecrange',[1:length(EEG.chanlocs)] ,'freqlimit',[20 40] ,'threshold',10,'epochlength',0.5,'contiguous',4,'addlength',0.25,'taper','hamming');
        EEG.orig_elecs = 1:128;
        EEG.orig_elecs_inds = setdiff(EEG.orig_elecs,indelec);
        
      %% save it
        pop_saveset( EEG, 'filename',[subID '_' task '_prepped.set'],'filepath',dir2save);
        toc
        if isempty(selectedregions)
            prep_report(j,2) = {0};
        else
            prep_report(j,2) = {100*(round(sum(selectedregions(:,2) - selectedregions(:,1)), 2)/length(EEG.times))};
        end
        prep_report(j,3) = {length(indelec)};
        
    catch
        prep_report(j,2) = {'unable to import'};
        prep_report(j,3) = {'unable to import'};
        
    end
end
    colnames = {'subIDs','rejected time segments %','# rejected elecs'};
    prep_report = cell2table(prep_report,'VariableNames',colnames);
    prep_clean_report = prep_report;
    save(['/labs/srslab/data_main/VJP_ICA/reports/',task,'_ICA_prep_clean_report.mat'],'prep_clean_report')




