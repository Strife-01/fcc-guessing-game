#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"



echo Enter your username:
read USERNAME

while [[ -z $USERNAME ]]
do
  echo Enter your username:
  read USERNAME
done

CHECK_USERNAME=$($PSQL "SELECT user_name FROM users WHERE user_name='$USERNAME';")
if [[ -z $CHECK_USERNAME ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_NAME_IN_DATABASE=$($PSQL "INSERT INTO users(user_name, games_played) VALUES('$USERNAME', 1);")

else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_name='$CHECK_USERNAME';")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_name='$CHECK_USERNAME';")
  echo "Welcome back, $CHECK_USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE user_name='$USERNAME';")
fi


RANDOM_NUMBER=$(($RANDOM%1001))
NUMBER_OF_TRIES=0


echo "Guess the secret number between 1 and 1000:"

read ANSWER
NUMBER_OF_TRIES=$(($NUMBER_OF_TRIES + 1))

while [[ $ANSWER -ne $RANDOM_NUMBER ]]
do

  if [[ ! $ANSWER =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read ANSWER
    NUMBER_OF_TRIES=$(($NUMBER_OF_TRIES + 1))


  else

    if [[ $ANSWER -gt $RANDOM_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
      read ANSWER
      NUMBER_OF_TRIES=$(($NUMBER_OF_TRIES + 1))


    else
      echo "It's higher than that, guess again:" 
      read ANSWER
      NUMBER_OF_TRIES=$(($NUMBER_OF_TRIES + 1))


    fi

  fi

done

echo "You guessed it in $NUMBER_OF_TRIES tries. The secret number was $RANDOM_NUMBER. Nice job!"

BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_name='$USERNAME';")

if [[ -z $BEST_GAME ]]
then
  INSERT_FIRST_BEST=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_TRIES WHERE user_name='$USERNAME';")

else
  if [[ $NUMBER_OF_TRIES -lt $BEST_GAME ]]
  then
    UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_TRIES WHERE user_name='$USERNAME';")
  fi

fi
