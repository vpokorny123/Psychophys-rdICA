%% run ICA
task = 'Dichotic';
sav_dir = '/labs/srslab/data_main/VJP_ICA/denoised_clean/';
conds = {'full','odds','99','90'};
classify_report = subIDs;
for jj = 1:length(subIDs)
    subID = subIDs{jj};
    for j = 1:length(conds)
        prep_EEG = pop_loadset( 'filename', [subID '_' task '_prepped.set'],'filepath','/labs/srslab/data_main/VJP_ICA/prepped_clean/');
        EEG = pop_loadset( 'filename', [subID '_' task '_ICA_' conds{j} '.set'],'filepath','/labs/srslab/data_main/VJP_ICA/ICAs_clean/');
        EEG = pop_iclabel(EEG, 'default');
        EEG = eeg_checkset( EEG );
        chans2use = size(EEG.data,1);
        if strcmp(conds{j}, 'odds')
            chans2use = size(EEG.data,1);
            EEG_odss = EEG;
            EEG_odss.data = EEG.data([1:2:chans2use],:);
            EEG_odss.nbchan = length([1:2:chans2use]);
        end
        
        %% calc percent variance of mixed ICs
        var_store = [];
        percent_conf_thresh = .8;
        mixed_bools  = EEG.etc.ic_classification.ICLabel.classifications(:,1:end-1) < percent_conf_thresh;
        mixed_idx = find(all(mixed_bools ,2));
        disp('..... computing percent variance accounted for of mixed ICs.....')
        if strcmp(conds{j}, 'odds')
            mixed_var = eeg_pvaf(EEG_odss,mixed_idx,'plot','off');
        else
            mixed_var = eeg_pvaf(EEG,mixed_idx,'plot','off');  
        end
        classify_report(jj,j+1) = {mixed_var};
         
        %%then flag bad ICs and reject
        EEG = pop_icflag(EEG, [NaN NaN;0.8 1;0.8 1;.8 1;.8 1;.8 1;NaN NaN]); %Brain, Muscle, Eye, Heart, Line Noise, Channel Noise, Other.
        comps2rej = find(EEG.reject.gcompreject==1);
        EEG = pop_subcomp( EEG, comps2rej, 0);

        %need to interpolate
        EEG = pop_interp(EEG, prep_EEG.urchanlocs, 'spherical');
        %swap out events too
        EEG.event = prep_EEG.event;
        EEG = pop_reref( EEG, []);
        pop_saveset( EEG, 'filename',[subID '_' task '_denoised_' conds{j} '.set'],'filepath',sav_dir);
    end
end
colnames = {'subIDs','% var mixed full','% var mixed odds','% var mixed 99','%var mixed 90'};
classify_report = cell2table(classify_report);
classify_report.Properties.VariableNames = colnames;
classify_clean_report = classify_report;
save(['/labs/srslab/data_main/VJP_ICA/reports/',task, '_classify_clean_report.mat'],'classify_clean_report')


