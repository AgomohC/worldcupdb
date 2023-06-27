#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database

echo $($PSQL "TRUNCATE games, teams")

# INSERT TEAMS INTO THE DB
cat games.csv | while IFS=","  read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $WINNER != "winner" ]]
  then
    # get winner's team_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'") 

    # if not found
    if [[ -z $WINNER_ID ]]
    then
      # set to null
      WINNER_ID=null
      # insert winner
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into team, $WINNER
         WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
       
      fi
    fi
    # get loser's team_id
     OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'") 

    # if not found
    if [[ -z $OPPONENT_ID ]]
    then
      # set to null
      OPPONENT_ID=null
      # insert winner
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into team, $OPPONENT
        OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'") 
      fi
    fi
 

    echo $WINNER_ID
    echo $OPPONENT_ID
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_goals, opponent_goals, winner_id, opponent_id) VALUES('$YEAR', '$ROUND', '$WINNER_GOALS', '$OPPONENT_GOALS', $WINNER_ID, $OPPONENT_ID);")

    if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
    then
      echo Inserted into games, $WINNER vs $OPPONENT
    fi
  fi
done