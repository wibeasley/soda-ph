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

path_input_maya     <- "data-public/raw/sample-maya.csv"
path_input_valencia <- "data-public/raw/sample-valencia.csv"

palette_dark <- c(
  "A&W"                         = "#4F2400"  # https://brandpalettes.com/aw-root-beer-color-codes/
  ,"Coke"                       = "#F40009"  # https://usbrandcolors.com/coca-cola-colors
  ,"Dr. Pepper"                 = "#711F25"  # https://brandpalettes.com/dr-pepper-color-codes/
  ,"Pepsi"                      = "#004B93"  # https://usbrandcolors.com/pepsi-colors/
  ,"Crush"                      = "#fe9820"  # https://colorpicker.me/#fe9820
  ,"Orange Crush"               = "#fe9820"  # https://colorpicker.me/#fe9820
  ,"Canada Dry"                 = "#238321"  # https://colorpicker.me/#238321
  ,"Cream Soda"                 = "#0f4557"  # https://colorpicker.me/#0f4557
  ,"Mtn. Dew"                   = "#94C93D"  # https://brandpalettes.com/mountain-dew-color-codes/
  ,"Mug Rootbeer"               = "#5A341F"  # https://brandpalettes.com/mug-root-beer-color-codes/
  ,"Cherry Bubly"               = "990014"   # https://colorpicker.me/#0f4557
  ,"Bubly(Cherry)"              = "990014"   # https://colorpicker.me/#0f4557
  ,"Fresca"                     = "#6dc8e2"  # https://colorpicker.me/#6dc8e2
  ,"San Pelligrino"             = "#d5a4d1"  # https://colorpicker.me/#d5a4d1
  ,"Perrier"                    = "#0f692b"  # https://colorpicker.me/#0f692b
  ,"La Croix"                   = "#d4c82c"  # https://colorpicker.me/#d4c82c
  ,"Spindrift"                  = "#10aaac"  # https://colorpicker.me/#10aaac
  ,"Izze(blackberry)"           = "#87265d"  # https://colorpicker.me/#87265d
  ,"Topo Chico"                 = "#ded03b"  # https://colorpicker.me/#ded03b
  ,"Voss"                       = "#80ba72"  # https://colorpicker.me/#80ba72
  ,"Fever-tree(ginger ale)"     = "#617242"  # https://colorpicker.me/#617242
  ,"Best choice(strawberry)"    = "#14c3b3"  # https://colorpicker.me/#14c3b3
  ,"Waterloo(Black Cherry)"     = "#8740e5"  # https://colorpicker.me/#8740e5
)

# Execute to specify the column types.  It might require some manual adjustment (eg doubles to integers).
#   OuhscMunge::readr_spec_aligned(path_input_maya)
col_types_maya <- readr::cols_only(
    substrate            = readr::col_character(),
    can_index            = readr::col_integer(),
    duration_min         = readr::col_integer(),
    temp_c               = readr::col_double(),
    ph                   = readr::col_double()
)
#   OuhscMunge::readr_spec_aligned(path_input_valencia)
col_types_valencia <- readr::cols_only(
    substrate            = readr::col_character(),
    can_index            = readr::col_integer(),
    temp_c               = readr::col_double(),
    ph                   = readr::col_double()
)

# ---- load-data ---------------------------------------------------------------
ds_maya     <- readr::read_csv(path_input_maya    , col_types = col_types_maya)
ds_valencia <- readr::read_csv(path_input_valencia, col_types = col_types_valencia)

# ---- tweak-data --------------------------------------------------------------
ds_maya <-
  ds_maya %>%
  dplyr::mutate(
    can = paste(substrate, can_index)
  ) %>%
  dplyr::filter(substrate != "Dr. Pepper")

ds_valencia <-
  ds_valencia %>%
  dplyr::mutate(
    can = paste(substrate, can_index)
  )

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

# ---- spaghetti-maya ------------------------------------------------------------
ds_maya %>%
  ggplot(aes(x=duration_min, y=ph, group=can, color=substrate, label=can_index)) +
  geom_smooth(aes(group = substrate),  method="loess", formula = "y~x", span=2, se = F) +
  # geom_line(alpha = .4) +
  geom_text(alpha = .4, show.legend = FALSE) +
  scale_color_manual(values = palette_dark) +
  guides(color = guide_legend(override.aes = list(alpha = 1))) +
  theme_minimal() +
  theme(axis.ticks = element_blank()) +
  theme(legend.position = "right") +
  # theme(legend.position = c(1, 1)) +
  # theme(legend.justification = c(1, 1)) +
  theme(legend.background  = element_blank()) +
  labs(
    title   = NULL,
    x       = "Duration (min)",
    y       = "pH",
    color   = NULL
  )

last_plot() +
  geom_line(alpha = .4)

last_plot() +
  facet_wrap(~substrate) +
  theme_light() +
  theme(legend.position = "none")

# ---- scatter-valencia ------------------------------------------------------------
ds_valencia %>%
  ggplot(aes(x=temp_c, y=ph, group=can, color=substrate, label=can_index)) +
  # geom_smooth(aes(group = substrate),  method="loess", span=2, se = F) +
  geom_smooth(aes(group = substrate),  method="lm", formula = "y ~ x", se = F, na.rm = T) +
  # geom_point(alpha = .4) +
  geom_text(alpha = .8, show.legend = FALSE, na.rm = T) +
  scale_color_manual(values = palette_dark) +
  guides(color = guide_legend(override.aes = list(alpha = 1))) +
  theme_minimal() +
  theme(axis.ticks = element_blank()) +
  theme(legend.position = "right") +
  # theme(legend.position = c(1, 1)) +
  # theme(legend.justification = c(1, 1)) +
  theme(legend.background  = element_blank()) +
  labs(
    title   = NULL,
    x       = "Temperatue (C)",
    y       = "pH",
    color   = NULL
  )

last_plot() +
  facet_wrap(~substrate) +
  # geom_smooth(aes(group = substrate),  method="lm", span=3, se = F) +
  theme_light() +
  theme(legend.position = "none")

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
