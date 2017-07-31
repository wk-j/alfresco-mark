module Main where

import System.Environment as IO
import Text.Printf
import Prelude hiding (readFile)
import System.IO.Strict (readFile)
import Data.Time (getZonedTime)
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
    let newLines  = insertAt format lines' 4
    
    saveReadmeContent file newLines

    putStrLn $ printf " -- %s" mark
    putStrLn $ printf " -- %s" url

pull :: String -> IO()
pull markRoot = do
    let pullCmd     = printf "git -C %s pull"  markRoot   
    callCommand pullCmd
    
commit :: String -> String -> IO()
commit markRoot mark = do
    let addCmd      = printf "git -C %s add --all" markRoot
    let commitCmd   = printf "git -C %s commit -m \"%s\"" markRoot mark
    let pushCmd     = printf "git -C %s push -u origin master" markRoot
    
    callCommand addCmd
    callCommand commitCmd
    callCommand pushCmd

main :: IO()
main = do
  root <- getHomeDirectory
  args <- IO.getArgs

  let markRoot = root ++ "/.alfresco-resource"
  let readme = markRoot ++ "/README.md"
  
  case args of 
    ["commit"] -> 
        putStrLn "Commit"
    [mark, url] -> do 
        pull markRoot 
        processMark readme mark url 
        commit markRoot mark
    _ -> 
        putStrLn "Invalid arguments"