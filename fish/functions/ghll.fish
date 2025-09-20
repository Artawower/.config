function ghll --wraps='gh run view --log 17021858545 | cat' --wraps="gh run view \$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId') --log" --wraps="gh run view \$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId') --log | cat" --description "alias ghll=gh run view \$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId') --log | cat"
  gh run view $(gh run list --limit 1 --json databaseId --jq '.[0].databaseId') --log | cat $argv
        
end
