task = 'DSCPT';
main_dvs = readtable(['/labs/srslab/data_main/VJP_ICA/csvs/' task '_amps_and_SME_clean.csv']);
main_dvs.subIDs = cellstr(num2str(main_dvs.subIDs));
load(['/labs/srslab/data_main/VJP_ICA/reports/' task '_ICA_prep_clean_report.mat']);
load(['/labs/srslab/data_main/VJP_ICA/reports/' task '_ICA_clean_report.mat']);
load(['/labs/srslab/data_main/VJP_ICA/reports/' task '_classify_clean_report.mat']);
load(['/labs/srslab/data_main/VJP_ICA/reports/' task '_trial_clean_report.mat']);
table4R = join(main_dvs,join(prep_clean_report,join(ica_clean_report,join(classify_clean_report,trial_clean_report))));
writetable(table4R, ['/labs/srslab/data_main/VJP_ICA/csvs/', task ,'_table4R.csv'])