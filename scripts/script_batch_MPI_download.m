proc_ids = [ 912650689 ;
   372275768;
   329812453;
   545331721;
   837963695;
   164741419;
   660242817
    ];
   
    for i = 1:length(proc_ids)
    id = proc_ids(i);
    download_gapfilled_partitioned_flux(id)
    end