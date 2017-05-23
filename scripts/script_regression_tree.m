% REGRESSION TREE SANDBOX

% Make an ensemble of regression trees
Mdl = TreeBagger(100,SHF(:,[1:12]),SHF(:,13),'Method','regression');
aa = find(isnan(SHF{:,13}));
predSHFP = predict(Mdl,SHF{:,1:12));
plot(1:17567,SHF.SHF_P_AVG,'.-k',aa,predSHFP,'og')

% Makes more sense to use with VWC, SW_IN, LW_IN, TA , P, ETC....
qc_T = parse_fluxall_qc_file( sitecode, year );
% Read in for gapfilling filled file
predictor_T = qc_T(:,[32,40,41,42,43,44,45,46,47]);

Mdl = TreeBagger( 100 , predictor_T, G_s( : , 13 ) , 'Method' , 'regression' );

missing_data = find( isnan( G_s{ : , 13 } ) );
missing_tower_data = find( isnan ( predictor_T{:,1} ) );
predSHF = predict(Mdl,predictor_T);
plot(qc_T.timestamp, G_s{ : , 13 },'-k',...
        qc_T.timestamp( missing_data ) ,predSHF( missing_data),'og')