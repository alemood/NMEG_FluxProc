proc_ids = [  704241790; 961329205];

   
    for i = 1:length(proc_ids)
    id = proc_ids(i);
    download_gapfilled_partitioned_flux(id)
    end