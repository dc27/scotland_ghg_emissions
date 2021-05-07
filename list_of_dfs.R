explorable_dfs <- list(
  "All" = list(
    
    "Historic Emissions" = list(
      data = read_csv("data/clean_data/ghg_emissions.csv"),
      plot_options = c("line", "bar"),
      explorable_vars = c("year", "pollutant")
    ),
    "Sector Breakdown" = list(
      data = read_csv("data/clean_data/hierarchical_data.csv"),
      plot_options = c("sunburst", "treemap"),
      explorable_vars = c("year", "pollutant")
    )
  ),
  "Agriculture" <- list(

  ),
  "Electricity Generation" <- list(

  ),
  "Industry" <- list(

  ),
  "Land Use" <- list(

  ),
  "Residential" <- list(

  ),
  "Services" <- list(

  ),
  "Transport" <- list(

  ),
  "Waste" <- list(

  )
)