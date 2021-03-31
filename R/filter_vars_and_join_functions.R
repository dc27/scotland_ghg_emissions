

# combine measurements with polygon data
join_with_shapes <- function(measurement_df, spdf) {
  spdf@data <- tibble(spdf@data) %>%
    left_join(measurement_df, by = c("id_code" = "code"))
  
  return(spdf)
}