##------------------------------------------------
# This script executes this function for all sites where fLUE droughts are identified (`successcode==1`) 
# and combines dataframes into combined large dataframes containing all sites' data, saved in `data/data_aligned_agg.Rdata`:
# - `df_dday_agg`
# - `df_dday_modis_agg`
# - `df_dday_mte_agg`
# - `df_dday_aggbydday_agg`
##------------------------------------------------

library(dplyr)

source( paste( "reshape_align_nn_fluxnet2015.R", sep="" ) )

##------------------------------------------------
## Select all sites for which method worked (codes 1 and 2 determined by 'nn_getfail_fluxnet2015.R')
##------------------------------------------------
siteinfo <- read.csv( "successcodes.csv", as.is = TRUE )
do.sites <- dplyr::filter( siteinfo, successcode==1 )$mysitename

# ## add classid column
# tmp <- read.csv( paste( myhome, "sofun/input_fluxnet2015_sofun/siteinfo_fluxnet2015_sofun.csv", sep="") )
# siteinfo <- siteinfo %>% left_join( dplyr::select(tmp, mysitename, classid ) )

print( "aligning data for all sites ...")

## initialise aggregated data
df_dday_agg <- c()
df_dday_modis_agg <- c()
df_dday_mte_agg <- c()
df_dday_aggbydday_agg <- c()

for (sitename in do.sites){

  # print( paste( "reshaping for site", sitename ) )
  out <- reshape_align_nn_fluxnet2015( sitename, nam_target="lue_obs_evi", overwrite=TRUE, verbose=FALSE )

  # df_dday_agg           <- rbind( df_dday_agg,           out$df_dday )
  # df_dday_aggbydday_agg <- rbind( df_dday_aggbydday_agg, out$df_dday_aggbydday )    
  # df_dday_modis_agg     <- rbind( df_dday_modis_agg,     out$df_dday_modis )
  # df_dday_mte_agg       <- rbind( df_dday_mte_agg,       out$df_dday_mte )

  if (!is.null(out$df_dday))           df_dday_agg           <- rbind( df_dday_agg,           out$df_dday )
  if (!is.null(out$df_dday_aggbydday)) df_dday_aggbydday_agg <- rbind( df_dday_aggbydday_agg, out$df_dday_aggbydday )    
  if (!is.null(out$df_dday_modis))     df_dday_modis_agg     <- rbind( df_dday_modis_agg,     out$df_dday_modis )
  if (!is.null(out$df_dday_mte  ))     df_dday_mte_agg       <- rbind( df_dday_mte_agg,       out$df_dday_mte )

}

print("... done.")

if ( length( dplyr::filter( siteinfo, successcode==1 )$mysitename ) == length( do.sites ) ){
  ##------------------------------------------------
  ## Aggregated data from MODIS and MTE around drought events
  ##------------------------------------------------
  filn <- "data/data_aligned_agg.Rdata"
  print( paste( "saving to file:", filn ) )
  save( df_dday_agg, df_dday_modis_agg, df_dday_mte_agg, df_dday_aggbydday_agg, file=filn )

} else {

  print("WARNING: NO SAVING AT THE END!")

}




