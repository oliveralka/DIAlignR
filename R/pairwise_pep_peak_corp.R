#' Outputs AlignObj from an alignment of two XIC-groups
#'
#' @author Shubham Gupta, \email{shubh.gupta@mail.utoronto.ca}
#'
#' ORCID: 0000-0003-3500-8152
#'
#' License: (c) Author (2019) + GPL-3
#' Date: 2019-12-13
#'
#' @param XICs.ref List of extracted ion chromatograms from reference run.
#' @param XICs.eXp List of extracted ion chromatograms from experiment run.
#' @param globalFit Linear or loess fit object between reference and experiment run.
#' @param alignType Available alignment methods are "global", "local" and "hybrid".
#' @param adaptiveRT (numeric) Similarity matrix is not penalized within adaptive RT.
#' @param normalization (character) Must be selected from "mean", "l2".
#' @param simType (string) Must be selected from dotProduct, cosineAngle,
#' cosine2Angle, dotProductMasked, euclideanDist, covariance and correlation.
#' @param goFactor (numeric) Penalty for introducing first gap in alignment. This value is multiplied by base gap-penalty.
#' @param geFactor (numeric) Penalty for introducing subsequent gaps in alignment. This value is multiplied by base gap-penalty.
#' @param cosAngleThresh (numeric) In simType = dotProductMasked mode, angular similarity should be higher than cosAngleThresh otherwise similarity is forced to zero.
#' @param OverlapAlignment (logical) An input for alignment with free end-gaps. False: Global alignment, True: overlap alignment.
#' @param dotProdThresh (numeric) In simType = dotProductMasked mode, values in similarity matrix higher than dotProdThresh quantile are checked for angular similarity.
#' @param gapQuantile (numeric) Must be between 0 and 1. This is used to calculate base gap-penalty from similarity distribution.
#' @param hardConstrain (logical) If FALSE; indices farther from noBeef distance are filled with distance from linear fit line.
#' @param samples4gradient (numeric) This parameter modulates penalization of masked indices.
#' @param objType (char) Must be selected from light, medium and heavy.
#' @return A S4 object. Three most-important slots are:
#' \item{indexA_aligned}{(integer) aligned indices of reference run.}
#' \item{indexB_aligned}{(integer) aligned indices of experiment run.}
#' \item{score}{(numeric) cumulative score of alignment.}
#'
#' @seealso \code{\link{alignChromatogramsCpp}}
#' @examples
#' data(XIC_QFNNTDIVLLEDFQK_3_DIAlignR, package="DIAlignR")
#' data(oswFiles_DIAlignR, package="DIAlignR")
#' XICs.ref <- XIC_QFNNTDIVLLEDFQK_3_DIAlignR[["run1"]][["14299_QFNNTDIVLLEDFQK/3"]]
#' XICs.eXp <- XIC_QFNNTDIVLLEDFQK_3_DIAlignR[["run2"]][["14299_QFNNTDIVLLEDFQK/3"]]
#' globalFit <- getGlobalAlignment(oswFiles_DIAlignR, ref = "run1", eXp = "run2",
#'  maxFdrGlobal = 0.05, spanvalue = 0.1)
#' AlignObj <- getAlignObj(XICs.ref, XICs.eXp, globalFit, alignType = "hybrid", adaptiveRT = 77.82315,
#'  normalization = "mean", simType = "dotProductMasked", goFactor = 0.125,
#'   geFactor = 40, cosAngleThresh = 0.3, OverlapAlignment = TRUE, dotProdThresh = 0.96,
#'   gapQuantile = 0.5, hardConstrain = FALSE, samples4gradient = 100, objType = "light")
#' @export
getAlignObj <- function(XICs.ref, XICs.eXp, globalFit, alignType, adaptiveRT,
                        normalization, simType, goFactor, geFactor,
                        cosAngleThresh, OverlapAlignment,
                        dotProdThresh, gapQuantile, hardConstrain,
                        samples4gradient, objType = "light"){
  tVec.ref <- XICs.ref[[1]][["time"]] # Extracting time component
  tVec.eXp <- XICs.eXp[[1]][["time"]] # Extracting time component
  len <- length(tVec.ref)
  B1p <- stats::predict(globalFit, data.frame("RT.ref" = tVec.ref[1]))[[1]]
  B2p <- stats::predict(globalFit, data.frame("RT.ref" = tVec.ref[len]))[[1]]

  # Set up constraints for penalizing similarity matrix
  samplingTime <- (tVec.ref[len] - tVec.ref[1])/(len-1)
  noBeef <- ceiling(adaptiveRT/samplingTime)

  # Perform dynamic programming for chromatogram alignment
  intensityList.ref <- lapply(XICs.ref, `[[`, 2) # Extracting intensity values
  intensityList.eXp <- lapply(XICs.eXp, `[[`, 2) # Extracting intensity values
  AlignObj <- alignChromatogramsCpp(intensityList.ref, intensityList.eXp,
                                    alignType, tVec.ref, tVec.eXp,
                                    normalization = normalization, simType = simType,
                                    B1p = B1p, B2p = B2p, noBeef = noBeef,
                                    goFactor = goFactor, geFactor = geFactor,
                                    cosAngleThresh = cosAngleThresh, OverlapAlignment = OverlapAlignment,
                                    dotProdThresh = dotProdThresh, gapQuantile = gapQuantile,
                                    hardConstrain = hardConstrain, samples4gradient = samples4gradient,
                                    objType = objType)
  AlignObj
}

#' Get mapping of reference RT on experiment run.
#'
#' This function aligns XICs of reference and experiment runs. Using alignment, it maps retention time from refernce run on experiment run.
#' @author Shubham Gupta, \email{shubh.gupta@mail.utoronto.ca}
#'
#' ORCID: 0000-0003-3500-8152
#'
#' License: (c) Author (2019) + GPL-3
#' Date: 2019-12-13
#' @param refRT Peak's retention-time in reference run.
#' @param XICs.ref List of extracted ion chromatograms from reference run.
#' @param XICs.eXp List of extracted ion chromatograms from experiment run.
#' @param globalFit Linear or loess fit object between reference and experiment run.
#' @param alignType Available alignment methods are "global", "local" and "hybrid".
#' @param adaptiveRT (numeric) Similarity matrix is not penalized within adaptive RT.
#' @param normalization (character) Must be selected from "mean", "l2".
#' @param simMeasure (string) Must be selected from dotProduct, cosineAngle,
#' cosine2Angle, dotProductMasked, euclideanDist, covariance and correlation.
#' @param goFactor (numeric) Penalty for introducing first gap in alignment. This value is multiplied by base gap-penalty.
#' @param geFactor (numeric) Penalty for introducing subsequent gaps in alignment. This value is multiplied by base gap-penalty.
#' @param cosAngleThresh (numeric) In simType = dotProductMasked mode, angular similarity should be higher than cosAngleThresh otherwise similarity is forced to zero.
#' @param OverlapAlignment (logical) An input for alignment with free end-gaps. False: Global alignment, True: overlap alignment.
#' @param dotProdThresh (numeric) In simType = dotProductMasked mode, values in similarity matrix higher than dotProdThresh quantile are checked for angular similarity.
#' @param gapQuantile (numeric) Must be between 0 and 1. This is used to calculate base gap-penalty from similarity distribution.
#' @param hardConstrain (logical) If FALSE; indices farther from noBeef distance are filled with distance from linear fit line.
#' @param samples4gradient (numeric) This parameter modulates penalization of masked indices.
#' @param objType (char) Must be selected from light, medium and heavy.
#' @return (numeric)
#' @seealso \code{\link{alignChromatogramsCpp}}
#' @keywords internal
#' @examples
#' data(XIC_QFNNTDIVLLEDFQK_3_DIAlignR, package="DIAlignR")
#' data(oswFiles_DIAlignR, package="DIAlignR")
#' XICs.ref <- XIC_QFNNTDIVLLEDFQK_3_DIAlignR[["run1"]][["14299_QFNNTDIVLLEDFQK/3"]]
#' XICs.eXp <- XIC_QFNNTDIVLLEDFQK_3_DIAlignR[["run2"]][["14299_QFNNTDIVLLEDFQK/3"]]
#' globalFit <- getGlobalAlignment(oswFiles_DIAlignR, ref = "run2", eXp = "run0",
#'  maxFdrGlobal = 0.05, spanvalue = 0.1)
#' adaptiveRT <- 77.82315 #3.5*globalFit$s
#' \dontrun{
#' getMappedRT(refRT = 5238.35, XICs.ref, XICs.eXp, globalFit, alignType = "hybrid",
#'  adaptiveRT = adaptiveRT, normalization = "mean",
#'   simMeasure = "dotProductMasked", goFactor = 0.125, geFactor = 40, cosAngleThresh = 0.3,
#'   OverlapAlignment = TRUE, dotProdThresh = 0.96, gapQuantile = 0.5, hardConstrain = FALSE,
#'   samples4gradient = 100)
#' }
getMappedRT <- function(refRT, XICs.ref, XICs.eXp, globalFit, alignType, adaptiveRT,
                        normalization, simMeasure, goFactor, geFactor, cosAngleThresh,
                        OverlapAlignment, dotProdThresh, gapQuantile, hardConstrain,
                        samples4gradient, objType = "light"){
  AlignObj <- getAlignObj(XICs.ref, XICs.eXp, globalFit, alignType, adaptiveRT,
                          normalization, simType = simMeasure, goFactor, geFactor,
                          cosAngleThresh, OverlapAlignment,
                          dotProdThresh, gapQuantile, hardConstrain, samples4gradient, objType)
  tVec.ref <- XICs.ref[[1]][["time"]] # Extracting time component
  tVec.eXp <- XICs.eXp[[1]][["time"]] # Extracting time component
  eXpRT <- mappedRTfromAlignObj(refRT, tVec.ref, tVec.eXp, AlignObj)
  eXpRT
}

#' Get aligned Retention times.
#'
#' This function aligns XICs of reference and experiment runs.
#' It produces aligned retention times between refernce run and experiment run.
#' @author Shubham Gupta, \email{shubh.gupta@mail.utoronto.ca}
#'
#' ORCID: 0000-0003-3500-8152
#'
#' License: (c) Author (2019) + GPL-3
#' Date: 2019-12-13
#' @param XICs.ref List of extracted ion chromatograms from reference run.
#' @param XICs.eXp List of extracted ion chromatograms from experiment run.
#' @param globalFit Linear or loess fit object between reference and experiment run.
#' @param alignType Available alignment methods are "global", "local" and "hybrid".
#' @param adaptiveRT (numeric) Similarity matrix is not penalized within adaptive RT.
#' @param normalization (character) Must be selected from "mean", "l2".
#' @param simMeasure (string) Must be selected from dotProduct, cosineAngle,
#' cosine2Angle, dotProductMasked, euclideanDist, covariance and correlation.
#' @param goFactor (numeric) Penalty for introducing first gap in alignment. This value is multiplied by base gap-penalty.
#' @param geFactor (numeric) Penalty for introducing subsequent gaps in alignment. This value is multiplied by base gap-penalty.
#' @param cosAngleThresh (numeric) In simType = dotProductMasked mode, angular similarity should be higher than cosAngleThresh otherwise similarity is forced to zero.
#' @param OverlapAlignment (logical) An input for alignment with free end-gaps. False: Global alignment, True: overlap alignment.
#' @param dotProdThresh (numeric) In simType = dotProductMasked mode, values in similarity matrix higher than dotProdThresh quantile are checked for angular similarity.
#' @param gapQuantile (numeric) Must be between 0 and 1. This is used to calculate base gap-penalty from similarity distribution.
#' @param hardConstrain (logical) If FALSE; indices farther from noBeef distance are filled with distance from linear fit line.
#' @param samples4gradient (numeric) This parameter modulates penalization of masked indices.
#' @param objType (char) Must be selected from light, medium and heavy.
#' @return (list) the first element corresponds to the aligned reference time, the second element is the aligned experiment time.
#' @seealso \code{\link{alignChromatogramsCpp}, \link{getAlignObj}}
#' @examples
#' data(XIC_QFNNTDIVLLEDFQK_3_DIAlignR, package="DIAlignR")
#' data(oswFiles_DIAlignR, package="DIAlignR")
#' XICs.ref <- XIC_QFNNTDIVLLEDFQK_3_DIAlignR[["run1"]][["14299_QFNNTDIVLLEDFQK/3"]]
#' XICs.eXp <- XIC_QFNNTDIVLLEDFQK_3_DIAlignR[["run2"]][["14299_QFNNTDIVLLEDFQK/3"]]
#' globalFit <- getGlobalAlignment(oswFiles_DIAlignR, ref = "run2", eXp = "run0",
#'  maxFdrGlobal = 0.05, spanvalue = 0.1)
#' adaptiveRT <- 77.82315 #3.5*globalFit$s
#' getAlignedIndices(XICs.ref, XICs.eXp, globalFit, alignType = "hybrid",
#'  adaptiveRT = adaptiveRT, normalization = "mean",
#'   simMeasure = "dotProductMasked", goFactor = 0.125, geFactor = 40, cosAngleThresh = 0.3,
#'   OverlapAlignment = TRUE, dotProdThresh = 0.96, gapQuantile = 0.5, hardConstrain = FALSE,
#'   samples4gradient = 100)
#' @export
getAlignedIndices <- function(XICs.ref, XICs.eXp, globalFit, alignType, adaptiveRT,
                        normalization, simMeasure, goFactor, geFactor, cosAngleThresh,
                        OverlapAlignment, dotProdThresh, gapQuantile, hardConstrain,
                        samples4gradient, objType = "light"){
  AlignObj <- getAlignObj(XICs.ref, XICs.eXp, globalFit, alignType, adaptiveRT,
                          normalization, simType = simMeasure, goFactor, geFactor,
                          cosAngleThresh, OverlapAlignment,
                          dotProdThresh, gapQuantile, hardConstrain, samples4gradient, objType)
  AlignedIndices <- cbind(AlignObj@indexA_aligned,
                          AlignObj@indexB_aligned,
                          AlignObj@score)
  colnames(AlignedIndices) <- c("indexAligned.ref", "indexAligned.eXp", "score")
  skip <- (AlignedIndices[,"indexAligned.ref"] != 0L)
  AlignedIndices[, 1:2][AlignedIndices[, 1:2] == 0] <- NA_integer_
  tVec.ref <- XICs.ref[[1]][["time"]] # Extracting time component
  tVec.eXp <- XICs.eXp[[1]][["time"]] # Extracting time component
  tAligned.ref <- mapIdxToTime(tVec.ref, AlignedIndices[,"indexAligned.ref"])
  tAligned.eXp <- mapIdxToTime(tVec.eXp, AlignedIndices[,"indexAligned.eXp"])
  tAligned.ref <- tAligned.ref[skip]
  tAligned.eXp <- tAligned.eXp[skip]
  list(tAligned.ref, tAligned.eXp)
}
