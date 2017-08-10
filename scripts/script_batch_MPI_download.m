proc_ids = [  534313839;242320221; 529389612;115708533;408337320;766174695;58119680;378765791];

   
    for i = 1:length(proc_ids)
    id = proc_ids(i);
    download_gapfilled_partitioned_flux(id)
    end