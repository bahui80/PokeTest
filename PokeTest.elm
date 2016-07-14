import Html exposing (..)
import PokeCard as Card
import Html.App as App
import Html.Attributes exposing (..)
import String
import Html.Events exposing (..)
import Time exposing (..)
import Date exposing (..)
import Random.Array
import Random
import Array
import Cmd.Extra

-- MAIN

cardsList : List Card.Model
cardsList = List.map (\image -> Card.init image) ["images/blastoise.jpg", "images/charmeleon.jpg", "images/raichu.jpg", "images/diglett.jpg", "images/venusaur.jpg", "images/mewto.jpg", "images/ninetales.jpg", "images/scyther.jpg", "images/wigglytuff.jpg", "images/pikachu.jpg", "images/omanyte.jpg", "images/jynx.jpg"]

indexedCardList : List IndexedCard
indexedCardList = List.map2 (<|) indexList (cardsList ++ cardsList)

indexList : List (Card.Model -> IndexedCard)
indexList = List.map (\index -> IndexedCard index) [0..((List.length cardsList) * 2)]

shuffleCards : List IndexedCard -> Cmd Msg
shuffleCards cards = Random.generate ShuffleCards (Random.Array.shuffle (Array.fromList indexedCardList))

init = (Model [] 0 0 NewGame, Cmd.none)

main = App.program { init = init, update = update, view = view, subscriptions = subscriptions }

-- MODEL

type alias Model = { cards : List IndexedCard, startTime : Time, currentTime : Time, gameState : GameState } 

type alias IndexedCard = { id : Int, model : Card.Model }

type GameState = NewGame | InProgress | Finished

-- UPDATE

type Msg = ShuffleCards (Array.Array IndexedCard) | FlipCard Int Card.Msg | Start | MainMenu | Tick Time | ChangeGameState GameState

update : Msg -> Model -> (Model, Cmd Msg)
update msg ({cards, startTime, currentTime, gameState} as model) =
    case msg of
        Start -> (Model [] 0 0 InProgress, shuffleCards indexedCardList)
        ShuffleCards array -> ({ model | cards = Array.toList array }, Cmd.none)
        Tick newTime -> if (startTime == 0) then ({ model | startTime = newTime, currentTime = newTime }, Cmd.none) else ({ model | currentTime = newTime }, Cmd.none)
        FlipCard id message -> ({ model | cards = checkCards (updateCards id message cards) }, Cmd.Extra.message (ChangeGameState gameState))
        ChangeGameState state -> ({ model | gameState = checkGameState cards }, Cmd.none)
        MainMenu -> init

updateCards : Int -> Card.Msg -> List IndexedCard -> List IndexedCard
updateCards id message cards = List.map (updateCard id message) cards

updateCard : Int -> Card.Msg -> IndexedCard -> IndexedCard
updateCard targetId msg {id, model} = IndexedCard id (if targetId == id then Card.update msg model else model)

checkCards : List IndexedCard -> List IndexedCard
checkCards cards = 
    let 
        frontCards = getFrontCards cards
        totalFrontCards = List.length frontCards
    in
        if totalFrontCards == 2 && checkPairOfCards frontCards then 
            setCardsFound cards
        else
            if totalFrontCards > 2 then
                setAllCardsBack cards
            else 
                cards


checkPairOfCards : List IndexedCard -> Bool
checkPairOfCards model = 
    let 
        f value acc = if List.member value.model acc then acc else (value.model)::acc
    in 
        List.length (List.foldl f [] model) <= 1  


getFrontCards : List IndexedCard -> List IndexedCard
getFrontCards cards = List.filter (\indexedCard -> Card.isFacingFront (indexedCard.model)) cards

setAllCardsBack : List IndexedCard -> List IndexedCard
setAllCardsBack cards = List.map (\indexedCard -> { indexedCard | model = Card.setCardBack (indexedCard.model) }) cards

setCardsFound : List IndexedCard -> List IndexedCard
setCardsFound cards = List.map (\indexedCard -> { indexedCard | model = Card.setCardFound (indexedCard.model) }) cards

checkGameState : List IndexedCard -> GameState
checkGameState cards = 
    if List.length cards == List.length (getFoundCards cards) then
        Finished
    else
        InProgress


getFoundCards : List IndexedCard -> List IndexedCard
getFoundCards cards = List.filter (\indexedCard -> Card.isFound (indexedCard.model)) cards

-- VIEW

stylesheet : Html Msg
stylesheet =
    let
        tag = "link"
        attrs =
            [ attribute "rel"       "stylesheet"
            , attribute "property"  "stylesheet"
            , attribute "href"      "css/bootstrap.css"
            ]
        children = []
    in 
        node tag attrs children

view : Model -> Html Msg
view model = 
    let 
        indexedCards = List.map viewIndexedCard model.cards
        totalTime = model.currentTime - model.startTime
        date = Date.fromTime totalTime
    in 
        case model.gameState of
            NewGame -> div [class "jumbotron"]
                       [stylesheet,
                       h1 [style [("text-align", "center"), ("font-weight", "bold"), ("font-size", "70px"), ("font-family", "Lora, Georgia, Times New Roman, Times, serif")]] [text "Poketest"],
                       p [style [("text-align", "center"), ("font-family", "Lora, Georgia, Times New Roman, Times, serif")]] [text "Welcome to the memotest of Pokemon. To win the game you must help Ash to catch them all!"],
                       img [src "images/ash_pokeball.png", style [("display", "block"), ("margin", "auto"), ("height", "320px"), ("width", "320px")]] [],
                       button [onClick Start, class "btn btn-primary", style [("display", "block"), ("margin", "auto")]] [text "CATCH THEM!"]
                       ]
            InProgress -> div [class "container-fluid"] 
                            [stylesheet,
                            audio [id "player", src "sounds/pokemon_song.mp3", autoplay True, loop True] [],
                            div [class "row-fluid"] 
                                [div [class "col-lg-2"] 
                                    [h1 [style[("font-family", "Lora, Georgia, Times New Roman, Times, serif"), ("text-align", "center")]] [text "Total time"], 
                                    h1 [style[("color", "green"), ("text-align", "center"), ("font-weight", "bold"), ("font-family", "Lora, Georgia, Times New Roman, Times, serif")]] [text (String.concat [toString (Date.minute date), ":", toString (Date.second date)])],
                                    br [] [],
                                    button [onClick Start, class "btn btn-danger", style[("margin", "auto"), ("display", "block")]] [text "Restart"]
                                    ],
                                div [class "col-lg-10"] 
                                    [div [class "col-lg-12", style[("margin-top", "10px")]] indexedCards]
                                ]      
                            ]
            Finished -> div [class "jumbotron"]
                        [stylesheet,
                        h1 [style [("text-align", "center"), ("font-weight", "bold"), ("font-family", "Lora, Georgia, Times New Roman, Times, serif")]] [text "You catched them all!"],
                        img [src "images/pokeball.gif", style [("display", "block"), ("margin", "auto")]] [],
                        h2 [style [("text-align", "center"), ("font-family", "Lora, Georgia, Times New Roman, Times, serif")]] [text "Your time"],
                        h1 [style [("color", "green"), ("text-align", "center"), ("font-weight", "bold"), ("font-family", "Lora, Georgia, Times New Roman, Times, serif")]] [text (String.concat [toString (Date.minute date), ":", toString (Date.second date)])],
                        br [] [],
                        br [] [],
                        br [] [],
                        button [onClick MainMenu, class "btn btn-primary", style [("display", "block"), ("margin", "auto")]] [text "Play again"]
                        ]
  

viewIndexedCard : IndexedCard -> Html Msg
viewIndexedCard {id, model} = App.map (FlipCard id) (Card.view model)



-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model = case model.gameState of
                        InProgress -> Time.every Time.second Tick
                        _ -> Sub.none