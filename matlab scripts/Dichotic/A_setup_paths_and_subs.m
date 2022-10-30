% preprocess resting file from DEFEND for building pipeline
addpath('/labs/srslab/static_files/shared_apps/matlab_toolboxes/EEGLAB/eeglab2021.1')
eeglab

%pull subIDs we have data for

task = 'Dichotic';
directory = '/labs/srslab/data_staging/GTF_archive/';
files = dir([directory, '*00' ]);
subIDs = {files(:).name}';
% get rid of probands and rels
expr = '1[0-9][5-9][0-9][0-9][0-9]00'; % very proud of myself for actually using regexps
subIDs = regexp(subIDs,expr,'match');
subIDs = subIDs(~cellfun('isempty',subIDs));

dich_subIDs = [];
for j = 1:length(subIDs)
    subID = char(subIDs{j});
    sub_files = dir([directory,subID]);
    if any(contains({sub_files.name},'Di')) 
        dich_subIDs = [dich_subIDs; subID];
    end
end

subIDs = cellstr(dich_subIDs);


        


