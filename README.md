# mkcdf

## USAGE
`mkcdf -name var -name_long "long name" [-option] data_file_YYYY1[-YYYY2].bin`

## Option
`-name`: variable name e.g., QA  
`-name_long`: long name e.g. "J-OFURO3 QA V1.0"  
`-unit`: unit for variable [option]  
`-hr`: 1440 x 720 input  
`-lr`: 360 x 180 input  
`-day`: daily mean (365 or 366 days)  
`-mon`: monthly mean (12 months)  
`-ann`: annual mean  (1 year)  
`-clm`: climatological mean (12 months)  
`-ltmm`: long-term monthly mean (12 months x n years)  
        (data file must be one big file as data_file_YYYY1-YYYY2.bin)
## Install and Setting

