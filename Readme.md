# PokeTest

Memotest of Pokemon developed using Elm 0.17

## How to run
### Elm installation
To install Elm on Windows and Mac go to [Elm](http://elm-lang.org/install) and download the installer. 
To install on Linux install npm run:
```
$ npm install -g elm
```

### Compilation
To compile the game some libraries are necessary. To install them run:
```
$ elm-package install elm-community/random-extra 
$ elm-package install elm-lang/core
$ elm-package install elm-lang/html 
$ elm-package install shmookey/cmd-extra
```

Once installed the libraries run on the root of the project: 
```
$ elm make PokeTest.elm PokeCard.elm
```

Open index.html to play the game or [click here](https://bahui80.github.io/PokeTest/) to play online.