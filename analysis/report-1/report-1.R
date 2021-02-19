rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.

# ---- load-sources ------------------------------------------------------------
#Load any source files that contain/define functions, but that don't load any other types of variables
#   into memory.  Avoid side effects and don't pollute the global environment.
# source("SomethingSomething.R")

# ---- load-packages -----------------------------------------------------------
library(ggplot2) #For graphing
import::from("magrittr", "%>%")
requireNamespace("dplyr")
# requireNamespace("RColorBrewer")
# requireNamespace("scales") #For formating values in graphs
# requireNamespace("mgcv) #For the Generalized Additive Model that smooths the longitudinal graphs.
# requireNamespace("TabularManifest") # remotes::install_github("Melinae/TabularManifest")

# ---- declare-globals ---------------------------------------------------------
options(show.signif.stars=F) #Turn off the annotations on p-values
# config                      <- config::get()
# path_input                  <- config$path_car_derived
# Uncomment the lines above and delete the one below if value is stored in 'config.yml'.

path_input <- "data-public/raw/sample.csv"

palette_dark <- c(
  "Pepsi"       = "#004B93", # https://usbrandcolors.com/pepsi-colors/
  "Coke"        = "#F40009", # https://usbrandcolors.com/coca-cola-colors
  "Dr. Pepper"  = "#711F25"  # https://brandpalettes.com/dr-pepper-color-codes/
)

# Execute to specify the column types.  It might require some manual adjustment (eg doubles to integers).
#   OuhscMunge::readr_spec_aligned(path_input)
col_types <- readr::cols_only(
    substrate            = readr::col_character(),
    can_index            = readr::col_integer(),
    duration_min         = readr::col_integer(),
    temp_c               = readr::col_integer(),
    ph                   = readr::col_double()
)

# ---- load-data ---------------------------------------------------------------
ds <- readr::read_csv(path_input, col_types = col_types) # 'ds' stands for 'datasets'

# ---- tweak-data --------------------------------------------------------------
ds <-
  ds %>%
  dplyr::mutate(
    can = paste(substrate, can_index)
  )
#
# checkmate::assert_factor(   ds$forward_gear_count_f         , any.missing=F                           )
# checkmate::assert_factor(   ds$carburetor_count_f           , any.missing=F                           )
# checkmate::assert_numeric(  ds$horsepower_by_gear_count_3   , any.missing=F , lower=   0, upper=   0  )
# checkmate::assert_numeric(  ds$horsepower_by_gear_count_4   , any.missing=F , lower=   0, upper=   0  )

# ---- marginals ---------------------------------------------------------------
# Inspect continuous variables
# histogram_continuous(d_observed=ds, variable_name="quarter_mile_sec", bin_width=.5, rounded_digits=1)
# # slightly better function: TabularManifest::histogram_continuous(d_observed=ds, variable_name="quarter_mile_sec", bin_width=.5, rounded_digits=1)
# histogram_continuous(d_observed=ds, variable_name="displacement_inches_cubed", bin_width=50, rounded_digits=1)
#
# # Inspect discrete/categorical variables
# histogram_discrete(d_observed=ds, variable_name="carburetor_count_f")
# histogram_discrete(d_observed=ds, variable_name="forward_gear_count_f")

# ---- spaghetti ------------------------------------------------------------
ggplot(ds, aes(x=duration_min, y=ph, group=can, color=substrate, label=can_index)) +
  # geom_smooth(method="loess", span=2) +
  geom_line(alpha = .6) +
  geom_text(alpha = .6) +
  scale_color_manual(values = palette_dark) +
  theme_light() +
  theme(axis.ticks = element_blank()) +
  labs(
    x = "Duration (min)"
  )




# # ---- models ------------------------------------------------------------------
# cat("============= Simple model that's just an intercept. =============")
# m0 <- lm(quarter_mile_sec ~ 1, data=ds)
# summary(m0)
#
# cat("============= Model includes one predictor. =============")
# m1 <- lm(quarter_mile_sec ~ 1 + miles_per_gallon, data=ds)
# summary(m1)
#
# cat("The one predictor is significantly tighter.")
# anova(m0, m1)
#
# cat("============= Model includes two predictors. =============")
# m2 <- lm(quarter_mile_sec ~ 1 + miles_per_gallon + forward_gear_count_f, data=ds)
# summary(m2)
#
# cat("The two predictor is significantly tighter.")
# anova(m1, m2)
#
# # ---- model-results-table  -----------------------------------------------
# summary(m2)$coef %>%
#   knitr::kable(
#     digits      = 2,
#     format      = "markdown"
#   )
#
# # Uncomment the next line for a dynamic, JavaScript [DataTables](https://datatables.net/) table.
# # DT::datatable(round(summary(m2)$coef, digits = 2), options = list(pageLength = 2))
