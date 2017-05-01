module Main where
  
import System.Environment as IO

githubUser = IO.getEnv "ghu"
githubToken = IO.getEnv "ghp"

main = do
  user <- githubUser
  pass <- githubToken
  putStrLn user
  putStrLn pass
