-- | A search engine that can be used in nodejs invironment.
module Docs.Search.NodeEngine where

import Docs.Search.Extra (stringToList)
import Docs.Search.PackageIndex as PackageIndex
import Docs.Search.Engine (Engine, Query, Index)
import Docs.Search.SearchResult (SearchResult, typeOfResult)
import Docs.Search.TypeQuery (TypeQuery, penalty)

import Prelude

import Data.Array as Array
import Data.Identity (Identity)
import Data.List as List
import Data.Search.Trie as Trie
import Data.String.Common (toLower)


type NodeEngine = Engine Identity Index (Array SearchResult)


nodeEngine :: NodeEngine
nodeEngine =
  { queryIndex
  , queryTypeIndex
  , queryPackageIndex: PackageIndex.queryPackageIndex
  }


queryIndex :: Query Identity Index String SearchResult
queryIndex index input =
  pure { index, results:
                Array.fromFoldable $
                List.concat $
                Trie.queryValues
                (stringToList $ toLower input)
                index
       }


queryTypeIndex
  :: Query Identity (Array SearchResult) TypeQuery SearchResult
queryTypeIndex index typeQuery =
  pure { index, results:
                Array.take 100 $
                sortByDistance typeQuery index
       }


sortByDistance
  :: TypeQuery
  -> Array SearchResult
  -> Array SearchResult
sortByDistance typeQuery =
  Array.sortWith (map (penalty typeQuery) <<< typeOfResult)
