# Media Logging App

This app (Android and iOS compatible) is custom way to log you games, movies, tv-series and books and automatically creates statistics from the logged data. The data is fetched from the the following databases:
- IGDB for games
- TMDB for movies and tv-series
- Google Book for books

All media types are logged in a similar way with an image and some additional metadata. Tapping on the "Media-Logging" Title switches the app to the statistics mode where graphs are generated. 

In order for this app to work a .env file must be created with the following content:
````
IGDB_CLIENT=<client-id>
IGDB_SECRET=<client-secret>
TMDB_V3=<tmdb-v3>
TMDB_TOKEN_V4=<tmdb-token-v4>
````
If you don't provide your own api keys this way the search function will not work and it'll only be possible to add entries manually for the media type with the missing api access. 
For the igdb and tmdb keys please refer to the official instructions:
- [IGDB](https://api-docs.igdb.com/#getting-started)
- [TMDB](https://developer.themoviedb.org/reference/intro/getting-startedV)