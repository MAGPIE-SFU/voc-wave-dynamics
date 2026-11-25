
# make a VOC/VOI group dataframe for grouping (and color palette) 
VOCVOI <- data.frame(name = character(),pattern = character())
VOCVOI[nrow(VOCVOI)+1, ]=list("wildtype A*",   "^A(\\.\\d+)*$")       #A cluster
VOCVOI[nrow(VOCVOI)+1, ]=list("wildtype B*",   "^B|B\\.1.|AB.1|AE.1|AV.1|AE.3|AE.2|AE.4|AE.5|AE.7|AN.1|AE.8|AD.2|AK.1|AM.2|AA.1|AL.1|AH.2|AQ.2|AG.1|AK.2|AS.2|AC.1|AW.1|AE.6|AF.1|AA.6|AH.3|AA.3|AA.4|AS.1|AM.3|AM.4|AD.1|AA.7|AJ.1|AM.1|AA.2|AQ.1|AA.8|AD.2.1|AA.5|AU.1|AU.2|AZ.5|AH.1|AZ.1|AT.1|AZ.2|AU.3|AZ.4|AZ.3|AZ.6|AZ.2.1
")           #B cluster
VOCVOI[nrow(VOCVOI)+1, ]=list("Alpha*",        "B.1.1\\.7$|^Q.|AP.1") #alpha+
VOCVOI[nrow(VOCVOI)+1, ]=list("Beta",          "B.1.351")             #beta
VOCVOI[nrow(VOCVOI)+1, ]=list("Gamma",         "^P.1")                #gamma
VOCVOI[nrow(VOCVOI)+1, ]=list("Lambda",        "^C.37|C.37.1")        #lambda
VOCVOI[nrow(VOCVOI)+1, ]=list("Mu",            "B.1.621")             #mu
VOCVOI[nrow(VOCVOI)+1, ]=list("Kappa",         "B.1.617.1")           #kappa
VOCVOI[nrow(VOCVOI)+1, ]=list("Eta",           "B.1.525")             #eta
VOCVOI[nrow(VOCVOI)+1, ]=list("Iota",          "B.1.526")             #iota
VOCVOI[nrow(VOCVOI)+1, ]=list("Epsilon",       "B.1.427|B.1.429")     #epsilon
VOCVOI[nrow(VOCVOI)+1, ]=list("Delta*",         "B.1.617.2|AY.")      #delta+
VOCVOI[nrow(VOCVOI)+1, ]=list("Omicron BA.1*",  "B.1.1.529|BA.1|BA.1.|BC.|BD.")#omicron BA.1+
VOCVOI[nrow(VOCVOI)+1, ]=list("Omicron BA.2*",  "BA.2|BA.2.|BJ.|BG.|BP.|BS.|CM."          )#omicron BA.2+
#VOCVOI[nrow(VOCVOI)+1, ]=list("Omicron BA.2.12.1*",  "BA.2.12.1|BA.2.12.1.")#omicron BA.2.12.1+
VOCVOI[nrow(VOCVOI)+1, ]=list("Omicron BA.4*",  "BA.4|BA.4.|DC.1|CS.1"          )#omicron BA.4
VOCVOI[nrow(VOCVOI)+1, ]=list("Omicron BA.5*",  "BA.5|BA.5.|BE.|BW.|BK.|BF.|BT.|BZ.|BV.|BU.|
CD.|CK.|CN.|CQ.|CL.|CU.|CG.|CF.|CE.|CP.|CR.|CT.|CY.|DA.|DB.|DE.|DF.|DG.|DJ.|DL.|DH.|DQ.|DZ.|DY." )#omicron BA.5
#VOCVOI[nrow(VOCVOI)+1, ]=list("Omicron BA.5.2*",  "BA.5.2|BA.5.2.")   #omicron BA.5.2.x
#VOCVOI[nrow(VOCVOI)+1, ]=list("Omicron BE/BF*",  "BA.5.3|BA.5.3.|BE.|BF.") #omicron BA.5.3.x
VOCVOI[nrow(VOCVOI)+1, ]=list("Omicron BA.2.75*",  "BA.2.75|BA.2.75.|BM.|BN.|BL.|BR.|BY.|CA.|CB.|CH.|CJ.|CV.|
EP.|EJ.|DV.|DS.") #omicron BA.2.75+
VOCVOI[nrow(VOCVOI)+1, ]=list("Omicron BQ.*",  "BQ.|EC.|ER.|EH.|EN.|ES.|ET.|EZ.|ED.|EE.|CZ.|DK.|DR.|DP.|DM.|DU.|DN.|DT.") #omicron BA.2.75
VOCVOI[nrow(VOCVOI)+1, ]=list("Recombinants",  "X") #recombinants
VOCVOI[nrow(VOCVOI)+1, ]=list("XBB*",  "XBB") #XBB*
#VOCVOI[nrow(VOCVOI)+1, ]=list("XAC*",  "XAC.") #XAC, canadian recombinant lineage
#VOCVOI[nrow(VOCVOI)+1, ]=list("XBB.1.5*",  "XBB.1.5|XBB.1.5.") #XBB.1.5*
#VOCVOI[nrow(VOCVOI)+1, ]=list("Deltacrons*",  "XBF|....") #Deltacrons
VOCVOI[nrow(VOCVOI)+1, ]=list("Unassigned",  "Unassigned") #unassigned


# #function for applying to metadata:
# # make a pango.group column (using the patterns determined above)
# metadata$VOC <-rep("other",length(metadata$pango_lineage))
# for (row in 1:nrow(VOCVOI)) {
#   name <- VOCVOI[row, "name"]
#   pattern=gsub("\\.",".",VOCVOI[row, "pattern"])
#   metadata$VOC[grepl(pattern, metadata$pango_lineage)] <- name
# }


# generate color palette
library("RColorBrewer")
colourcount <- length(unique(VOCVOI$name))
getpal <- colorRampPalette(rev(brewer.pal(9,"Set1"))) #rev(brewer.pal(9,Set1
pal <- getpal(colourcount)
names(pal)<- unique(VOCVOI$name)[order(unique(VOCVOI$name))]
# change some colours (and add "other")
pal["other"][[1]] <- "grey"
pal["Delta*"][[1]] <- "darkorchid"
pal["Unassigned"][[1]] <- "black"
pal["Omicron BA.4*"][[1]] <- "#A6CEE3"
pal["Omicron BA.5*"][[1]] <- "#1F78B4"
pal["Omicron BQ.*"][[1]] <- "darkolivegreen"
pal["Alpha*"][[1]] <- "#4DAF4A"
pal["Omicron BA.2*"][[1]] <- "firebrick2"
pal["XBB*"][[1]] <- "bisque1" 
pal["Omicron BA.2.75*"][[1]] <- "#C51B7D"
  
# #in ggplot use this for calling the palette:
# #scale_fill_manual(breaks=names(pal), values = pal)+

# Code provided by Carmen Lia Murall, edited by Nathan K Smith
# May 2023