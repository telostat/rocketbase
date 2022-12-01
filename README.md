# rocketbase - Unofficial PocketBase API Client for R

![GitHub release (latest by date)](https://img.shields.io/github/v/release/telostat/rocketbase)
![github last commit](https://img.shields.io/github/last-commit/telostat/rocketbase)
![GitHub contributors](https://img.shields.io/github/contributors/telostat/rocketbase)

`rocketbase` is an unofficial [PocketBase](https://pocketbase.io/) API client
for R.

## Installation

`rocketbase` is currently not on [CRAN](https://cran.r-project.org/). The
easiest way to install it is using [devtools](https://devtools.r-lib.org/).

For the latest development snapshot:

```R
devtools::install_github("telostat/rocketbase", upgrade="ask")
```

For the latest version (`X.Y.Z`, following [semantic
versioning](https://semver.org/)):

```R
devtools::install_github("telostat/rocketbase", ref="X.Y.Z", upgrade="ask")
```

## Development

Enter the Nix shell and launch PocketBase:

```sh
nix-shell
pocketbase-serve
```

Create an admin user account on PocketBase. Now, on another console session,
enter Nix shell:

```sh
nix-shell
```

Launch R:

```sh
R
```

Here is a sample session:

```R
devtools::load_all(".")
rb <- rocketbase::RocketBase$new("http://localhost:8090", identity = "hebele@hubele.com", password = "hebelehubele")
response <- rb$bare$get("/api/collections/users/records")
stopifnot(response$status_code == 200)
my_data <- jsonlite::fromJSON(response$parse(encoding = "UTF-8"))
print(my_data)

table <- list(
    name = "observations",
    type = "base",
    system = FALSE,
    schema = list(
        list(
            "name" = "key",
            "type" = "text",
            "system" = FALSE,
            "required" = TRUE,
            "unique" = TRUE,
            "nullable" = FALSE
        ),
        list(
            "name" = "value",
            "type" = "text",
            "system" = FALSE,
            "required" = FALSE,
            "unique" = FALSE,
            "nullable" = TRUE
        )
    )
)
response <- rb$bare$post("/api/collections", encode = "json", body=table)
stopifnot(response$status_code == 200)

response <- rb$bare$get("/api/collections/observations/records")
stopifnot(response$status_code == 200)
my_data <- jsonlite::fromJSON(response$parse(encoding = "UTF-8"))
print(my_data)

response <- rb$bare$post("/api/collections/observations/records", encode = "json", body=list(
    key = "key1",
    value = "value1"
))
stopifnot(response$status_code == 200)

response <- rb$bare$post("/api/collections/observations/records", encode = "json", body=list(
    key = "key2",
    value = "value2"
))
stopifnot(response$status_code == 200)

response <- rb$bare$get("/api/collections/observations/records")
stopifnot(response$status_code == 200)
my_data <- jsonlite::fromJSON(response$parse(encoding = "UTF-8"))
print(my_data)
```

## License

This work is licensed under MIT license. See [LICENSE](./LICENSE.md).
