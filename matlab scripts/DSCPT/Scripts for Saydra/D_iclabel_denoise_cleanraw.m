%% run ICA

task = 'DSCPT';
sav_dir = '/labs/srslab/data_main/VJP_ICA/denoised_clean/';
prep_eeg_dir = '/labs/srslab/data_main/VJP_ICA/prepped_clean/';
for jj = 1:length(subIDs)
    subID = subIDs{jj};
    %try
    prep_EEG = pop_loadset( 'filename', [subID '_' task '_prepped.set'],'filepath',prep_eeg_dir);
    EEG = pop_loadset( 'filename', [subID '_' task '_ICA.set'],'filepath','/labs/srslab/data_main/VJP_ICA/ICAs_clean/');
    EEG = pop_iclabel(EEG, 'default');
    EEG = eeg_checkset( EEG );
    chans2use = size(EEG.data,1);

    %%then flag bad ICs and reject
    EEG = pop_icflag(EEG, [NaN NaN;0.8 1;0.8 1;.8 1;.8 1;.8 1;NaN NaN]); %Brain, Muscle, Eye, Heart, Line Noise, Channel Noise, Other.
    comps2rej = find(EEG.reject.gcompreject==1);
    EEG = pop_subcomp( EEG, comps2rej, 0);
    %[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'gui','off','setname',['denoised_' conds{j}]);

    %need to interpolate
    EEG = pop_interp(EEG,prep_EEG.urchanlocs, 'spherical');
    %swap out events too
    EEG.event = prep_EEG.event;

    %% rereference to get Cz elec
    EEG.data(end+1,:) = 0;
    EEG.nbchan = size(EEG.data,1);
    EEG = pop_reref( EEG,[]);

    pop_saveset( EEG, 'filename',[subID '_' task '_denoised_' conds{j} '.set'],'filepath',sav_dir);
end



