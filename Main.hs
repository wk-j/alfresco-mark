module Main where

import System.Environment as IO
import Text.Printf
import Prelude hiding (readFile)
import System.IO.Strict (readFile)
import Data.Time (getCurrentTime, getZonedTime)
import System.Directory
import System.Process

getReadmeContent :: String -> IO [String]
getReadmeContent file = do
    contents <- readFile file
    return $ lines contents
    
saveReadmeContent :: String -> [String] -> IO()
saveReadmeContent file contents = writeFile file $ unlines contents

insertAt :: a -> [a] -> Int -> [a]
insertAt x ys 1 = x : ys
insertAt x (y:ys) n = y : insertAt x ys (n - 1)

formatMark :: String -> String -> IO String
formatMark mark url = do
    zonedTime <- fmap show getZonedTime
    return $ printf "- `[%s]` [%s](%s)" (take 16 zonedTime) mark url
  
processMark :: String -> String -> String -> IO()
processMark file mark url = do
    lines' <- getReadmeContent file
    format <- formatMark mark url
    let newLines  = insertAt format lines' 3
    
    saveReadmeContent file newLines

    putStrLn $ printf " -- %s" mark
    putStrLn $ printf " -- %s" url
    
commit :: String -> String -> IO()
commit markRoot mark = do
    let addCmd      = printf "git -C %s add --all" markRoot
    let commitCmd   = printf "git -C %s commit -m \"%s\"" markRoot mark
    let pullCmd     = printf "git -C %s pull"  markRoot   
    let pushCmd     = printf "git -C %s push -u origin master" markRoot
    
    callCommand pullCmd
    callCommand addCmd
    callCommand commitCmd
    callCommand pushCmd

main :: IO()
main = do
  root <- getHomeDirectory
  args <- IO.getArgs

  let markRoot = root ++ "/.bookmarks"
  let readme = markRoot ++ "/README.md"
  
  case args of 
    ["commit"] ->
      putStrLn "Commit"
    [mark, url] -> do
      processMark readme mark url
      commit markRoot mark
    _ ->
      putStrLn "Invalid arguments"