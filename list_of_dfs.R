explorable_dfs <- list(
  "All" = list(
    "Historic Emissions" = list(
      data = read_csv("data/clean_data/ghg_emissions_summary.csv"),
      plot_options = c("line", "bar", "area"),
      explorable_vars = c("year", "pollutant")
    ),
    "Sector Breakdown" = list(
      data = read_csv("data/clean_data/hierarchical_data.csv"),
      plot_options = c("sunburst", "treemap"),
      explorable_vars = c("year", "pollutant")
    )
  ),
  "Agriculture" = list(

  ),
  "Electricity Generation" = list(

  ),
  "Industry" = list(

  ),
  "Land Use" = list(

  ),
  "Residential" = list(

  ),
  "Services" = list(

  ),
  "Transport" = list(
    "Newly Registered Vehicles" = list(
      data = read_csv(
        "data/clean_data/transport/newly_registered_vehicles_and_ulevs.csv"
        ),
      plot_options = c("line"),
      explorable_vars = c("year", "vehicle_type", "statistic")
    ),
    "Road Traffic" = list(
      data = read_csv("data/clean_data/transport/road_traffic.csv"),
      plot_options = c("line"),
      explorable_vars = c("year", "vehicle_type", "road_type")
    )
  ),
  "Waste" = list(

  )
)

