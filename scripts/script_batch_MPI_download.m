proc_ids = [ 473865728 ;
    878200703;
    129565661;
    71428372;
    42743458;
    708262613;
    987096403;
    836382324;
    630402809];
   
    for i = 1:length(proc_ids)
    id = proc_ids(i);
    download_gapfilled_partitioned_flux(id)
    end