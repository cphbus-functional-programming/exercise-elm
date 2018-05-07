import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode
import Json.Encode as Encode

main : Program Never Model Msg
main =
  Html.program
    { init = start
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

url : String -> String
url action = "http://localhost:9000/member/" ++ action

-- MODEL

type alias Member =
  { id : Int
  , name : String
  , email : String
  }

type alias Model =
  { count : Int
  , message : String
  , member : Member
  }

start : (Model, Cmd Msg)
start =
  ( Model 0 "No message" (Member 7 "gunni" "gunni@gmail.com")
  , Cmd.none
  )

-- UPDATE

type Msg
  = GetMemberCount
  | GetMember
  | MemberReceived (Result Http.Error Member)
  | MemberCountReceived (Result Http.Error Int)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GetMemberCount ->
      (model, getMemberCount)

    MemberCountReceived (Ok newCount) ->
      ( { model | count = newCount }, Cmd.none)

    MemberCountReceived (Err error) ->
      ( { model | message = toString error }, Cmd.none)

    GetMember ->
      (model, getMember)

    MemberReceived (Ok member) ->
      ( { model | member = member }, Cmd.none)

    MemberReceived (Err error) ->
      ( { model | message = toString error }, Cmd.none)

-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ h2 [] [text ("Member Count = " ++ toString model.count) ]
    , button [ onClick GetMemberCount ] [ text "Update Member Count" ]
    , button [ onClick GetMember ] [ text "Get Member" ]
    , hr [] []
    , input [type_ "text", value (toString model.member.id)] []
    , input [type_ "text", value model.member.name] []
    , input [type_ "text", value model.member.email] []
    , hr [] []
    , text model.message
    ]

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model = Sub.none

-- HTTP
getMember : Cmd Msg
getMember =
    Http.send MemberReceived (Http.get (url "1") memberDecoder)

getMemberCount : Cmd Msg
getMemberCount =
    Http.send MemberCountReceived (Http.get (url "count") Decode.int)

memberDecoder : Decode.Decoder Member
memberDecoder =
  Decode.map3 Member
    (Decode.field "id" Decode.int)
    (Decode.field "name" Decode.string)
    (Decode.field "email" Decode.string)

encodeMember : Member -> Encode.Value
encodeMember member =
  Encode.object
    [ ("id", Encode.int member.id)
    , ("name", Encode.string member.name)
    , ("email", Encode.string member.email)
    ]
