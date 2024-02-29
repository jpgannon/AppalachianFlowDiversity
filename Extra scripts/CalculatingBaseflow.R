source("BaseflowSeparation.R")

#need to calculate flow in mm/day
QdatDV <- QdatDV |> 
  mutate(Qmm_day = 2.447 * q / DRAIN_SQKM)

# Create vector of gauge id's for for loop:
gauge_ids <- QdatDV$gauge_id

# Might want to write out this big CSV here!
#Input: Vector with baseflow
# Quick flow: total flow - baseflow
QdatDV$baseflow <- NA

for (x in gauge_ids) {
  QdatDV$baseflow[QdatDV$gauge_id == x] <- 
    BaseflowSeparation(QdatDV$Qmm_day[QdatDV$gauge_id == x])$bt
  
}

# Check output
QdatDV |> 
  filter(gauge_id == gauge_ids[1]) |> 
  ggplot(aes(x = date, y = Qmm_day)) +
  geom_line() +
  geom_line(aes(y=baseflow), color = "blue")