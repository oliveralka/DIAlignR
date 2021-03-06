% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/align_dia_runs.R
\name{alignTargetedRuns}
\alias{alignTargetedRuns}
\title{Outputs intensities for each analyte from aligned Targeted-MS runs}
\usage{
alignTargetedRuns(
  dataPath,
  outFile = "DIAlignR.csv",
  oswMerged = TRUE,
  runs = NULL,
  runType = "DIA_Proteomics",
  maxFdrQuery = 0.05,
  XICfilter = "sgolay",
  polyOrd = 4,
  kernelLen = 9,
  globalAlignment = "loess",
  globalAlignmentFdr = 0.01,
  globalAlignmentSpan = 0.1,
  RSEdistFactor = 3.5,
  normalization = "mean",
  simMeasure = "dotProductMasked",
  alignType = "hybrid",
  goFactor = 0.125,
  geFactor = 40,
  cosAngleThresh = 0.3,
  OverlapAlignment = TRUE,
  dotProdThresh = 0.96,
  gapQuantile = 0.5,
  hardConstrain = FALSE,
  samples4gradient = 100,
  analyteFDR = 0.01,
  unalignedFDR = 0.01,
  alignedFDR = 0.05,
  baselineType = "base_to_base",
  integrationType = "intensity_sum",
  fitEMG = FALSE,
  recalIntensity = FALSE,
  fillMissing = TRUE,
  smoothPeakArea = FALSE
)
}
\arguments{
\item{dataPath}{(string) path to mzml and osw directory.}

\item{outFile}{(string) name of the output file.}

\item{oswMerged}{(logical) TRUE for experiment-wide FDR and FALSE for run-specific FDR by pyprophet.}

\item{runs}{(A vector of string) names of mzml file without extension.}

\item{runType}{(string) must be one of the strings "DIA_proteomics", "DIA_Metabolomics".}

\item{maxFdrQuery}{(numeric) a numeric value between 0 and 1. It is used to filter features from osw file which have SCORE_MS2.QVALUE less than itself.}

\item{XICfilter}{(string) must be either sgolay, boxcar, gaussian, loess or none.}

\item{polyOrd}{(integer) order of the polynomial to be fit in the kernel.}

\item{kernelLen}{(integer) number of data-points to consider in the kernel.}

\item{globalAlignment}{(string) must be from "loess" or "linear".}

\item{globalAlignmentFdr}{(numeric) a numeric value between 0 and 1. Features should have m-score lower than this value for participation in LOESS fit.}

\item{globalAlignmentSpan}{(numeric) spanvalue for LOESS fit. For targeted proteomics 0.1 could be used.}

\item{RSEdistFactor}{(numeric) defines how much distance in the unit of rse remains a noBeef zone.}

\item{normalization}{(character) must be selected from "mean", "l2".}

\item{simMeasure}{(string) must be selected from dotProduct, cosineAngle,
cosine2Angle, dotProductMasked, euclideanDist, covariance and correlation.}

\item{alignType}{available alignment methods are "global", "local" and "hybrid".}

\item{goFactor}{(numeric) penalty for introducing first gap in alignment. This value is multiplied by base gap-penalty.}

\item{geFactor}{(numeric) penalty for introducing subsequent gaps in alignment. This value is multiplied by base gap-penalty.}

\item{cosAngleThresh}{(numeric) in simType = dotProductMasked mode, angular similarity should be higher than cosAngleThresh otherwise similarity is forced to zero.}

\item{OverlapAlignment}{(logical) an input for alignment with free end-gaps. False: Global alignment, True: overlap alignment.}

\item{dotProdThresh}{(numeric) in simType = dotProductMasked mode, values in similarity matrix higher than dotProdThresh quantile are checked for angular similarity.}

\item{gapQuantile}{(numeric) must be between 0 and 1. This is used to calculate base gap-penalty from similarity distribution.}

\item{hardConstrain}{(logical) if FALSE; indices farther from noBeef distance are filled with distance from linear fit line.}

\item{samples4gradient}{(numeric) modulates penalization of masked indices.}

\item{analyteFDR}{(numeric) defines the upper limit of FDR on a precursor to be considered for multipeptide.}

\item{unalignedFDR}{(numeric) must be between 0 and maxFdrQuery. Features below unalignedFDR are
considered for quantification even without the RT alignment.}

\item{alignedFDR}{(numeric) must be between unalignedFDR and 1. Features below alignedFDR are
considered for quantification after the alignment.}

\item{baselineType}{(string) method to estimate the background of a peak contained in XICs. Must be
from "base_to_base", "vertical_division_min", "vertical_division_max".}

\item{integrationType}{(string) method to ompute the area of a peak contained in XICs. Must be
from "intensity_sum", "trapezoid", "simpson".}

\item{fitEMG}{(logical) enable/disable exponentially modified gaussian peak model fitting.}

\item{recalIntensity}{(logical) recalculate intensity for all analytes.}

\item{fillMissing}{(logical) calculate intensity for ananlytes for which features are not found.}

\item{smoothPeakArea}{(logical) FALSE: raw chromatograms will be used for quantification. TRUE: smoothed chromatograms will be used for quantification.}
}
\value{
An output table with following columns: precursor, run, intensity, RT, leftWidth, rightWidth,
 peak_group_rank, m_score, alignment_rank, peptide_id, sequence, charge, group_label.
}
\description{
This function expects osw and mzml directories at dataPath. It first reads osw files and fetches chromatogram indices for each analyte.
It then align XICs of its reference XICs. Best peak, which has lowest m-score, about the aligned retention time is picked for quantification.
}
\examples{
dataPath <- system.file("extdata", package = "DIAlignR")
alignTargetedRuns(dataPath, outFile = "testDIAlignR.csv", oswMerged = TRUE)
}
\references{
Gupta S, Ahadi S, Zhou W, Röst H. "DIAlignR Provides Precise Retention Time Alignment Across Distant Runs in DIA and Targeted Proteomics." Mol Cell Proteomics. 2019 Apr;18(4):806-817. doi: https://doi.org/10.1074/mcp.TIR118.001132 Epub 2019 Jan 31.
}
\seealso{
\code{\link{getRunNames}, \link{getFeatures}, \link{setAlignmentRank}, \link{getMultipeptide}}
}
\author{
Shubham Gupta, \email{shubh.gupta@mail.utoronto.ca}

ORCID: 0000-0003-3500-8152

License: (c) Author (2019) + GPL-3
Date: 2019-12-14
}
