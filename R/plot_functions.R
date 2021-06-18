create_bar_plot <-function(df = selected_df(), facet_var = NULL) {
  x_name <- names(df)[1]
  
  
  # bar plots use the first variable in the df as the x value
  p <- df %>% 
    ggplot() +
    aes(x = .data[[x_name]], y = value, fill = .data[[x_name]]) +
    geom_col(position = "stack", show.legend = FALSE) +
    scale_y_continuous(labels = scales::comma)
  
  
  # facet if required
  if (!is.null(facet_var)) {
    p <- p +
      facet_wrap(~.data[[facet_var]])
  }
  
  return(p)
}

create_line_plot <- function(df = selected_df(), plt_title, facet_var = NULL ) {
  # to clean up output for x-axis
  min_year = min(df[["year"]])
  max_year = max(df[["year"]])
  
  # define separation between year breaks (for axis label)
  sep = ceiling((max_year - min_year)/10)
  
  # line plots always have year as x-axis.
  p <- df %>%
    ggplot() +
    aes(x = year, y = value) +
    geom_line() +
    geom_point() +
    scale_x_continuous(limits = c(min_year, max_year),
                       breaks = seq(min_year, max_year, sep)) +
    scale_y_continuous(labels = scales::comma, limits = c(0, NA)) +
    labs(x = "Year", y = df[["units"]][1], title = plt_title)
  
  # facet if required
  if (!is.null(facet_var)) {
    p <- p +
      facet_wrap(~.data[[facet_var]])
  }
  
  return(p)
}

create_area_plot <- function(df = selected_df()) {
  # to clean up output for x-axis
  min_year = min(df[["year"]])
  max_year = max(df[["year"]])
  
  # define separation between year breaks (for axis label)
  sep = ceiling((max_year - min_year)/10)
  
  # to define order within area plot
  remove <- c("year", "value", "units")
  temp <- names(df)
  
  remaining_cols <- temp [!temp %in% remove]
  
  
  order <- df %>%
    filter(year == min(year) |
             year == max(year)) %>% 
    group_by_at(remaining_cols) %>% 
    summarise(diff = value - lag(value), .groups = 'drop_last') %>% 
    drop_na() %>% 
    arrange(diff) %>% 
    pull(1)
  
  group_name <- names(df)[1]
  
  # dirty mutate
  # df[[group_name]] <- factor(df[[group_name]], levels = order)
  
  p <- df %>% 
    mutate(ccp_mapping = factor(ccp_mapping, levels = order)) %>% 
    ggplot() +
    aes(x = year, y = value,
        fill = .data[[group_name]], group = .data[[group_name]]) +
    geom_area(alpha = 0.8) +
    scale_x_continuous(limits = c(min_year, max_year),
                       breaks = seq(min_year, max_year, sep)) +
    scale_y_continuous(labels = scales::comma, limits = c(0, NA))
  
  return(p)
}

create_hierarchical_plot <- function(df = selected_df(), plot_type = "Sunburst",
                                     sinks = FALSE) {
  p_type <- str_to_lower(plot_type)
  
  # 0. create empty list to store dfs to be plotted side by side
  plot_dfs <- list()
  
  # 1. separate emissions and (usually carbon) sinks
  if (sinks == FALSE) {
    plot_dfs$emissions <- 
      df %>%
      filter(!value < 0) %>%
      group_by(id, label, parent) %>%
      summarise(value = sum(value, na.rm = TRUE), .groups = 'drop_last') %>%
      mutate(units = "megatonnes of CO2 equivelant")
  } else {
    plot_dfs$sinks <- df %>%
      filter(value < 0) %>%
      mutate(value = value * -1) %>%
      group_by(id, label, parent) %>%
      summarise(value = sum(value, na.rm = TRUE), .groups = 'drop_last') %>%
      mutate(units = "megatonnes of CO2 equivelant")
  }
  
  # 2. create plot
  fig <- plot_ly()
  
  # 2.1 add trace for emissions
  if (sinks == FALSE) {
    fig <- fig %>%
      add_trace(
        name = "Emissions",
        ids = plot_dfs$emissions$id,
        labels = plot_dfs$emissions$label,
        parents = plot_dfs$emissions$parent,
        values = plot_dfs$emissions$value,
        type = p_type,
        domain = list(column = 0),
        branchvalues = 'total',
        insidetextorientation = 'radial',
        leaf = list(opacity = 0.6),
        text = ~replace(plot_dfs$emissions$label,
                          nchar(plot_dfs$emissions$label) > 14 & plot_dfs$emissions$label != "Greenhouse Gas Emissions", NA),
        textinfo='text+percent root',
        hovertemplate = paste("%{label}: <br>%{value:.3f}","Mt CO2 or equivelant"),
        maxdepth = 3
      ) %>% 
      layout(
        grid = list(columns =1, rows = 1),
        margin = list(l = 0, r = 0, b = 0, t = 0),
      colorway = c(rev(scales::viridis_pal()(10))[1:9]))
  } else {
  # 2.2 add trace for sinks
    fig <- fig %>%
      add_trace(
        name = "Sinks",
        ids = plot_dfs$sinks$id,
        labels = plot_dfs$sinks$label,
        parents = plot_dfs$sinks$parent,
        values = plot_dfs$sinks$value,
        type = p_type,
        domain = list(column = 1),
        branchvalues = 'total',
        insidetextorientation = 'radial',
        leaf = list(opacity = 0.6),
        text = ~replace(plot_dfs$sinks$label,
                        nchar(plot_dfs$sinks$label) > 14 & plot_dfs$sinks$label != "Greenhouse Gas Sinks", NA),
        textinfo='text+percent root',
        hovertemplate = paste("%{label}: <br>%{value:.3f}","Mt CO2 or equivelant"),
        maxdepth = 3
    ) %>% 
      layout(
        grid = list(columns =1, rows = 1),
        margin = list(l = 0, r = 0, b = 0, t = 0),
        colorway = c(rev(scales::viridis_pal()(10))[3:7]))
  }
  return(fig )
}

# paste0(round(plot_dfs$emissions$value, 1))