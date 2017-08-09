proc_ids = [ 259605188;440095293];

   
    for i = 1:length(proc_ids)
    id = proc_ids(i);
    download_gapfilled_partitioned_flux(id)
    end