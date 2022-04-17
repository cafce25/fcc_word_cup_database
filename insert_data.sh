#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
$PSQL "TRUNCATE games, teams;"

cat games.csv | while IFS="," read year round winner opponent winner_goals opponent_goals; do
  if [[ year == $year ]]; then continue; fi
  winner_id="$($PSQL "SELECT team_id FROM teams WHERE name = '$winner';")"
  if [[ -z $winner_id ]]; then
    INSERT_WINNER_RETURN="$($PSQL "INSERT INTO teams(name) VALUES('$winner');")"
    if [[ "INSERT 0 1" == $INSERT_WINNER_RETURN ]]; then
      echo "Inserted $winner into teams."
    fi
    winner_id="$($PSQL "SELECT team_id FROM teams WHERE name = '$winner';")"
  fi
  opponent_id="$($PSQL "SELECT team_id FROM teams WHERE name = '$opponent';")"
  if [[ -z $opponent_id ]]; then
    INSERT_OPPONENT_RETURN="$($PSQL "INSERT INTO teams(name) VALUES('$opponent');")"
    if [[ "INSERT 0 1" == $INSERT_OPPONENT_RETURN ]]; then
      echo "Inserted $opponent into teams."
    fi
    opponent_id="$($PSQL "SELECT team_id FROM teams WHERE name = '$opponent';")"
  fi
  INSERT_GAME_RETURN="$($PSQL "INSERT INTO \
                     games(  year,   round,   winner_id,  opponent_id,  winner_goals,  opponent_goals) \
                     VALUES($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals);")"
  if [[ "INSERT 0 1" == $INSERT_GAME_RETURN ]]; then
    echo "Inserted $winner vs $opponent ($year) into games" 
  fi
done