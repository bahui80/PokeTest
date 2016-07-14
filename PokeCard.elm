module PokeCard exposing (Model, Msg, init, update, view, isFacingFront, setCardBack, setCardFound, isFound)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.App as Html

-- MAIN
init: String -> Model
init image = Model Back image

main = Html.beginnerProgram { model = init "images/blastoise.jpg", update = update, view = view }

-- MODEL

type alias Model = { face: Face, image: String }

type Face = Back | Front | Found

-- UPDATE

type Msg = Flip

update : Msg -> Model -> Model
update msg model =
    case msg of
        Flip -> flipCard model

flipCard : Model -> Model
flipCard model = case model.face of
    Front -> { model | face = Back }
    Back -> { model | face = Front }
    Found -> model


isFacingFront : Model -> Bool
isFacingFront model = case model.face of
    Front -> True
    _ -> False
    

setCardBack : Model -> Model
setCardBack model = case model.face of 
    Found -> model
    _ -> { model | face = Back }


setCardFound : Model -> Model
setCardFound model = case model.face of 
    Front -> { model | face = Found }
    _ -> model

isFound : Model -> Bool
isFound model = case model.face of
    Found -> True
    _ -> False

-- VIEW

view: Model -> Html Msg
view model = div [class "col-lg-2 col-sm-3 col-xs-3"]
    [ img [onClick Flip, src (getImage model), style [("display", "block"), ("margin", "auto"), ("width", "80%"), ("margin-bottom", "10px")] ] [] ]

    
getImage: Model -> String
getImage model = case model.face of 
    Back -> "images/cardBack.jpg"
    _ -> model.image