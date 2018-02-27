{-# LANGUAGE MonadComprehensions #-}
{-# LANGUAGE RebindableSyntax  #-}

module Set2 where
  
import MCPrelude

-- required for Haskell for Mac to display values in playground
import Prelude (($!)) 

-- 1. The Maybe Type

data Maybe a = Just a | Nothing
  deriving (Eq, Show) 

{-- the exercise wants us to do this, but "deriving" is easier
 -- the exercise should have had us define Eq as well
 
instance Show a => Show (Maybe a) where
  show (Just a)= "Just " ++ show a
  show Nothing = "Nothing"
--}

-- 2. Build a library of things that can fail

headMay :: [a] -> Maybe a
headMay [] = Nothing
headMay (a : _) = Just a

tailMay :: [a] -> Maybe [a]
tailMay [] = Nothing
tailMay (_ : as) = Just as

lookupMay :: Eq a => a -> [(a, b)] -> Maybe b
lookupMay a [] = Nothing
lookupMay a' ((a, b) : tups) =
  ifThenElse (a' == a) (Just b) $ lookupMay a' tups

divMay :: (Eq a, Fractional a) => a -> a -> Maybe a
divMay _ 0 = Nothing
divMay a1 a2 = Just (a1 / a2)

maximumMay :: Ord a => [a] -> Maybe a
maximumMay [] = Nothing
maximumMay [a] = Just a
maximumMay (a : as) = case maximumMay as of
   Just m -> Just $ a `max` m
   Nothing -> Just a

minimumMay :: Ord a => [a] -> Maybe a
minimumMay [] = Nothing
minimumMay [a] = Just a
minimumMay (a : as) = case minimumMay as of
   Just m -> Just $ a `min` m
   Nothing -> Just a
   
-- 3. Chains of Failing Computations
queryGreek :: GreekData -> String -> Maybe Double
queryGreek greekData key =
  case lookupMay key greekData of
      Nothing -> Nothing
      Just xs -> case tailMay xs of
        Nothing -> Nothing
        Just ys -> case maximumMay ys of
          Nothing -> Nothing
          Just mx -> case headMay xs of
            Nothing -> Nothing
            Just first -> divMay (fromIntegral mx) (fromIntegral first)

-- 4. Generalizing chains of failures
chain :: (a -> Maybe b) -> Maybe a -> Maybe b
chain f Nothing = Nothing
chain f (Just a) = f a

link :: Maybe a -> (a -> Maybe b) -> Maybe b
link Nothing f = Nothing
link (Just a) f = f a

queryGreek2 :: GreekData -> String -> Maybe Double
queryGreek2 greekData key =
  let
    xsMaybe = lookupMay key greekData
    ysMaybe = link xsMaybe tailMay
    mxMaybe = link ysMaybe maximumMay
    firstMaybe = link xsMaybe headMay
  in
    link firstMaybe (\first ->
      link mxMaybe (\mx ->
        divMay (fromIntegral mx) (fromIntegral first)))
        