#' Download, translate and read OSM extracts
#'
#' @param place Description of the geographical area that should be download
#'   through the chosen `provider`. Can be either a length-1 character vector, a
#'   length-1 `sfc_POINT` object or a numeric vector with length 2. See details
#'   and examples.
#' @param layer TODO
#' @param provider Which provider should be used to download the data? For the
#'   moment we support only [`"geofabrik"`](http://download.geofabrik.de/).
#' @param match_by Which column of the provider data should be used for matching
#'   the input place with the provider's data? The default is "name". Check
#'   details and examples to understand how this parameter works. Ignored if
#'   `place` is not a character vector since the matching is performed through a
#'   spatial operation.
#' @param max_string_dist Numeric value greater or equal than 0. What is the
#'   maximum distance in fuzzy matching to tolerate before asking the user to
#'   select which zone to download? This parameter is set equal to 0 if
#'   `match_by` is equal to `iso3166_1_alpha2` or `iso3166_2`. Check details and
#'   examples to understand why this parameter is important. Ignored if `place`
#'   is not a character vector since the matching is performed through a spatial
#'   operation.
#' @param interactive_ask Boolean. If `TRUE` the function creates and
#'   interactive menu in case the best match is further than `max_string_dist`.
#'   Check details and examples to understand why this parameter is important.
#'   Ignored if `place` is not a character vector since the matching is
#'   performed through a spatial operation.
#' @param download_directory TODO
#' @param force_download TODO
#' @param max_file_size TODO
#' @param vectortranslate_options TODO
#' @param osmconf_ini TODO
#' @param extra_attributes TODO
#' @param force_vectortranslate TODO
#' @param osmext_verbose Boolean. If `TRUE` the function prints informative messages.
#' @param ... Arguments that should  be passed to [`sf::st_read()`]
#'
#' @return An sf object related to the input place.
#' @export
#' @details This function is a wrapper around ...
#'
#' @examples
#' osmext_get("Isle of Wight", provider = "test")
osmext_get = function(
  place,
  layer = "lines",
  provider = "geofabrik",
  ...,
  match_by = "name",
  max_string_dist = 1,
  interactive_ask = FALSE,
  download_directory = osmext_download_directory(),
  force_download = FALSE,
  max_file_size = 5e+8,
  vectortranslate_options = NULL,
  osmconf_ini = NULL,
  extra_attributes = NULL,
  force_vectortranslate = NULL,
  osmext_verbose = FALSE
) {

  # Match the input place with the provider's data.
  matched_zone <- osmext_match(
    place = place,
    provider = provider,
    match_by = match_by,
    max_string_dist = max_string_dist,
    interactive_ask = interactive_ask,
    verbose = osmext_verbose
  )

  # Extract the matched url and file size and pass these parameters to the
  # osmext-download function.
  file_url <- matched_zone[["url"]]
  file_size <- matched_zone[["file_size"]]
  file_path <- osmext_download(
    file_url = file_url,
    download_directory = download_directory,
    file_size = file_size,
    force_download = force_download,
    max_file_size = max_file_size,
    verbose = osmext_verbose
  )

  # Pass the file_path to osmext_vectortranslate
  gpkg_file_path = osmext_vectortranslate(
    file_path = file_path,
    vectortranslate_options = vectortranslate_options,
    layer = layer,
    osmconf_ini = osmconf_ini,
    extra_attributes = extra_attributes,
    force_vectortranslate = force_vectortranslate,
    verbose = osmext_verbose
  )

  # Read the translated file with sf::st_read
  sf::st_read(
    dsn = gpkg_file_path,
    layer = layer,
    ...
  )

}
