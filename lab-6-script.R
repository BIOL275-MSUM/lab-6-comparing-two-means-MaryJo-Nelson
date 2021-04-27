
# load packages -----------------------------------------------------------

library(tidyverse)


# read data ---------------------------------------------------------------

fish <- read_csv("chap12q19ElectricFish.csv")


# put data in tidy format ------------------------------------------------

fish_long <- 
  pivot_longer(fish, speciesUpstream:speciesDownstream,
               names_to = "location",
               values_to = "species") %>% 
  mutate(location = str_remove(location, c("species"))) %>% 
  print()

# Questions ----------------------------------------------------------------

# For each question below, write a sentence answering the question and show the 
# code you used to come up with the answer, if applicable.


# Question A --------------------------------------------------------------

# What is the mean different in the number of species between areas upstream and 
# downstream of a tributary? 

  ## The mean difference is 1.83334

# What is the 95% confidence interval of this mean difference. 

  ## The 95% confidence interval of the mean difference is 
  ## -4.587031 < x < 8.253697

# Show your code and write a sentence giving your answer

ttest <- t.test(formula = species ~ location, data = fish_long)
ttest

diff(ttest$estimate)





# Question B --------------------------------------------------------------

# Test the hypothesis that the tributaries have no effect on the number of 
# species of electric fish.

  ## Based on the t-test, we can fail to reject the hypothesis that tributaries
  ## have no effect on the number of species of electric fish for the following
  ## reasons:

    # The p-value is greater than the assumed alpha of 0.05
    # The confidence interval encompasses 0, meaning that the difference in the 
        # means could be 0
    # The graph shows that there is significan overlap between the confidence 
        # intervals for areas upstream and downstream of tributaries

fish_summary <-
  fish_long %>% 
  group_by(location) %>% 
  summarize(
    n = n(),
    mean = mean(species),
    sd = sd(species),
    sem = sd/sqrt(n),
    upper = mean + 1.96 * sem,
    lower = mean - 1.96 * sem
  ) %>% 
  print()


fish_long %>% 
  ggplot(aes(x = location, y = species)) +
  geom_jitter(aes(color = location), 
              shape = 16, size = 3, 
              alpha = 0.3, width = 0.4) +
  geom_errorbar(aes(y = mean, ymax = upper, ymin = lower), 
                data = fish_summary, 
                width = .1, size = .8) +
  geom_point(aes(y = mean), 
             data = fish_summary, 
             size = 3) +
  scale_color_manual(values = c("darkorange","cyan4")) +
  theme_minimal() +
  guides(color = "none")


# Question C --------------------------------------------------------------

# State the assumptions that you had to make to complete parts (A) and (B). 

# Create a graph to assess whether one of those assumptions was met.

    ## The assumptions we had to make were that the sampling units were randomly 
    ## sampled from the population and that the paired differences have a normal
    ## distribution in populations.

fish_long %>% 
  ggplot(aes(x = species)) +
  geom_histogram(
    aes(fill = location), 
    bins = 8, 
    alpha = 0.5, 
    position = "identity"
  ) +
  scale_fill_manual(values = c("darkorange","cyan4")) +
  theme_minimal()

    ## The distribution appears not to be normal, but rather is skewed right.


# ANOVA-crabs -------------------------------------------------------------

# Read Data
crabs <- read_csv("chap15q27FiddlerCrabFans.csv") %>%
  rename(type = crabType, temp = bodyTemperature)
crabs

temp_means <-
  crabs %>% 
  filter(!is.na(temp)) %>%      # remove missing values
  group_by(type) %>% 
  summarize(
    mean = mean(temp),
    sd = sd(temp),
    n = n(),
    sem = sd / sqrt(n),
    upper = mean + 1.96 * sem,
    lower = mean - 1.96 * sem
  ) %>% 
  print()


# Question D --------------------------------------------------------------

  ## Graph the distribution of body temperatures for each crab type:

# Distribution
crabs %>% 
  ggplot(aes(x = temp)) +
  geom_histogram(
    aes(fill = type), 
    bins = 13, 
    alpha = 0.5, 
    position = "identity",
    na.rm = TRUE
  ) +
  scale_fill_manual(values = c("darkorange", "darkorchid", "cyan4", "#C24641")) +
  labs(title = "Distribution of Temperatures for each Crab Type", x = "Temperature", 
       y = "Count")
  theme_minimal()

# Means and CI
ggplot(data = crabs, aes(x = type, y = temp)) +
  geom_jitter(aes(color = type),
              width = 0.1,
              alpha = 0.7,
              show.legend = FALSE,
              na.rm = TRUE) +
  geom_errorbar(aes(y = mean, ymin = lower, ymax = upper), 
                data = temp_means,
                width = .1, position = position_nudge(.3)) +
  geom_point(aes(y = mean), data = temp_means,
             position = position_nudge(.3)) +
  scale_color_manual(values = c("darkorange","darkorchid","cyan4", "#C24641")) +
  labs(title = "Means and Confidence Intervals for Temperatures of Each Crab Type", 
       x = "Crab Type", y = "Temperature")


# Question E --------------------------------------------------------------

  ## Does body temperature varies among crab types? State the null and alternative 
  ## hypothesis, conduct and ANOVA, and interpret the results.

    ### The temperature does appear to vary among crab types based on the distribution.
    
    ### The null hypothesis for the ANOVA test is the that the temperature does not 
      # vary among crap types, and the alternative hypothesis is that the temperature
      # of at least one crab type does vary from the rest.

(aov_crab_temps <- aov(temp ~ type, data = crabs))

summary(aov_crab_temps)
