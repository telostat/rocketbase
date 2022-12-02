#' @title PocketBase API Client
#'
#' @description Instances of this class can be used for conveniently issuing
#' HTTP requests to remote PocketBase API instances.
#'
#' Note that this client only works with admin users at the moment.
#'
#' @importFrom crul HttpClient
#' @importFrom jsonlite fromJSON
#' @importFrom R6 R6Class
#' @export
RocketBase <- R6::R6Class("RocketBase", ## nolint
    public = list(
        #' @field url Base URL of the remote PocketBase API instance.
        url = NULL,

        #' @field bare Bare HTTP client for the remote PocketBase API instance.
        #'
        #' This is a plain vanilla `crul::HttpClient` instance that is ready to
        #' issue requests to remote PocketBase API instance. Indeed, this
        #' instance should be sufficient for most API communication with
        #' PocketBase API instances.
        bare = NULL,

        #' @description Creates a PocketBase API client instance.
        #'
        #' @param url Base URL of the remote PocketBase API instance.
        #' @param identity Identity credential for authentication.
        #' @param password Password credential for authentication.
        #'
        #' @return A new `RocketBase` object.
        #' @examples
        #' \dontrun{
        #' client <- rocketbase::RocketBase$new(
        #'     url = "https://httpbin.org",
        #'     identity = "hebele",
        #'     password = "hubele"
        #' )
        #' }
        initialize = function(url, identity, password) {
            self$url <- url
            private$identity <- identity
            private$password <- password
            private$setup()
        },

        #' @description Prints rudimentary information about the remote
        #' PocketBase API instance.
        info = function() {
            cat(sprintf("PocketBase Instance URL: %s\n", self$url))
        },

        #' @description Provides the print function for `RocketBase` object.
        print = function() {
            print(sprintf("<ROCKETBASE (url = %s)>", self$url))
        }
    ),
    private = list(
        ## Identity credential for the remote PocketBase API instance.
        identity = NULL,

        ## Password credential for the remote PocketBase API instance.
        password = NULL,

        ## Token credential for the remote PocketBase API instance.
        token = NULL,

        ## Setups this instance.
        setup = function() {
            ## Attempt to authenticate and get the authentication token:
            private$token <- private$authenticate()

            ## Build the bare HTTP client:
            self$bare <- crul::HttpClient$new(
                url = self$url,
                headers = list(
                    Authorization = sprintf("%s", private$token),
                    "User-Agent" = private$useragent()
                )
            )
        },

        ## Attempts to authenticate and get a token.
        authenticate = function() {
            ## Build the HTTP client:
            client <- crul::HttpClient$new(url = self$url)

            ## Define authentication endpoint path:
            path <- "/api/admins/auth-with-password"

            ## Define credentials payload:
            credentials <- list(
                identity = private$identity,
                password = private$password
            )

            ## Issue the authentication request and get a response:
            response <- client$post(path, body = credentials)

            ## If response status is not 200, raise error as it implies
            ## failed authentication:
            if (response$status_code != 200) {
                stop("Authentication failed.")
            }

            ## Parse the content of the response:
            content <- jsonlite::fromJSON(response$parse(encoding = "UTF-8"))

            ## Return the authentication token:
            content$token
        },

        ## Builds the user-agent string.
        useragent = function() {
            ## Get package version:
            version <- utils::packageVersion("rocketbase")

            ## Get operating system:
            sysname <- Sys.info()["sysname"]

            ## Build the "User-Agent" header value:
            sprintf("rocketbase/%s (%s)", version, sysname)
        }
    )
)
