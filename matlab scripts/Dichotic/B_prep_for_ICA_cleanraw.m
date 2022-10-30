%% import from data_staging
task = 'Dichotic';
directory = '/labs/srslab/data_staging/GTF_archive/';
dir2save = '/labs/srslab/data_main/VJP_ICA/prepped_clean/';
prep_report = subIDs;
all_oevent = [];
for j = 1:length(subIDs)
    subID = subIDs{j};
    tic
    %% import with ear elecs
    try
        EEG = pop_biosig([directory '/' subID '/' subID '_' task '.bdf'], 'ref',[129 130] ,'importannot','off','refoptions',{'keepref' 'off'},'channels',[1:130]);
        %%  load in channel info so we can look at topoplots in ICA
        EEG=pop_chanedit(EEG, 'load',[],'load',{'/labs/srslab/static_files/shared_apps/matlab_toolboxes/ssk_eegtoolbox/ICAcleanEEG.v.1.3/montage/BioSemi_128_elecN.elp' 'filetype' 'autodetect'});
        eeglab redraw
        
        %% make event codes make sense
        oevent = [EEG.event.type];
        if any(ismember(oevent,768)) & any(ismember(oevent,779))
            oevent = oevent-768;
        elseif any(ismember(oevent,768)) & any(ismember(oevent,832))
            oevent = oevent-768;
            oevent(oevent==9) = 11;
            oevent(oevent==19) = 11;
            oevent(oevent==64) = 13;
            oevent(oevent==164) = 13;
            oevent(oevent==145) = 12;
            oevent(oevent==45) = 12;
            oevent(oevent==186) = 14;
            oevent(oevent==86) = 14;
            oevent(oevent==20) = 2;
            oevent(oevent==120) = 2;
            oevent(oevent==140) = 3;
            oevent(oevent==140) = 3;
        elseif any(ismember(oevent,768)) & any(ismember(oevent,789))
            oevent = oevent-768;
            oevent(oevent==21) = 11;
            oevent(oevent==31) = 11;
            oevent(oevent==41) = 11;
            oevent(oevent==22) = 12;
            oevent(oevent==32) = 12;
            oevent(oevent==42) = 12;
            oevent(oevent==23) = 13;
            oevent(oevent==33) = 13;
            oevent(oevent==43) = 13;
            oevent(oevent==24) = 14;
            oevent(oevent==34) = 14;
            oevent(oevent==44) = 14;
        end

        all_oevent = [all_oevent,oevent];
        celloevent = num2cell(oevent);
        [EEG.event.type] = celloevent{:};
           
        %% downsample and filter
        EEG = pop_resample( EEG, 250);
        %following is taken from Kappenman's scripts
        EEG  = pop_basicfilter( EEG,  1:128 , 'Cutoff',  0.1, 'Design', 'butter', 'Filter', 'highpass', 'Order',  2, 'RemoveDC', 'on' );
        EEG.urchanlocs = EEG.chanlocs;
        
       %% automatic bad elec and bad epoch rejection
        EEG.etc.clean_channel_mask = true(size(EEG.data,1),1); 
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




