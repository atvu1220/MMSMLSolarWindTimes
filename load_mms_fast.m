function [timedata,espectdata,energydata,ndata,vdata,tperpdata,tparadata,btimedata,bdata,rtimedata,rdata] = load_mms_fast(date_start,date_end)
    %Load Solar Wind Magnetic Field Data from WIND's MFI instrument for All files within directory
    %date format = YYYYMMDD; same as filename
    
    
    
    %% FPI
    %Create Directory String
    data_directory = '/Volumes/data2/mms/FPI/';
    
    
    %Search for files in directory
    directory_structure = dir(data_directory);
    
    %Find the exact filename for files in directory
    all_filenames = {directory_structure(:,1).name};
    
    data_filenames = all_filenames(contains(all_filenames,'fpi'));
    
    %datestr((ds + n),'yyyymmdd');
    %Use only time range given by arguments
    data_filenames = data_filenames(find(~contains(data_filenames,'._')));
    index_start = find(contains(data_filenames,date_start),1,'first');
    index_end = find(contains(data_filenames,date_end),1,'last');
    data_filenames = data_filenames(index_start:index_end);
    
    
    days_of_data = size(data_filenames,2);
    
    clear all_filenames
    clear directory_structure
    
    
    
    %Do first file
    if isempty(data_filenames) == 1
        timedata = 0;
        espectdata=0
        energydata=0
        ndata=0;
        vdata=0;
        tperpdata=0;
        tparadata=0;
        btimedata=0;
        bdata=0;
        rtimedata=0;
        rdata=0;
        
        
    else
        currentDataFilename = strcat(data_directory,char(data_filenames(1)));%Error, filename inludes ._
        data_info = spdfcdfinfo(currentDataFilename);
        data_variables = data_info.Variables;
        
        timedata_label = data_variables(1,1); %Epoch
        espectdata_label = data_variables(14,1); %Energy Spectrum
        energydata_label = data_variables(36,1);
        ndata_label = data_variables(17,1);
        vdata_label = data_variables(23,1);
        tparadata_label = data_variables(38,1);
        tperpdata_label = data_variables(39,1);
        
        timedata = spdfcdfread(currentDataFilename, 'Variables', timedata_label, 'ConvertEpochToDatenum', true);
        espectdata = spdfcdfread(currentDataFilename,'Variables', espectdata_label);
        energydata = spdfcdfread(currentDataFilename,'Variables', energydata_label);
        ndata = spdfcdfread(currentDataFilename,'Variables', ndata_label);
        vdata = spdfcdfread(currentDataFilename,'Variables', vdata_label);
        tparadata = spdfcdfread(currentDataFilename,'Variables', tparadata_label);
        tperpdata = spdfcdfread(currentDataFilename,'Variables', tperpdata_label);
        
        timedata = double(timedata);
        espectdata = double(espectdata);
        energydata = double(energydata);
        ndata = double(ndata);
        vdata = double(vdata);
        tparadata = double(tparadata);
        tperpdata = double(tperpdata);
        
        
        
        
        
        for i=2:days_of_data
            yesterdayDateFilename = strcat(data_directory,char(data_filenames(i-1)));
            currentDataFilename = strcat(data_directory,char(data_filenames(i)));
            currentDataFilename(43:54); %Print Current Date
            
            
            %Load Data
            timedata_additional = spdfcdfread(currentDataFilename, 'Variables', timedata_label, 'ConvertEpochToDatenum', true);
            
            %load FPI data
            ndata_additional = spdfcdfread(currentDataFilename,'Variables', ndata_label);
            vdata_additional = spdfcdfread(currentDataFilename,'Variables', vdata_label);
            
            tparadata_additional = spdfcdfread(currentDataFilename,'Variables', tparadata_label);
            tperpdata_additional = spdfcdfread(currentDataFilename,'Variables', tperpdata_label);
            
            energydata_additional = spdfcdfread(currentDataFilename,'Variables', energydata_label);
            espectdata_additional = spdfcdfread(currentDataFilename,'Variables', espectdata_label);
            
            %convert to double type for more precision
            timedata_additional = double(timedata_additional);
            
            ndata_additional = double(ndata_additional);
            vdata_additional = double(vdata_additional);
            
            tparadata_additional = double(tparadata_additional);
            tperpdata_additional = double(tperpdata_additional);
            
            energydata_additional = double(energydata_additional);
            espectdata_additional = double(espectdata_additional);
            %
            %
            %         %If there's at gap between the two data files, put a NaN.
            while (timedata_additional(1) > datenum(hours(2)) + timedata(end))
                timedata = [timedata; (timedata(end)+datenum(seconds(4.5)):datenum(seconds(4.5)):(datenum(hours(2) + timedata(end))))'];
                espectdata = [espectdata;NaN(1600,32)];
                energydata = [energydata;NaN(1600,32)];
                ndata = [ndata; NaN(1600,1)];
                vdata = [vdata; NaN(1600,3)];
                tparadata = [tparadata;NaN(1600,1)];
                tperpdata = [tperpdata;NaN(1600,1)];
                
            end
            while timedata_additional(1) > datenum(seconds(4.5)) + timedata(end)
                timedata = [timedata; datenum(seconds(4.5)) + timedata(end)];
                espectdata = [espectdata;NaN(1,32)];
                energydata = [energydata;NaN(1,32)];
                ndata = [ndata; NaN];
                vdata = [vdata; NaN(1,3)];
                tparadata = [tparadata;NaN];
                tperpdata = [tperpdata;NaN];
                
            end
            
            
            
            
            
            %append this file's data to the main data array
            timedata = [timedata; timedata_additional];
            
            ndata = [ndata; ndata_additional];
            vdata = [vdata; vdata_additional];
            
            tparadata = [tparadata; tparadata_additional];
            tperpdata = [tperpdata; tperpdata_additional];
            
            energydata = [energydata; energydata_additional];
            espectdata = [espectdata; espectdata_additional];
            
            
            clear timedata_additional;
            clear ndata_additional;
            clear vdata_additional;
            clear tparadata_additional;
            clear tperpdata_additional;
            clear energydata_additional;
            clear espectdata_additional;
            
            
        end
        vmagdata = vecnorm(vdata,2,2);
        vdata = [vdata,vmagdata];
        %% FGM
        %Create Directory String
        data_directory = '/Volumes/data2/mms/FGM/';
        
        
        %Search for files in directory
        directory_structure = dir(data_directory);
        
        %Find the exact filename for files in directory
        all_filenames = {directory_structure(:,1).name};
        
        data_filenames = all_filenames(contains(all_filenames,'fgm'));
        
        
        %Use only time range given by arguments
        index_start = find(contains(data_filenames,date_start));
        index_end = find(contains(data_filenames,date_end));
        data_filenames = data_filenames(index_start:index_end);
        
        days_of_data = size(data_filenames,2);
        
        clear all_filenames
        clear directory_structure
        
        
        
        %Do first file
        currentDataFilename = strcat(data_directory,char(data_filenames(1)));
        data_info = spdfcdfinfo(currentDataFilename);
        data_variables = data_info.Variables;
        
        btimedata_label = data_variables(1,1); %Epoch
        bdata_label = data_variables(2,1);
        rtimedata_label = data_variables(7,1);
        rdata_label = data_variables(8,1);
        
        
        btimedata = spdfcdfread(currentDataFilename, 'Variables', btimedata_label, 'ConvertEpochToDatenum', true);
        rtimedata = spdfcdfread(currentDataFilename, 'Variables', rtimedata_label, 'ConvertEpochToDatenum', true);
        bdata = spdfcdfread(currentDataFilename,'Variables', bdata_label);
        rdata = spdfcdfread(currentDataFilename,'Variables', rdata_label);
        
        
        btimedata = double(btimedata);
        rtimedata = double(rtimedata);
        bdata = double(bdata);
        rdata = double(rdata);
        
        
        for i=2:days_of_data
            yesterdayDateFilename = strcat(data_directory,char(data_filenames(i-1)));
            currentDataFilename = strcat(data_directory,char(data_filenames(i)));
            currentDataFilename(43:54); %Print Current Date
            
            
            %Load Data
            btimedata_additional = spdfcdfread(currentDataFilename, 'Variables', btimedata_label, 'ConvertEpochToDatenum', true);
            rtimedata_additional = spdfcdfread(currentDataFilename, 'Variables', rtimedata_label, 'ConvertEpochToDatenum', true);
            
            %load FPI data
            bdata_additional = spdfcdfread(currentDataFilename,'Variables', bdata_label);
            rdata_additional = spdfcdfread(currentDataFilename,'Variables', rdata_label);
            
            %convert to double type for more precision
            btimedata_additional = double(btimedata_additional);
            rtimedata_additional = double(rtimedata_additional);
            
            bdata_additional = double(bdata_additional);
            rdata_additional = double(rdata_additional);
            %
            %         %If there's at least a day gap between the two data files, put a NaN.
            %         if datetime(currentDataFilename(43:50),'inputFormat','yyyyMMdd') - days(1) > datetime(yesterdayDateFilename(43:50),'inputFormat','yyyyMMdd')
            %             timedata = [timedata;datenum(datetime(currentDataFilename(26:33),'inputFormat','yyyyMMddHH') - hours(1))];
            %             ndata = [ndata; NaN];
            %             vdata = [vdata; NaN(1,3)];
            %         end
            
            
            %append this file's data to the main data array
            btimedata = [btimedata; btimedata_additional];
            rtimedata = [rtimedata; rtimedata_additional];
            
            bdata = [bdata; bdata_additional];
            rdata = [rdata; rdata_additional];
            
            clear btimedata_additional;
            clear rtimedata_additional;
            clear bdata_additional;
            clear rdata_additional;
            
            
        end
        
        %% DownSample FGM to FPI
        [btimedata,bdata] = interpxyz(btimedata,bdata,timedata);
        [rtimedata,rdata] = interpxyz(rtimedata,rdata,timedata);
        
        
        %     %crop according to available FPI data
        %     btimedata_end = find(timedata(end) < btimedata,1);
        %     btimedata = btimedata(1:btimedata_end);
        %     bdata = bdata(1:btimedata_end,:);
        %     rtimedata_end = find(timedata(end) < rtimedata,1);
        %     rdata = rdata(1:rtimedata_end,:);
        
    end
end