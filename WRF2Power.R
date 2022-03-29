############################################################################################################
#
# This script shows the methodology followed to simulate thea PV Plant production from a Tslist WRF output  
# file, to obtain the power production of the plant. By Sosa-Tinoco, Ian; Prosper, Miguel A.; Miguez-Macho, 
# Gonzalo.
# 
#############################################################################################################

library(solaR)
library(readxl)
library(lubridate)

##### PV Plant Characteristics ################
mod1 <- list(Vocn=36.4, Iscn=8.2, Vmn= 28.3, Imn=7.6, Ncs = 20, Ncp = 3, CoefVT = 0.0052, TONC = 43) #PV Module 
gen1 <- list(Nms = 21, Nmp = 24)  #Array Info 
inv1 <- list(Ki = c(0.0101, 0.018, 0.03), Pinv = 100000, Vmin =450, Vmax = 900, Gumb = 20) #Inverter
eff1 <- list(ModQual = 5, ModDisp = 2, OhmDC = 3, OhmAC = 1.5, MPP = 1, TrafoMT = 1, Disp = 0.5) #Eficciency Losses
b = 30 #declination
lon=-6.5593889 #Longitud
lat=37.421733  #Latitude


WRF <- read.csv(file = "WRF_Tslist.csv") #### WRF Tstlist Import
WRFl$Ta <- (WRF$T2 - 273.15)   ### Kelvin to Celsius
drops <- c("WF_ID", "DATE_INI", "T2", "AOD5502D")  #List of columns not needed
WRF[drops] <- list(NULL)

names(WRF) <- c("date","G0", "B0", "B","D0", "Ta") ### Change the name of the columns needed by solaR package.

WRF$date <- with_tz(WRF$date, tz = 'Europe/Madrid') ### Change the timezone from UTC to UTC+1

WRF$date <- local2Solar(WRF$date, lon) #Change from the timezone of the region to solar hours.

#### Convert the data frame to Meteo File #####
Meteo <- dfI2Meteo(WRF, time.col = "date", lat=lat, source = "WRF", format = "%Y-%m-%d %H:%M:%S")

#### Run the simulation #####
Prod <- prodGCPV(lat = lat, modeRad = "bdI", dataRad = Meteo, beta = b, module = mod1, generator = gen1, inverter = inv1, effSys = eff1)

##### Extract the Power from the Inverter####
Inv_AC <- Prod@prodI$Pac

#### Write CSV ######
write.zoo(Inv_AC, file = 'name_your_file.csv', row.names = TRUE)


